package com.ngclass.backend.content.service;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.Chapter;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.ContentShare;
import com.ngclass.backend.content.domain.ContentView;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.domain.FileKind;
import com.ngclass.backend.content.dto.ContentDtos.ChapterRef;
import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.dto.ContentDtos.MyContentItem;
import com.ngclass.backend.content.dto.ContentDtos.SubjectRef;
import com.ngclass.backend.content.repository.ChapterRepository;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.content.repository.ContentShareRepository;
import com.ngclass.backend.content.repository.ContentViewRepository;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.service.FamilyAccess;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.work.service.MyHomeworkService;
import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * "Cours" for a pupil or a parent (spec 09): the published documents shared with the child's groups,
 * directly or through a chapter, and the viewer links for anyone allowed to open a document.
 */
@Service
@RequiredArgsConstructor
public class MyContentService {
	private final FamilyAccess family;
	private final GroupMemberRepository members;
	private final ClassGroupRepository groups;
	private final ContentItemRepository items;
	private final ContentShareRepository shares;
	private final ChapterRepository chapters;
	private final SubjectRepository subjects;
	private final ContentViewRepository views;
	private final FileLinks links;
	private final MyHomeworkService homework;
	private final Clock clock;

	/** [studentId] is required for a parent (one of their children) and ignored for a pupil. */
	@Transactional(readOnly = true)
	public List<MyContentItem> mine(AuthenticatedUser user, UUID studentId) {
		List<UUID> groupIds = activeGroups(List.of(family.child(user, studentId)));
		if (groupIds.isEmpty()) {
			return List.of();
		}
		List<ContentItem> visible = items.visibleTo(groupIds);
		if (visible.isEmpty()) {
			return List.of();
		}
		// The latest share that makes each document visible: "partagé hier".
		Map<UUID, Instant> byItem = new HashMap<>();
		Map<UUID, Instant> byChapter = new HashMap<>();
		for (ContentShare share : shares.findByGroupIdIn(groupIds)) {
			if (share.getItemId() != null) {
				byItem.merge(share.getItemId(), share.getSharedAt(), MyContentService::later);
			} else {
				byChapter.merge(share.getChapterId(), share.getSharedAt(), MyContentService::later);
			}
		}
		Map<UUID, Subject> subjectById = subjects.findAllById(visible.stream().map(ContentItem::getSubjectId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(Subject::getId, Function.identity()));
		Set<UUID> chapterIds = visible.stream().map(ContentItem::getChapterId).filter(id -> id != null).collect(Collectors.toSet());
		Map<UUID, Chapter> chapterById = chapterIds.isEmpty() ? Map.of()
				: chapters.findByIdIn(chapterIds).stream().collect(Collectors.toMap(Chapter::getId, Function.identity()));
		Set<UUID> seen = new HashSet<>(views.viewedBy(user.id(), visible.stream().map(ContentItem::getId).toList()));
		return visible.stream()
				.map(item -> {
					Subject subject = subjectById.get(item.getSubjectId());
					Chapter chapter = item.getChapterId() == null ? null : chapterById.get(item.getChapterId());
					Instant shared = later(byItem.get(item.getId()), chapter == null ? null : byChapter.get(chapter.getId()));
					FileAsset file = item.getFile();
					return new MyContentItem(
							item.getId(),
							item.getTitle(),
							item.getTag().name(),
							file.kind().name(),
							file.getPageCount(),
							new SubjectRef(subject.getId(), subject.name(), subject.getColor(), subject.getPosition()),
							chapter == null ? null : new ChapterRef(chapter.getId(), chapter.getTitle(), chapter.getPosition()),
							shared,
							!seen.contains(item.getId()));
				})
				.sorted(Comparator.comparing((MyContentItem i) -> i.subject().position())
						.thenComparing(i -> i.chapter() == null ? Integer.MAX_VALUE : i.chapter().position())
						.thenComparing(MyContentItem::sharedAt, Comparator.nullsLast(Comparator.reverseOrder())))
				.toList();
	}

	/**
	 * Signed links to a document's pages and file. The teacher opens any of hers; a pupil or a parent only
	 * what their Cours shows, and opening it takes "Nouveau" off for them.
	 */
	@Transactional
	public ContentViewResponse view(UUID itemId) {
		AuthenticatedUser me = CurrentTeacher.principal();
		ContentItem item = switch (me.role()) {
			case TEACHER -> items.findByIdAndTeacherId(itemId, me.id()).orElseThrow(() -> ApiException.notFound("content_not_found"));
			case STUDENT, PARENT -> {
				List<UUID> groupIds = activeGroups(family.children(me));
				// Shared with the child's groups, or given as homework to the child (spec 06).
				ContentItem found = (groupIds.isEmpty() ? List.<ContentItem>of() : items.visibleTo(groupIds)).stream()
						.filter(i -> i.getId().equals(itemId))
						.findFirst()
						.or(() -> homework.assignedToFamily(me, itemId) ? items.findById(itemId) : Optional.empty())
						.orElseThrow(() -> ApiException.notFound("content_not_found"));
				ContentView.Key key = new ContentView.Key(itemId, me.id());
				if (!views.existsById(key)) {
					views.save(new ContentView(key, clock.instant()));
				}
				yield found;
			}
			case ADMIN -> throw new ApiException(HttpStatus.FORBIDDEN, "forbidden");
		};
		FileAsset file = item.getFile();
		FileKind kind = file.kind();
		int pages = switch (kind) {
			case PDF -> file.getPageCount() == null ? 0 : file.getPageCount();
			case IMAGE -> 1;
			case WORD -> 0;
		};
		Subject subject = subjects.findById(item.getSubjectId()).orElseThrow();
		String chapterTitle = item.getChapterId() == null ? null : chapters.findById(item.getChapterId()).map(Chapter::getTitle).orElse(null);
		return new ContentViewResponse(
				item.getId(),
				item.getTitle(),
				subject.name(),
				chapterTitle,
				kind.name(),
				item.getTag().name(),
				file.getPageCount(),
				file.getOriginalName(),
				file.getSizeBytes(),
				IntStream.rangeClosed(1, pages).mapToObj(page -> links.link(item.getId(), page)).toList(),
				links.link(item.getId(), 0));
	}

	/** The children's current groups, archived groups left out. */
	private List<UUID> activeGroups(List<Student> children) {
		List<UUID> ids = members.findById_StudentIdInAndLeftAtIsNull(children.stream().map(Student::getId).toList()).stream()
				.map(m -> m.getId().getGroupId())
				.distinct()
				.toList();
		if (ids.isEmpty()) {
			return List.of();
		}
		return groups.findByIdIn(ids).stream().filter(g -> g.getArchivedAt() == null).map(ClassGroup::getId).toList();
	}

	private static Instant later(Instant a, Instant b) {
		if (a == null) {
			return b;
		}
		return b == null || a.isAfter(b) ? a : b;
	}
}
