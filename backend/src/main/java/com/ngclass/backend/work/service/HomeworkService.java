package com.ngclass.backend.work.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.ContentStatus;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.domain.FileKind;
import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.content.service.ContentService;
import com.ngclass.backend.content.service.FileLinks;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.notifications.service.NotificationService;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.planning.service.PlanningService;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.work.domain.Assignment;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import com.ngclass.backend.work.domain.HomeworkStatus;
import com.ngclass.backend.work.domain.Submission;
import com.ngclass.backend.work.domain.SubmissionMode;
import com.ngclass.backend.work.dto.HomeworkDtos.AssignRequest;
import com.ngclass.backend.work.dto.HomeworkDtos.AssignmentDetail;
import com.ngclass.backend.work.dto.HomeworkDtos.AssignmentItem;
import com.ngclass.backend.work.dto.HomeworkDtos.RecipientRow;
import com.ngclass.backend.work.dto.HomeworkDtos.StatusCounts;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.AssignmentRepository;
import com.ngclass.backend.work.repository.SubmissionRepository;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.Objects;
import java.util.function.Function;
import java.util.function.IntFunction;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Homework for the teacher (spec 06): give it, follow who sent what, move the deadline, close it. */
@Service
@RequiredArgsConstructor
public class HomeworkService {
	private final AssignmentRepository assignments;
	private final AssignmentRecipientRepository recipients;
	private final SubmissionRepository submissions;
	private final ContentService contents;
	private final ContentItemRepository items;
	private final GroupService groupService;
	private final ClassGroupRepository groups;
	private final GroupMemberRepository members;
	private final StudentRepository students;
	private final SubjectRepository subjects;
	private final NotificationService notifications;
	private final FileLinks links;
	private final CurrentTeacher teacher;
	private final Clock clock;

	/** Every homework of the teacher with its counts; the app splits "En cours" and "Terminés" on [done]. */
	@Transactional(readOnly = true)
	public List<AssignmentItem> list() {
		List<Assignment> all = assignments.findByTeacherIdOrderByDeadlineAtAsc(teacher.id());
		if (all.isEmpty()) {
			return List.of();
		}
		Map<UUID, List<AssignmentRecipient>> byAssignment = recipients.findByAssignmentIdIn(all.stream().map(Assignment::getId).toList()).stream()
				.collect(Collectors.groupingBy(AssignmentRecipient::getAssignmentId));
		Map<UUID, ClassGroup> groupById = groupsOf(all);
		Map<UUID, ContentItem> itemById = items.findAllById(all.stream().map(Assignment::getContentItemId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ContentItem::getId, Function.identity()));
		Instant now = clock.instant();
		return all.stream()
				.map(a -> item(a, groupById.get(a.getGroupId()), itemById.get(a.getContentItemId()), byAssignment.getOrDefault(a.getId(), List.of()), now))
				.toList();
	}

	@Transactional
	public AssignmentItem create(AssignRequest request) {
		UUID me = teacher.id();
		ContentItem item = contents.own(request.contentItemId());
		if (item.getStatus() != ContentStatus.PUBLISHED) {
			throw new ApiException(HttpStatus.CONFLICT, "content_not_published");
		}
		ClassGroup group = groupService.require(request.groupId());
		SubmissionMode mode = mode(request.submissionMode());
		Instant now = clock.instant();
		if (!request.deadlineAt().isAfter(now)) {
			throw ApiException.badRequest("deadline_past");
		}
		Set<UUID> memberIds = members.findById_GroupIdAndLeftAtIsNull(group.getId()).stream()
				.map(m -> m.getId().getStudentId())
				.collect(Collectors.toCollection(LinkedHashSet::new));
		boolean wholeGroup = request.studentIds() == null || request.studentIds().isEmpty();
		Set<UUID> chosen = wholeGroup ? memberIds : new LinkedHashSet<>(request.studentIds());
		if (!memberIds.containsAll(chosen)) {
			throw ApiException.badRequest("not_group_member");
		}
		Assignment assignment = assignments.saveAndFlush(Assignment.builder()
				.teacherId(me)
				.contentItemId(item.getId())
				.groupId(group.getId())
				.title(request.title().trim())
				.instructions(request.instructions() == null || request.instructions().isBlank() ? null : request.instructions().trim())
				.deadlineAt(request.deadlineAt())
				.maxScore(request.maxScore() == null ? 20 : request.maxScore())
				.submissionMode(mode)
				.allowLate(request.allowLate())
				.wholeGroup(wholeGroup)
				.build());
		List<AssignmentRecipient> rows = recipients.saveAll(chosen.stream()
				.map(studentId -> AssignmentRecipient.builder()
						.assignmentId(assignment.getId())
						.studentId(studentId)
						.status(HomeworkStatus.TODO)
						.statusChangedAt(now)
						.build())
				.toList());
		notifications.homeworkAssigned(group, chosen, assignment.getId(), assignment.getTitle(), assignment.getDeadlineAt());
		return item(assignment, group, item, rows, now);
	}

	@Transactional(readOnly = true)
	public AssignmentDetail detail(UUID id) {
		Assignment assignment = own(id);
		List<AssignmentRecipient> rows = recipients.findByAssignmentId(id);
		Map<UUID, Student> studentById = students.findByIdIn(rows.stream().map(AssignmentRecipient::getStudentId).toList()).stream()
				.collect(Collectors.toMap(Student::getId, Function.identity()));
		Map<UUID, Submission> latest = latestSubmissions(rows);
		Instant now = clock.instant();
		List<RecipientRow> out = rows.stream()
				.map(r -> {
					Student s = studentById.get(r.getStudentId());
					Submission sub = latest.get(r.getId());
					return new RecipientRow(
							r.getStudentId(),
							s.getUser().getFirstName(),
							s.getUser().getLastName(),
							status(r, assignment, now),
							sub == null ? null : sub.getSubmittedAt(),
							sub == null ? null : sub.getId(),
							r.getStatus() == HomeworkStatus.CORRECTED ? r.getScore() : null);
				})
				.sorted(Comparator.comparing(RecipientRow::lastName, String.CASE_INSENSITIVE_ORDER).thenComparing(RecipientRow::firstName, String.CASE_INSENSITIVE_ORDER))
				.toList();
		ClassGroup group = groups.findById(assignment.getGroupId()).orElseThrow();
		ContentItem item = items.findById(assignment.getContentItemId()).orElse(null);
		return new AssignmentDetail(item(assignment, group, item, rows, now), out);
	}

	/** A later deadline gives their chance back to pupils marked "Manquant". */
	@Transactional
	public AssignmentItem changeDeadline(UUID id, Instant deadline) {
		Assignment assignment = own(id);
		Instant now = clock.instant();
		if (!deadline.isAfter(now)) {
			throw ApiException.badRequest("deadline_past");
		}
		assignment.setDeadlineAt(deadline);
		assignment.setDeadlineNotifiedAt(null);
		recipients.reopenMissing(id, now);
		return detail(id).assignment();
	}

	/** Nothing more can be sent; what was sent stays. */
	@Transactional
	public void close(UUID id) {
		Assignment assignment = own(id);
		if (assignment.getClosedAt() == null) {
			assignment.setClosedAt(clock.instant());
		}
	}

	/** A pupil's work, page by page, through signed links. */
	@Transactional(readOnly = true)
	public ContentViewResponse submissionView(UUID submissionId) {
		Submission submission = submissions.findById(submissionId).orElseThrow(() -> ApiException.notFound("submission_not_found"));
		AssignmentRecipient recipient = recipients.findById(submission.getRecipientId()).orElseThrow();
		Assignment assignment = assignments.findByIdAndTeacherId(recipient.getAssignmentId(), teacher.id())
				.orElseThrow(() -> ApiException.notFound("submission_not_found"));
		Student student = students.findById(recipient.getStudentId()).orElseThrow();
		return view(submission, assignment, student.getUser().getFirstName() + " " + student.getUser().getLastName());
	}

	// ── Shared with the pupil's side ──

	ContentViewResponse view(Submission submission, Assignment assignment, String who) {
		return fileView(submission.getId(), submission.getFile(), assignment, who,
				page -> links.submissionLink(submission.getId(), page));
	}

	/** The teacher's corrected copy of one pupil, through its own signed links. */
	ContentViewResponse correctionView(AssignmentRecipient recipient, Assignment assignment, String who) {
		return fileView(recipient.getId(), recipient.getCorrectionFile(), assignment, who,
				page -> links.correctionLink(recipient.getId(), page));
	}

	private ContentViewResponse fileView(UUID id, FileAsset file, Assignment assignment, String who, IntFunction<String> link) {
		ContentItem item = items.findById(assignment.getContentItemId()).orElseThrow();
		Subject subject = subjects.findById(item.getSubjectId()).orElseThrow();
		int pages = switch (file.kind()) {
			case PDF -> file.getPageCount() == null ? 0 : file.getPageCount();
			case IMAGE -> 1;
			case WORD -> 0;
		};
		return new ContentViewResponse(
				id,
				who + " · " + assignment.getTitle(),
				subject.name(),
				null,
				file.kind().name(),
				"AUTRE",
				file.getPageCount(),
				file.getOriginalName(),
				file.getSizeBytes(),
				IntStream.rangeClosed(1, pages).mapToObj(link).toList(),
				link.apply(0));
	}

	static String status(AssignmentRecipient r, Assignment a, Instant now) {
		return a.getSubmissionMode() == SubmissionMode.NONE ? null : r.statusAt(a, now).name();
	}

	Map<UUID, Submission> latestSubmissions(List<AssignmentRecipient> rows) {
		if (rows.isEmpty()) {
			return Map.of();
		}
		Map<UUID, Submission> latest = new HashMap<>();
		for (Submission s : submissions.findByRecipientIdInOrderBySubmittedAtDesc(rows.stream().map(AssignmentRecipient::getId).toList())) {
			latest.putIfAbsent(s.getRecipientId(), s);
		}
		return latest;
	}

	Assignment own(UUID id) {
		return assignments.findByIdAndTeacherId(id, teacher.id()).orElseThrow(() -> ApiException.notFound("assignment_not_found"));
	}

	Map<UUID, ClassGroup> groupsOf(List<Assignment> list) {
		return groups.findByIdIn(list.stream().map(Assignment::getGroupId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ClassGroup::getId, Function.identity()));
	}

	private static SubmissionMode mode(String value) {
		try {
			return SubmissionMode.valueOf(value.trim().toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException e) {
			throw ApiException.badRequest("invalid_submission_mode");
		}
	}

	static AssignmentItem item(Assignment a, ClassGroup group, ContentItem item, List<AssignmentRecipient> rows, Instant now) {
		int[] counts = new int[HomeworkStatus.values().length];
		for (AssignmentRecipient r : rows) {
			counts[r.statusAt(a, now).ordinal()]++;
		}
		List<BigDecimal> scores = rows.stream()
				.filter(r -> r.getStatus() == HomeworkStatus.CORRECTED)
				.map(AssignmentRecipient::getScore)
				.filter(Objects::nonNull)
				.map(score -> Grades.on20(score, a.getMaxScore()))
				.toList();
		return new AssignmentItem(
				a.getId(),
				a.getTitle(),
				a.getContentItemId(),
				item == null ? FileKind.PDF.name() : item.getFile().kind().name(),
				PlanningService.ref(group),
				a.isWholeGroup(),
				a.getDeadlineAt(),
				a.getSubmissionMode().name(),
				a.isAllowLate(),
				a.getInstructions(),
				a.getMaxScore(),
				a.getClosedAt() != null,
				a.isDone(now),
				rows.size(),
				new StatusCounts(
						counts[HomeworkStatus.TODO.ordinal()],
						counts[HomeworkStatus.SUBMITTED.ordinal()],
						counts[HomeworkStatus.LATE.ordinal()],
						counts[HomeworkStatus.MISSING.ordinal()],
						counts[HomeworkStatus.CORRECTED.ordinal()]),
				a.getCreatedAt(),
				item == null ? null : item.getSubjectId(),
				Grades.average(scores));
	}
}
