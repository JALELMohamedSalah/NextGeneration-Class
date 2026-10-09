package com.ngclass.backend.work.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.content.repository.FileAssetRepository;
import com.ngclass.backend.content.service.FileInspector;
import com.ngclass.backend.content.service.FileInspector.Inspected;
import com.ngclass.backend.content.storage.FileStorage;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.notifications.service.NotificationService;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.work.domain.Assignment;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import com.ngclass.backend.work.domain.HomeworkStatus;
import com.ngclass.backend.work.domain.Submission;
import com.ngclass.backend.work.domain.SubmissionMode;
import com.ngclass.backend.work.dto.HomeworkDtos.CorrectionFile;
import com.ngclass.backend.work.dto.HomeworkDtos.CorrectionRequest;
import com.ngclass.backend.work.dto.HomeworkDtos.CorrectionView;
import com.ngclass.backend.work.dto.HomeworkDtos.MissingWork;
import com.ngclass.backend.work.dto.HomeworkDtos.StudentName;
import com.ngclass.backend.work.dto.HomeworkDtos.SubmissionInfo;
import com.ngclass.backend.work.dto.HomeworkDtos.ToCorrectGroup;
import com.ngclass.backend.work.dto.HomeworkDtos.ToCorrectItem;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.AssignmentRepository;
import com.ngclass.backend.work.repository.SubmissionRepository;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
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
 * Correction (spec 06, release 2 step 4): the "À corriger" queue, a score out of the homework's max score with a
 * comment and an optional corrected copy, seen by the pupil and the parents as soon as it is saved.
 */
@Service
@RequiredArgsConstructor
public class CorrectionService {
	/** "Travail manquant" on Ma journée looks this far back. */
	static final Duration MISSING_WINDOW = Duration.ofDays(14);

	private static final Set<HomeworkStatus> WAITING = Set.of(HomeworkStatus.SUBMITTED, HomeworkStatus.LATE);

	private final AssignmentRepository assignments;
	private final AssignmentRecipientRepository recipients;
	private final SubmissionRepository submissions;
	private final ContentItemRepository items;
	private final StudentRepository students;
	private final FileAssetRepository files;
	private final FileStorage storage;
	private final FileInspector inspector;
	private final NotificationService notifications;
	private final HomeworkService homework;
	private final CurrentTeacher teacher;
	private final Clock clock;

	/** Every copy sent and not corrected yet, grouped by homework; the oldest copy first, in each and overall. */
	@Transactional(readOnly = true)
	public List<ToCorrectGroup> queue() {
		Instant now = clock.instant();
		Lists lists = lists(assignments.findByTeacherIdOrderByDeadlineAtAsc(teacher.id()));
		List<AssignmentRecipient> waiting = lists.rows().values().stream().flatMap(List::stream).filter(r -> WAITING.contains(r.getStatus())).toList();
		if (waiting.isEmpty()) {
			return List.of();
		}
		Map<UUID, Submission> latest = homework.latestSubmissions(waiting);
		Map<UUID, Student> names = studentsOf(waiting);
		List<ToCorrectGroup> out = new ArrayList<>();
		for (Assignment a : lists.assignments()) {
			List<ToCorrectItem> copies = lists.rows().getOrDefault(a.getId(), List.of()).stream()
					.filter(r -> WAITING.contains(r.getStatus()) && latest.containsKey(r.getId()))
					.map(r -> {
						Student s = names.get(r.getStudentId());
						Submission sub = latest.get(r.getId());
						return new ToCorrectItem(r.getStudentId(), s.getUser().getFirstName(), s.getUser().getLastName(), r.getStatus().name(),
								sub.getSubmittedAt(), sub.getId());
					})
					.sorted(Comparator.comparing(ToCorrectItem::submittedAt))
					.toList();
			if (!copies.isEmpty()) {
				out.add(new ToCorrectGroup(lists.item(a, now), copies));
			}
		}
		out.sort(Comparator.comparing(g -> g.items().getFirst().submittedAt()));
		return out;
	}

	/** Homework past its deadline in the last two weeks, newest first, with the pupils who sent nothing. */
	@Transactional(readOnly = true)
	public List<MissingWork> missing() {
		Instant now = clock.instant();
		Instant since = now.minus(MISSING_WINDOW);
		List<Assignment> past = assignments.findByTeacherIdOrderByDeadlineAtAsc(teacher.id()).stream()
				.filter(a -> !a.getDeadlineAt().isAfter(now) && a.getDeadlineAt().isAfter(since))
				.toList();
		Lists lists = lists(past);
		List<AssignmentRecipient> absent = lists.rows().values().stream().flatMap(List::stream)
				.filter(r -> r.statusAt(lists.byId().get(r.getAssignmentId()), now) == HomeworkStatus.MISSING)
				.toList();
		if (absent.isEmpty()) {
			return List.of();
		}
		Map<UUID, Student> names = studentsOf(absent);
		List<MissingWork> out = new ArrayList<>();
		for (Assignment a : lists.assignments().reversed()) {
			List<StudentName> missing = absent.stream()
					.filter(r -> r.getAssignmentId().equals(a.getId()))
					.map(r -> names.get(r.getStudentId()))
					.map(s -> new StudentName(s.getId(), s.getUser().getFirstName(), s.getUser().getLastName()))
					.sorted(Comparator.comparing(StudentName::lastName, String.CASE_INSENSITIVE_ORDER))
					.toList();
			if (!missing.isEmpty()) {
				out.add(new MissingWork(lists.item(a, now), missing));
			}
		}
		return out;
	}

	@Transactional(readOnly = true)
	public CorrectionView view(UUID assignmentId, UUID studentId) {
		Assignment assignment = homework.own(assignmentId);
		return view(assignment, recipientOf(assignment, studentId));
	}

	/** Saves the score and comment; the first time, the pupil and the parents are told. Saving again changes them. */
	@Transactional
	public CorrectionView correct(UUID assignmentId, UUID studentId, CorrectionRequest request) {
		Assignment assignment = homework.own(assignmentId);
		AssignmentRecipient recipient = correctable(assignment, studentId);
		Instant now = clock.instant();
		boolean first = recipient.getStatus() != HomeworkStatus.CORRECTED;
		recipient.setScore(Grades.checked(request.score(), assignment.getMaxScore()));
		recipient.setComment(request.comment() == null || request.comment().isBlank() ? null : request.comment().trim());
		recipient.setCorrectedAt(now);
		recipient.setStatus(HomeworkStatus.CORRECTED);
		recipient.setStatusChangedAt(now);
		recipients.saveAndFlush(recipient);
		if (first) {
			ClassGroup group = homework.groupsOf(List.of(assignment)).get(assignment.getGroupId());
			notifications.homeworkCorrected(group, studentId, assignment.getId(), assignment.getTitle(), assignment.getDeadlineAt());
		}
		return view(assignment, recipient);
	}

	/** The teacher's corrected copy (a photo or a PDF), replacing the one before; the pupil sees it once corrected. */
	@Transactional
	public CorrectionView attach(UUID assignmentId, UUID studentId, byte[] data, String fileName) {
		Assignment assignment = homework.own(assignmentId);
		AssignmentRecipient recipient = correctable(assignment, studentId);
		Inspected inspected = inspector.inspectWork(data, fileName);
		recipient.setCorrectionFile(files.save(FileAsset.builder()
				.teacherId(assignment.getTeacherId())
				.storageKey(storage.save(data))
				.mimeType(inspected.mimeType())
				.sizeBytes(data.length)
				.originalName(fileName == null || fileName.isBlank() ? "correction.pdf" : fileName.trim())
				.pageCount(inspected.pageCount())
				.build()));
		recipients.saveAndFlush(recipient);
		return view(assignment, recipient);
	}

	@Transactional
	public CorrectionView detach(UUID assignmentId, UUID studentId) {
		Assignment assignment = homework.own(assignmentId);
		AssignmentRecipient recipient = recipientOf(assignment, studentId);
		recipient.setCorrectionFile(null);
		recipients.saveAndFlush(recipient);
		return view(assignment, recipient);
	}

	@Transactional(readOnly = true)
	public ContentViewResponse fileView(UUID assignmentId, UUID studentId) {
		Assignment assignment = homework.own(assignmentId);
		AssignmentRecipient recipient = recipientOf(assignment, studentId);
		if (recipient.getCorrectionFile() == null) {
			throw ApiException.notFound("correction_not_found");
		}
		Student student = students.findById(studentId).orElseThrow();
		return homework.correctionView(recipient, assignment, student.getUser().getFirstName() + " " + student.getUser().getLastName());
	}

	// ── Shared with the pupil's side ──

	static CorrectionFile fileOf(AssignmentRecipient recipient) {
		FileAsset file = recipient.getCorrectionFile();
		return file == null ? null : new CorrectionFile(file.getOriginalName(), file.kind().name(), file.getPageCount());
	}

	// ── Private ──

	/** Something to send, and sent or past its deadline: a pupil with nothing yet before the deadline waits. */
	private AssignmentRecipient correctable(Assignment assignment, UUID studentId) {
		if (assignment.getSubmissionMode() == SubmissionMode.NONE) {
			throw ApiException.badRequest("nothing_to_submit");
		}
		AssignmentRecipient recipient = recipientOf(assignment, studentId);
		if (recipient.statusAt(assignment, clock.instant()) == HomeworkStatus.TODO) {
			throw new ApiException(HttpStatus.CONFLICT, "not_submitted_yet");
		}
		return recipient;
	}

	private AssignmentRecipient recipientOf(Assignment assignment, UUID studentId) {
		return recipients.findByAssignmentIdAndStudentId(assignment.getId(), studentId)
				.orElseThrow(() -> ApiException.notFound("student_not_found"));
	}

	private CorrectionView view(Assignment assignment, AssignmentRecipient recipient) {
		Student student = students.findById(recipient.getStudentId()).orElseThrow();
		Submission submission = submissions.findFirstByRecipientIdOrderBySubmittedAtDesc(recipient.getId()).orElse(null);
		return new CorrectionView(
				assignment.getId(),
				student.getId(),
				student.getUser().getFirstName(),
				student.getUser().getLastName(),
				HomeworkService.status(recipient, assignment, clock.instant()),
				assignment.getMaxScore(),
				submission == null ? null : new SubmissionInfo(submission.getId(), submission.getSubmittedAt(), submission.isLate(),
						submission.getFile().getOriginalName(), submission.getFile().getPageCount()),
				recipient.getStatus() == HomeworkStatus.CORRECTED ? recipient.getScore() : null,
				recipient.getComment(),
				recipient.getCorrectedAt(),
				fileOf(recipient));
	}

	private Map<UUID, Student> studentsOf(List<AssignmentRecipient> rows) {
		return students.findByIdIn(rows.stream().map(AssignmentRecipient::getStudentId).distinct().toList()).stream()
				.collect(Collectors.toMap(Student::getId, Function.identity()));
	}

	/** Homework with its pupils, groups and documents, read once. */
	private record Lists(List<Assignment> assignments, Map<UUID, Assignment> byId, Map<UUID, List<AssignmentRecipient>> rows,
			Map<UUID, ClassGroup> groups, Map<UUID, ContentItem> items) {
		com.ngclass.backend.work.dto.HomeworkDtos.AssignmentItem item(Assignment a, Instant now) {
			return HomeworkService.item(a, groups.get(a.getGroupId()), items.get(a.getContentItemId()), rows.getOrDefault(a.getId(), List.of()), now);
		}
	}

	private Lists lists(List<Assignment> list) {
		List<Assignment> withWork = list.stream().filter(a -> a.getSubmissionMode() == SubmissionMode.FILE).toList();
		if (withWork.isEmpty()) {
			return new Lists(List.of(), Map.of(), Map.of(), Map.of(), Map.of());
		}
		Map<UUID, List<AssignmentRecipient>> rows = recipients.findByAssignmentIdIn(withWork.stream().map(Assignment::getId).toList()).stream()
				.collect(Collectors.groupingBy(AssignmentRecipient::getAssignmentId));
		Map<UUID, ContentItem> itemById = items.findAllById(withWork.stream().map(Assignment::getContentItemId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ContentItem::getId, Function.identity()));
		return new Lists(withWork, withWork.stream().collect(Collectors.toMap(Assignment::getId, Function.identity())), rows,
				homework.groupsOf(withWork), itemById);
	}
}
