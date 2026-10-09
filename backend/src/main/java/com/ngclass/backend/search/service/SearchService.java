package com.ngclass.backend.search.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.LocalizedText;
import com.ngclass.backend.content.dto.ContentDtos.ChapterItem;
import com.ngclass.backend.content.dto.ContentDtos.ContentItemResponse;
import com.ngclass.backend.content.dto.ContentDtos.LibraryResponse;
import com.ngclass.backend.content.service.ContentService;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.dto.StudentDtos.GroupTag;
import com.ngclass.backend.people.dto.StudentDtos.StudentRow;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.service.StudentService;
import com.ngclass.backend.school.domain.Level;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.LevelRepository;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.search.dto.SearchDtos.ChapterHit;
import com.ngclass.backend.search.dto.SearchDtos.ChildRef;
import com.ngclass.backend.search.dto.SearchDtos.DocumentHit;
import com.ngclass.backend.search.dto.SearchDtos.EvaluationHit;
import com.ngclass.backend.search.dto.SearchDtos.GroupHit;
import com.ngclass.backend.search.dto.SearchDtos.HomeworkHit;
import com.ngclass.backend.search.dto.SearchDtos.ParentHit;
import com.ngclass.backend.search.dto.SearchDtos.SearchResults;
import com.ngclass.backend.search.dto.SearchDtos.StudentHit;
import com.ngclass.backend.work.service.EvaluationService;
import com.ngclass.backend.work.service.HomeworkService;
import java.text.Normalizer;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The search of the teacher's top bar (design `r2/Recherche.png`): from two letters, accents and capitals ignored, in
 * everything that is hers and not archived. A result whose words start with the letters comes before one that only
 * contains them; five per family at most.
 */
@Service
@RequiredArgsConstructor
public class SearchService {
	public static final int PER_FAMILY = 5;

	private final StudentService students;
	private final ParentRepository parents;
	private final GroupService groups;
	private final ContentService contents;
	private final HomeworkService homework;
	private final EvaluationService evaluations;
	private final SubjectRepository subjects;
	private final LevelRepository levels;
	private final CurrentTeacher teacher;

	@Transactional(readOnly = true)
	public SearchResults search(String query) {
		String q = plain(query);
		if (q.length() < 2) {
			return new SearchResults(List.of(), List.of(), List.of(), List.of(), List.of(), List.of(), List.of());
		}
		List<StudentHit> pupils = best(students.list(false), q,
				(StudentRow s) -> Stream.of(s.firstName() + " " + s.lastName(), s.lastName() + " " + s.firstName(), s.username(), s.phone()),
				s -> s.firstName() + " " + s.lastName())
				.map(s -> new StudentHit(s.id(), s.firstName(), s.lastName(), s.level(), s.groups().stream().map(GroupTag::name).toList()))
				.toList();
		List<ParentHit> families = best(parents.findAllWithChildren(teacher.id()), q,
				(Parent p) -> Stream.of(p.getUser().getFirstName() + " " + p.getUser().getLastName(),
						p.getUser().getLastName() + " " + p.getUser().getFirstName(), p.getUser().getPhone()),
				p -> p.getUser().getFirstName() + " " + p.getUser().getLastName())
				.map(p -> new ParentHit(p.getId(), p.getUser().getFirstName(), p.getUser().getLastName(), p.getUser().getPhone(),
						p.getChildren().stream()
								.filter(c -> c.getArchivedAt() == null)
								.sorted(Comparator.comparing((Student c) -> c.getUser().getFirstName()))
								.map(c -> new ChildRef(c.getId(), c.getUser().getFirstName()))
								.toList()))
				.filter(p -> !p.children().isEmpty())
				.toList();
		List<GroupHit> classes = best(groups.list(), q, g -> Stream.of(g.name(), g.code()), g -> g.name())
				.map(g -> new GroupHit(g.id(), g.name(), g.code(), g.color(), g.privateLesson(), g.memberCount()))
				.toList();

		LibraryResponse library = contents.library();
		Map<UUID, Subject> subjectById = subjects.findByTeacherIdOrderByPositionAsc(teacher.id()).stream()
				.collect(Collectors.toMap(Subject::getId, Function.identity()));
		Map<UUID, Level> levelById = levels.findAllByOrderByPositionAsc().stream().collect(Collectors.toMap(Level::getId, Function.identity()));
		Map<UUID, ChapterItem> chapterById = library.chapters().stream().collect(Collectors.toMap(ChapterItem::id, Function.identity()));
		List<DocumentHit> documents = best(library.items(), q, (ContentItemResponse d) -> Stream.of(d.title()), ContentItemResponse::title)
				.map(d -> new DocumentHit(d.id(), d.title(), d.tag(), d.kind(), name(subjectById.get(d.subjectId())), name(levelById.get(d.levelId())),
						d.chapterId() == null || !chapterById.containsKey(d.chapterId()) ? null : chapterById.get(d.chapterId()).title()))
				.toList();
		Map<UUID, Long> documentsPerChapter = library.items().stream().filter(d -> d.chapterId() != null)
				.collect(Collectors.groupingBy(ContentItemResponse::chapterId, Collectors.counting()));
		List<ChapterHit> chapters = best(library.chapters(), q, (ChapterItem c) -> Stream.of(c.title()), ChapterItem::title)
				.map(c -> new ChapterHit(c.id(), c.title(), name(subjectById.get(c.subjectId())), name(levelById.get(c.levelId())),
						documentsPerChapter.getOrDefault(c.id(), 0L).intValue()))
				.toList();
		List<HomeworkHit> given = best(homework.list(), q, a -> Stream.of(a.title()), a -> a.title())
				.map(a -> new HomeworkHit(a.id(), a.title(), a.group(), a.deadlineAt(), a.counts().submitted() + a.counts().late(), a.done()))
				.toList();
		List<EvaluationHit> tests = best(evaluations.list(), q, e -> Stream.of(e.title()), e -> e.title())
				.map(e -> new EvaluationHit(e.id(), e.title(), e.group(), e.heldOn()))
				.toList();
		return new SearchResults(pupils, families, classes, documents, chapters, given, tests);
	}

	/** The matches of [q] in [all]: words starting with it first, then by name; [PER_FAMILY] at most. */
	private static <T> Stream<T> best(List<T> all, String q, Function<T, Stream<String>> fields, Function<T, String> label) {
		return all.stream()
				.map(item -> Map.entry(item, rank(fields.apply(item), q)))
				.filter(e -> e.getValue() < 2)
				.sorted(Comparator.comparing((Map.Entry<T, Integer> e) -> e.getValue()).thenComparing(e -> plain(label.apply(e.getKey()))))
				.limit(PER_FAMILY)
				.map(Map.Entry::getKey);
	}

	/** 0: a word starts with [q]; 1: [q] is inside; 2: not found. */
	private static int rank(Stream<String> fields, String q) {
		int best = 2;
		for (String field : fields.filter(f -> f != null && !f.isBlank()).toList()) {
			String text = plain(field);
			if (text.startsWith(q) || text.contains(" " + q)) {
				return 0;
			}
			if (text.contains(q)) {
				best = 1;
			}
		}
		return best;
	}

	private static LocalizedText name(Subject subject) {
		return subject == null ? null : subject.name();
	}

	private static LocalizedText name(Level level) {
		return level == null ? null : level.name();
	}

	/** Lower case, no accents, single spaces: "Élève" finds "eleve". */
	static String plain(String text) {
		if (text == null) {
			return "";
		}
		return Normalizer.normalize(text, Normalizer.Form.NFD).replaceAll("\\p{M}", "").toLowerCase(Locale.ROOT)
				.replaceAll("[^\\p{L}\\p{N}]+", " ").trim();
	}
}
