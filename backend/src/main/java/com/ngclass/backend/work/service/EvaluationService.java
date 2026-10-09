package com.ngclass.backend.work.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.Chapter;
import com.ngclass.backend.content.repository.ChapterRepository;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.notifications.service.NotificationService;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.planning.service.PlanningService;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.work.domain.Evaluation;
import com.ngclass.backend.work.domain.EvaluationGrade;
import com.ngclass.backend.work.dto.EvaluationDtos.ChapterRef;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationDetail;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationItem;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationRequest;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationUpdate;
import com.ngclass.backend.work.dto.EvaluationDtos.GradeInput;
import com.ngclass.backend.work.dto.EvaluationDtos.GradeRow;
import com.ngclass.backend.work.repository.EvaluationGradeRepository;
import com.ngclass.backend.work.repository.EvaluationRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Paper evaluations (spec 06 "Évaluations", design `r2/Evaluation.png`): created for one of the teacher's groups,
 * the scores typed in one table. A grade counts in Résultats like a corrected homework; an absent pupil never as 0.
 */
@Service
@RequiredArgsConstructor
public class EvaluationService {
	private final EvaluationRepository evaluations;
	private final EvaluationGradeRepository grades;
	private final ClassGroupRepository groups;
	private final GroupMemberRepository members;
	private final StudentRepository students;
	private final ChapterRepository chapters;
	private final GroupService groupService;
	private final NotificationService notifications;
	private final CurrentTeacher teacher;
	private final AppProperties properties;
	private final Clock clock;

	/** The "Évaluations" tab: latest first. */
	@Transactional(readOnly = true)
	public List<EvaluationItem> list() {
		List<Evaluation> all = evaluations.findByTeacherIdOrderByHeldOnDescCreatedAtDesc(teacher.id());
		if (all.isEmpty()) {
			return List.of();
		}
		Map<UUID, List<EvaluationGrade>> byEvaluation = grades.findById_EvaluationIdIn(all.stream().map(Evaluation::getId).toList()).stream()
				.collect(Collectors.groupingBy(g -> g.getId().getEvaluationId()));
		Map<UUID, ClassGroup> groupById = groupsOf(all);
		Map<UUID, Chapter> chapterById = chaptersOf(all);
		return all.stream()
				.map(e -> item(e, groupById.get(e.getGroupId()), chapterById.get(e.getChapterId()), byEvaluation.getOrDefault(e.getId(), List.of()),
						memberIds(e.getGroupId())))
				.toList();
	}

	@Transactional
	public EvaluationDetail create(EvaluationRequest request) {
		ClassGroup group = groupService.require(request.groupId());
		Evaluation evaluation = evaluations.save(Evaluation.builder()
				.teacherId(group.getTeacherId())
				.groupId(group.getId())
				.title(request.title().trim())
				.heldOn(request.heldOn())
				.maxScore(request.maxScore())
				.chapterId(chapter(request.chapterId()))
				.build());
		return detail(evaluation);
	}

	@Transactional(readOnly = true)
	public EvaluationDetail detail(UUID id) {
		return detail(own(id));
	}

	/** "Modifier": title, date, scale and chapter. A smaller scale than a typed score is refused. */
	@Transactional
	public EvaluationDetail update(UUID id, EvaluationUpdate update) {
		Evaluation evaluation = own(id);
		BigDecimal max = BigDecimal.valueOf(update.maxScore());
		boolean tooHigh = grades.findById_EvaluationId(id).stream().anyMatch(g -> g.getScore() != null && g.getScore().compareTo(max) > 0);
		if (tooHigh) {
			throw ApiException.badRequest("scale_below_scores", update.maxScore());
		}
		evaluation.setTitle(update.title().trim());
		evaluation.setHeldOn(update.heldOn());
		evaluation.setMaxScore(update.maxScore());
		evaluation.setChapterId(chapter(update.chapterId()));
		return detail(evaluation);
	}

	/**
	 * The score table, saved whole: a score (half points, up to the scale), absent, or nothing (a typed score
	 * erased). Pupils who get their first score are told, with their parents ("Nouvelle note").
	 */
	@Transactional
	public EvaluationDetail saveGrades(UUID id, List<GradeInput> inputs) {
		Evaluation evaluation = own(id);
		Map<UUID, EvaluationGrade> existing = grades.findById_EvaluationId(id).stream()
				.collect(Collectors.toMap(g -> g.getId().getStudentId(), Function.identity()));
		Set<UUID> allowed = new HashSet<>(memberIds(evaluation.getGroupId()));
		allowed.addAll(existing.keySet());
		Instant now = clock.instant();
		List<UUID> newlyGraded = new ArrayList<>();
		for (GradeInput input : inputs) {
			if (!allowed.contains(input.studentId())) {
				throw ApiException.notFound("student_not_found");
			}
			EvaluationGrade grade = existing.get(input.studentId());
			String comment = input.comment() == null || input.comment().isBlank() ? null : input.comment().trim();
			if (!input.absent() && input.score() == null && comment == null) {
				if (grade != null) {
					grades.delete(grade);
				}
				continue;
			}
			BigDecimal score = input.absent() || input.score() == null ? null : Grades.checked(input.score(), evaluation.getMaxScore());
			if (grade == null) {
				grade = EvaluationGrade.builder().id(new EvaluationGrade.Key(id, input.studentId())).build();
			}
			if (score != null && grade.getScore() == null) {
				newlyGraded.add(input.studentId());
			}
			grade.setScore(score);
			grade.setAbsent(input.absent());
			grade.setComment(comment);
			grade.setGradedAt(now);
			grades.save(grade);
		}
		grades.flush();
		if (!newlyGraded.isEmpty()) {
			ClassGroup group = groups.findById(evaluation.getGroupId()).orElseThrow();
			Instant heldOn = evaluation.getHeldOn().atStartOfDay(properties.zoneId()).toInstant();
			notifications.evaluationGraded(group, newlyGraded, evaluation.getId(), evaluation.getTitle(), heldOn);
		}
		return detail(evaluation);
	}

	// ── Helpers ──

	private Evaluation own(UUID id) {
		return evaluations.findByIdAndTeacherId(id, teacher.id()).orElseThrow(() -> ApiException.notFound("evaluation_not_found"));
	}

	private UUID chapter(UUID chapterId) {
		if (chapterId == null) {
			return null;
		}
		return chapters.findByIdAndTeacherId(chapterId, teacher.id())
				.map(Chapter::getId)
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "chapter_not_found"));
	}

	private EvaluationDetail detail(Evaluation evaluation) {
		ClassGroup group = groups.findById(evaluation.getGroupId()).orElseThrow();
		Chapter chapter = evaluation.getChapterId() == null ? null : chapters.findById(evaluation.getChapterId()).orElse(null);
		List<EvaluationGrade> typed = grades.findById_EvaluationId(evaluation.getId());
		List<UUID> current = memberIds(evaluation.getGroupId());
		Map<UUID, EvaluationGrade> byStudent = typed.stream().collect(Collectors.toMap(g -> g.getId().getStudentId(), Function.identity()));
		// The current members, and anyone already graded who left the group since.
		Set<UUID> ids = new LinkedHashSet<>(current);
		ids.addAll(byStudent.keySet());
		List<GradeRow> rows = students.findByIdIn(ids).stream()
				.filter(s -> s.getArchivedAt() == null || byStudent.containsKey(s.getId()))
				.sorted(Comparator.comparing((Student s) -> s.getUser().getFirstName().toLowerCase(Locale.ROOT))
						.thenComparing(s -> s.getUser().getLastName().toLowerCase(Locale.ROOT)))
				.map(s -> {
					EvaluationGrade g = byStudent.get(s.getId());
					return new GradeRow(s.getId(), s.getUser().getFirstName(), s.getUser().getLastName(),
							g == null ? null : g.getScore(), g != null && g.isAbsent(), g == null ? null : g.getComment());
				})
				.toList();
		return new EvaluationDetail(item(evaluation, group, chapter, typed, current), rows);
	}

	private static EvaluationItem item(Evaluation e, ClassGroup group, Chapter chapter, List<EvaluationGrade> typed, List<UUID> current) {
		List<BigDecimal> scores = typed.stream().map(EvaluationGrade::getScore).filter(s -> s != null).toList();
		Set<UUID> pupils = new HashSet<>(current);
		typed.forEach(g -> pupils.add(g.getId().getStudentId()));
		BigDecimal average = scores.isEmpty() ? null
				: scores.stream().reduce(BigDecimal.ZERO, BigDecimal::add).divide(BigDecimal.valueOf(scores.size()), 2, RoundingMode.HALF_UP);
		return new EvaluationItem(
				e.getId(),
				e.getTitle(),
				PlanningService.ref(group),
				e.getHeldOn(),
				e.getMaxScore(),
				chapter == null ? null : new ChapterRef(chapter.getId(), chapter.getTitle()),
				pupils.size(),
				scores.size(),
				(int) typed.stream().filter(EvaluationGrade::isAbsent).count(),
				average);
	}

	private List<UUID> memberIds(UUID groupId) {
		return members.findById_GroupIdAndLeftAtIsNull(groupId).stream().map(m -> m.getId().getStudentId()).toList();
	}

	private Map<UUID, ClassGroup> groupsOf(List<Evaluation> all) {
		Map<UUID, ClassGroup> out = new HashMap<>();
		groups.findByIdIn(all.stream().map(Evaluation::getGroupId).collect(Collectors.toSet())).forEach(g -> out.put(g.getId(), g));
		return out;
	}

	private Map<UUID, Chapter> chaptersOf(List<Evaluation> all) {
		Set<UUID> ids = all.stream().map(Evaluation::getChapterId).filter(id -> id != null).collect(Collectors.toSet());
		Map<UUID, Chapter> out = new HashMap<>();
		if (!ids.isEmpty()) {
			chapters.findByIdIn(ids).forEach(c -> out.put(c.getId(), c));
		}
		return out;
	}
}
