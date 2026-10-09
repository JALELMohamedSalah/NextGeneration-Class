package com.ngclass.backend.content.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.Chapter;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.ContentShare;
import com.ngclass.backend.content.domain.ContentStatus;
import com.ngclass.backend.content.domain.ContentTag;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.dto.ContentDtos.ChapterItem;
import com.ngclass.backend.content.dto.ContentDtos.ChapterRequest;
import com.ngclass.backend.content.dto.ContentDtos.ContentItemResponse;
import com.ngclass.backend.content.dto.ContentDtos.LibraryResponse;
import com.ngclass.backend.content.dto.ContentDtos.UpdateRequest;
import com.ngclass.backend.content.dto.ContentDtos.UploadRequest;
import com.ngclass.backend.content.repository.ChapterRepository;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.content.repository.ContentShareRepository;
import com.ngclass.backend.content.repository.FileAssetRepository;
import com.ngclass.backend.content.service.FileInspector.Inspected;
import com.ngclass.backend.content.storage.FileStorage;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.school.repository.LevelRepository;
import com.ngclass.backend.school.service.SubjectService;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.time.Clock;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

/** The teacher's library (spec 04): chapters, documents, and what is shared with which group. */
@Service
@RequiredArgsConstructor
public class ContentService {
	private final ChapterRepository chapters;
	private final ContentItemRepository items;
	private final ContentShareRepository shares;
	private final FileAssetRepository files;
	private final FileStorage storage;
	private final FileInspector inspector;
	private final SubjectService subjectService;
	private final LevelRepository levels;
	private final GroupService groupService;
	private final CurrentTeacher teacher;
	private final Clock clock;

	/** Every chapter and every document not archived; the app builds the tree, searches and filters. */
	@Transactional(readOnly = true)
	public LibraryResponse library() {
		UUID me = teacher.id();
		List<Chapter> all = chapters.findByTeacherIdOrderByPositionAscCreatedAtAsc(me);
		List<ContentItem> list = items.findByTeacherIdAndStatusNotOrderByUpdatedAtDesc(me, ContentStatus.ARCHIVED);
		Map<UUID, List<UUID>> chapterGroups = all.isEmpty() ? Map.of()
				: groupsBy(shares.findByChapterIdIn(all.stream().map(Chapter::getId).toList()), ContentShare::getChapterId);
		Map<UUID, List<UUID>> itemGroups = list.isEmpty() ? Map.of()
				: groupsBy(shares.findByItemIdIn(list.stream().map(ContentItem::getId).toList()), ContentShare::getItemId);
		return new LibraryResponse(
				all.stream().map(c -> chapterItem(c, chapterGroups.getOrDefault(c.getId(), List.of()))).toList(),
				list.stream().map(i -> response(i, itemGroups.getOrDefault(i.getId(), List.of()))).toList());
	}

	// ── Chapters ──

	@Transactional
	public ChapterItem createChapter(ChapterRequest request) {
		UUID me = teacher.id();
		placement(request.subjectId(), request.levelId(), null);
		String title = request.title().trim();
		ensureFree(me, request.subjectId(), request.levelId(), title, null);
		Chapter chapter = chapters.save(Chapter.builder()
				.teacherId(me)
				.subjectId(request.subjectId())
				.levelId(request.levelId())
				.title(title)
				.position(chapters.lastPosition(me, request.subjectId(), request.levelId()) + 1)
				.build());
		return chapterItem(chapter, List.of());
	}

	@Transactional
	public ChapterItem renameChapter(UUID id, String newTitle) {
		Chapter chapter = ownChapter(id);
		String title = newTitle.trim();
		ensureFree(chapter.getTeacherId(), chapter.getSubjectId(), chapter.getLevelId(), title, chapter.getId());
		chapter.setTitle(title);
		return chapterItem(chapter, groupIds(shares.findByChapterId(id)));
	}

	/** Its documents stay, in "Sans chapitre"; the chapter's shares go with it. */
	@Transactional
	public void deleteChapter(UUID id) {
		Chapter chapter = ownChapter(id);
		items.clearChapter(id);
		chapters.delete(chapter);
	}

	/** Every published document of the chapter, including those added later, shows in these groups' Cours. */
	@Transactional
	public ChapterItem shareChapter(UUID id, Collection<UUID> groupIds) {
		Chapter chapter = ownChapter(id);
		List<UUID> kept = replaceShares(shares.findByChapterId(id), groupIds, groupId -> ContentShare.builder().chapterId(id).groupId(groupId));
		return chapterItem(chapter, kept);
	}

	// ── Documents ──

	/** [data] and [fileName] as uploaded; the file's real type is read from its first bytes. */
	@Transactional
	public ContentItemResponse upload(byte[] data, String fileName, UploadRequest request) {
		UUID me = teacher.id();
		placement(request.subjectId(), request.levelId(), request.chapterId());
		ContentTag tag = tag(request.tag());
		List<UUID> groupIds = request.groupIds() == null ? List.of() : request.groupIds();
		if (request.draft() && !groupIds.isEmpty()) {
			throw new ApiException(HttpStatus.CONFLICT, "content_not_published");
		}
		Inspected inspected = inspector.inspect(data, fileName);
		FileAsset asset = files.save(FileAsset.builder()
				.teacherId(me)
				.storageKey(storage.save(data))
				.mimeType(inspected.mimeType())
				.sizeBytes(data.length)
				.originalName(cleanName(fileName))
				.pageCount(inspected.pageCount())
				.build());
		ContentItem item = items.saveAndFlush(ContentItem.builder()
				.teacherId(me)
				.title(request.title().trim())
				.subjectId(request.subjectId())
				.levelId(request.levelId())
				.chapterId(request.chapterId())
				.status(request.draft() ? ContentStatus.DRAFT : ContentStatus.PUBLISHED)
				.tag(tag)
				.file(asset)
				.build());
		List<UUID> kept = replaceShares(List.of(), groupIds, groupId -> ContentShare.builder().itemId(item.getId()).groupId(groupId));
		return response(item, kept);
	}

	/** Title, place, tag; turning a document back into a draft takes it out of every group's Cours. */
	@Transactional
	public ContentItemResponse update(UUID id, UpdateRequest request) {
		ContentItem item = own(id);
		placement(request.subjectId(), request.levelId(), request.chapterId());
		item.setTitle(request.title().trim());
		item.setSubjectId(request.subjectId());
		item.setLevelId(request.levelId());
		item.setChapterId(request.chapterId());
		item.setTag(tag(request.tag()));
		if (request.draft() && item.getStatus() == ContentStatus.PUBLISHED) {
			item.setStatus(ContentStatus.DRAFT);
			shares.deleteAll(shares.findByItemId(id));
		} else if (!request.draft() && item.getStatus() == ContentStatus.DRAFT) {
			item.setStatus(ContentStatus.PUBLISHED);
		}
		items.saveAndFlush(item);
		return response(item, groupIds(shares.findByItemId(id)));
	}

	@Transactional
	public ContentItemResponse share(UUID id, Collection<UUID> groupIds) {
		ContentItem item = own(id);
		if (item.getStatus() != ContentStatus.PUBLISHED && !groupIds.isEmpty()) {
			throw new ApiException(HttpStatus.CONFLICT, "content_not_published");
		}
		List<UUID> kept = replaceShares(shares.findByItemId(id), groupIds, groupId -> ContentShare.builder().itemId(id).groupId(groupId));
		return response(item, kept);
	}

	/** Hidden from the library and from every Cours; nothing is deleted (spec 04). */
	@Transactional
	public void archive(UUID id) {
		ContentItem item = own(id);
		item.setStatus(ContentStatus.ARCHIVED);
		shares.deleteAll(shares.findByItemId(id));
	}

	public ContentItem own(UUID id) {
		return items.findByIdAndTeacherId(id, teacher.id()).orElseThrow(() -> ApiException.notFound("content_not_found"));
	}

	// ── Helpers ──

	private Chapter ownChapter(UUID id) {
		return chapters.findByIdAndTeacherId(id, teacher.id()).orElseThrow(() -> ApiException.notFound("chapter_not_found"));
	}

	/** Her subject, a level, and a chapter of that same subject and level when one is given. */
	private void placement(UUID subjectId, UUID levelId, UUID chapterId) {
		subjectService.own(subjectId);
		levels.findById(levelId).orElseThrow(() -> ApiException.notFound("level_not_found"));
		if (chapterId != null) {
			Chapter chapter = ownChapter(chapterId);
			if (!chapter.getSubjectId().equals(subjectId) || !chapter.getLevelId().equals(levelId)) {
				throw ApiException.badRequest("chapter_mismatch");
			}
		}
	}

	private void ensureFree(UUID teacherId, UUID subjectId, UUID levelId, String title, UUID except) {
		boolean taken = chapters.findByTeacherIdAndSubjectIdAndLevelIdAndTitleIgnoreCase(teacherId, subjectId, levelId, title).stream()
				.anyMatch(c -> !c.getId().equals(except));
		if (taken) {
			throw ApiException.badRequest("chapter_exists", title);
		}
	}

	/** The groups to share with, all hers and active; existing shares keep their date. */
	private List<UUID> replaceShares(List<ContentShare> existing, Collection<UUID> wanted, Function<UUID, ContentShare.ContentShareBuilder> builder) {
		Set<UUID> target = new LinkedHashSet<>(wanted);
		target.forEach(groupService::require);
		shares.deleteAll(existing.stream().filter(s -> !target.contains(s.getGroupId())).toList());
		Set<UUID> present = new LinkedHashSet<>(groupIds(existing));
		for (UUID groupId : target) {
			if (!present.contains(groupId)) {
				shares.save(builder.apply(groupId).sharedAt(clock.instant()).build());
			}
		}
		return List.copyOf(target);
	}

	private static ContentTag tag(String value) {
		try {
			return ContentTag.valueOf(value.trim().toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException e) {
			throw ApiException.badRequest("invalid_tag");
		}
	}

	public static byte[] bytes(MultipartFile file) {
		if (file == null || file.isEmpty()) {
			throw ApiException.badRequest("file_required");
		}
		try {
			return file.getBytes();
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	/** The name as uploaded, without any folder part, shortened to fit. */
	private static String cleanName(String original) {
		String name = original == null || original.isBlank() ? "document" : original.replace('\\', '/');
		name = name.substring(name.lastIndexOf('/') + 1).trim();
		return name.length() > 255 ? name.substring(name.length() - 255) : name;
	}

	private static List<UUID> groupIds(List<ContentShare> list) {
		return list.stream().map(ContentShare::getGroupId).toList();
	}

	private static Map<UUID, List<UUID>> groupsBy(List<ContentShare> list, Function<ContentShare, UUID> key) {
		Map<UUID, List<UUID>> out = new HashMap<>();
		for (ContentShare share : list) {
			out.computeIfAbsent(key.apply(share), k -> new ArrayList<>()).add(share.getGroupId());
		}
		return out;
	}

	private static ChapterItem chapterItem(Chapter chapter, List<UUID> groupIds) {
		return new ChapterItem(chapter.getId(), chapter.getSubjectId(), chapter.getLevelId(), chapter.getTitle(), chapter.getPosition(), groupIds);
	}

	public static ContentItemResponse response(ContentItem item, List<UUID> groupIds) {
		FileAsset file = item.getFile();
		return new ContentItemResponse(
				item.getId(),
				item.getTitle(),
				item.getSubjectId(),
				item.getLevelId(),
				item.getChapterId(),
				item.getTag().name(),
				item.getStatus().name(),
				file.kind().name(),
				file.getOriginalName(),
				file.getSizeBytes(),
				file.getPageCount(),
				groupIds,
				item.getCreatedAt(),
				item.getUpdatedAt());
	}
}
