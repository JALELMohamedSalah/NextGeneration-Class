package com.ngclass.backend.work.service;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.dto.ContentDtos.SubjectRef;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.service.FamilyAccess;
import com.ngclass.backend.people.service.StudentService;
import com.ngclass.backend.planning.domain.AttendanceStatus;
import com.ngclass.backend.planning.repository.AttendanceRepository;
import com.ngclass.backend.planning.service.AttendanceStats.Summary;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.work.domain.Assignment;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import com.ngclass.backend.work.domain.HomeworkStatus;
import com.ngclass.backend.work.domain.Submission;
import com.ngclass.backend.work.domain.SubmissionMode;
import com.ngclass.backend.work.dto.ResultsDtos.GradeItem;
import com.ngclass.backend.work.dto.ResultsDtos.MyResults;
import com.ngclass.backend.work.dto.ResultsDtos.SubjectResult;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.AssignmentRepository;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.work.domain.Evaluation;
import com.ngclass.backend.work.domain.EvaluationGrade;
import com.ngclass.backend.work.repository.EvaluationGradeRepository;
import com.ngclass.backend.work.repository.EvaluationRepository;
import java.util.ArrayList;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * "Résultats" (spec 07 and 09): per subject the average on /20, the trend, homework sent out of homework due,
 * attendance, and each grade with the teacher's comment. A pupil sees their own, a parent each child's.
 */
@Service
@RequiredArgsConstructor
public class ResultsService {
	private final FamilyAccess family;
	private final StudentService students;
	private final AssignmentRecipientRepository recipients;
	private final AssignmentRepository assignments;
	private final ContentItemRepository items;
	private final SubjectRepository subjects;
	private final GroupMemberRepository members;
	private final ClassGroupRepository groups;
	private final AttendanceRepository attendance;
	private final HomeworkService homework;
	private final EvaluationRepository evaluations;
	private final EvaluationGradeRepository evaluationGrades;
	private final AppProperties properties;
	private final Clock clock;

	@Transactional(readOnly = true)
	public MyResults of(AuthenticatedUser user, UUID studentId) {
		Student child = family.child(user, studentId);
		return results(child.getId());
	}

	/** One of the teacher's pupils (the Fiche élève): the same numbers the pupil and the parents see. */
	@Transactional(readOnly = true)
	public MyResults forTeacher(UUID studentId) {
		return results(students.require(studentId).getId());
	}

	MyResults results(UUID studentId) {
		Instant now = clock.instant();
		List<AssignmentRecipient> rows = recipients.findByStudentIdIn(List.of(studentId));
		Map<UUID, Assignment> byId = rows.isEmpty() ? Map.of() : assignments.findByIdIn(rows.stream().map(AssignmentRecipient::getAssignmentId).toList()).stream()
				.collect(Collectors.toMap(Assignment::getId, Function.identity()));
		List<AssignmentRecipient> work = rows.stream().filter(r -> byId.get(r.getAssignmentId()).getSubmissionMode() == SubmissionMode.FILE).toList();
		Map<UUID, UUID> subjectOfItem = items.findAllById(work.stream().map(r -> byId.get(r.getAssignmentId()).getContentItemId()).collect(Collectors.toSet()))
				.stream()
				.collect(Collectors.toMap(ContentItem::getId, ContentItem::getSubjectId));
		Map<UUID, Submission> latest = homework.latestSubmissions(work);

		// The subjects of the child's groups, and any subject with homework.
		Set<UUID> subjectIds = new LinkedHashSet<>();
		List<UUID> groupIds = members.findById_StudentIdAndLeftAtIsNull(studentId).stream().map(m -> m.getId().getGroupId()).toList();
		groups.findByIdIn(groupIds).stream().filter(g -> g.getArchivedAt() == null).map(ClassGroup::getSubject).forEach(s -> subjectIds.add(s.getId()));
		subjectOfItem.values().forEach(subjectIds::add);
		Map<UUID, List<GradeItem>> tests = evaluationGrades(studentId);
		subjectIds.addAll(tests.keySet());
		Map<UUID, Integer> attendanceBySubject = attendanceBySubject(studentId);

		return new MyResults(subjects.findAllById(subjectIds).stream()
				.sorted(Comparator.comparingInt(Subject::getPosition).thenComparing(s -> s.name().fr(), String.CASE_INSENSITIVE_ORDER))
				.map(subject -> {
					List<AssignmentRecipient> mine = work.stream()
							.filter(r -> subject.getId().equals(subjectOfItem.get(byId.get(r.getAssignmentId()).getContentItemId())))
							.toList();
					return result(subject, mine, byId, latest, tests.getOrDefault(subject.getId(), List.of()), attendanceBySubject.get(subject.getId()), now);
				})
				.toList());
	}

	private static SubjectResult result(Subject subject, List<AssignmentRecipient> rows, Map<UUID, Assignment> byId, Map<UUID, Submission> latest,
			List<GradeItem> tests, Integer attendanceRate, Instant now) {
		List<GradeItem> grades = java.util.stream.Stream.concat(
						rows.stream()
								.filter(r -> r.getStatus() == HomeworkStatus.CORRECTED && r.getScore() != null)
								.map(r -> {
									Assignment a = byId.get(r.getAssignmentId());
									return new GradeItem("HOMEWORK", a.getId(), null, a.getTitle(), r.getCorrectedAt(), r.getScore(), a.getMaxScore(),
											Grades.on20(r.getScore(), a.getMaxScore()), r.getComment(), false);
								}),
						tests.stream())
				.sorted(Comparator.comparing(GradeItem::date).reversed())
				.toList();
		// An absent pupil has no grade: never counted as 0 (spec 07).
		List<BigDecimal> chronological = grades.reversed().stream().filter(g -> !g.absent()).map(GradeItem::score20).toList();
		// Due: past the deadline, or already sent. Sent: on time, late, or corrected with a copy (business rules 6).
		int due = 0;
		int submitted = 0;
		for (AssignmentRecipient r : rows) {
			Assignment a = byId.get(r.getAssignmentId());
			boolean sent = r.getStatus() == HomeworkStatus.SUBMITTED || r.getStatus() == HomeworkStatus.LATE
					|| (r.getStatus() == HomeworkStatus.CORRECTED && latest.containsKey(r.getId()));
			if (sent || !a.getDeadlineAt().isAfter(now) || r.getStatus() == HomeworkStatus.CORRECTED) {
				due++;
			}
			if (sent) {
				submitted++;
			}
		}
		return new SubjectResult(
				new SubjectRef(subject.getId(), subject.name(), subject.getColor(), subject.getPosition()),
				Grades.average(chronological),
				chronological.size(),
				Grades.trend(chronological),
				submitted,
				due,
				attendanceRate,
				grades);
	}

	/** The pupil's paper evaluations, by the subject of their group: a score on /20, or absent. */
	private Map<UUID, List<GradeItem>> evaluationGrades(UUID studentId) {
		List<EvaluationGrade> mine = evaluationGrades.findById_StudentId(studentId);
		if (mine.isEmpty()) {
			return Map.of();
		}
		Map<UUID, Evaluation> byId = evaluations.findAllById(mine.stream().map(g -> g.getId().getEvaluationId()).toList()).stream()
				.collect(Collectors.toMap(Evaluation::getId, Function.identity()));
		Map<UUID, UUID> subjectOfGroup = groups.findByIdIn(byId.values().stream().map(Evaluation::getGroupId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ClassGroup::getId, g -> g.getSubject().getId()));
		Map<UUID, List<GradeItem>> out = new HashMap<>();
		for (EvaluationGrade g : mine) {
			Evaluation e = byId.get(g.getId().getEvaluationId());
			if (e == null || (g.getScore() == null && !g.isAbsent())) {
				continue;
			}
			Instant day = e.getHeldOn().atStartOfDay(properties.zoneId()).toInstant();
			GradeItem item = new GradeItem("EVALUATION", null, e.getId(), e.getTitle(), day, g.getScore(), e.getMaxScore(),
					g.getScore() == null ? null : Grades.on20(g.getScore(), e.getMaxScore()), g.getComment(), g.isAbsent());
			out.computeIfAbsent(subjectOfGroup.get(e.getGroupId()), k -> new ArrayList<>()).add(item);
		}
		return out;
	}

	private Map<UUID, Integer> attendanceBySubject(UUID studentId) {
		Map<UUID, int[]> counts = new HashMap<>();
		for (Object[] row : attendance.countBySubject(studentId)) {
			counts.computeIfAbsent((UUID) row[0], id -> new int[3])[((AttendanceStatus) row[1]).ordinal()] = ((Number) row[2]).intValue();
		}
		Map<UUID, Integer> rates = new HashMap<>();
		counts.forEach((subjectId, c) -> rates.put(subjectId, new Summary(c[0], c[1], c[2]).rate()));
		return rates;
	}
}
