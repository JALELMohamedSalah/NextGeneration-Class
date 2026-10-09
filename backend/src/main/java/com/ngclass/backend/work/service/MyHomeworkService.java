package com.ngclass.backend.work.service;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.dto.ContentDtos.SubjectRef;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.content.repository.FileAssetRepository;
import com.ngclass.backend.content.service.FileInspector;
import com.ngclass.backend.content.service.FileInspector.Inspected;
import com.ngclass.backend.content.storage.FileStorage;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.notifications.service.NotificationService;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.service.FamilyAccess;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.work.domain.Assignment;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import com.ngclass.backend.work.domain.HomeworkStatus;
import com.ngclass.backend.work.domain.Submission;
import com.ngclass.backend.work.domain.SubmissionMode;
import com.ngclass.backend.work.dto.HomeworkDtos.ContentRef;
import com.ngclass.backend.work.dto.HomeworkDtos.CorrectionInfo;
import com.ngclass.backend.work.dto.HomeworkDtos.MyHomework;
import com.ngclass.backend.work.dto.HomeworkDtos.MyHomeworkDetail;
import com.ngclass.backend.work.dto.HomeworkDtos.SubmissionInfo;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.AssignmentRepository;
import com.ngclass.backend.work.repository.SubmissionRepository;
import java.time.Clock;
import java.time.Instant;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Homework for a pupil, or a parent for one child (spec 06 and 09; user decision 2026-10-07: a parent may send
 * the work for a child, since most pupils have no login).
 */
@Service
@RequiredArgsConstructor
public class MyHomeworkService {
	private final FamilyAccess family;
	private final AssignmentRepository assignments;
	private final AssignmentRecipientRepository recipients;
	private final SubmissionRepository submissions;
	private final ContentItemRepository items;
	private final SubjectRepository subjects;
	private final ClassGroupRepository groups;
	private final NotificationService notifications;
	private final FileAssetRepository files;
	private final FileStorage storage;
	private final FileInspector inspector;
	private final HomeworkService homework;
	private final Clock clock;

	/** What is to do first (nearest deadline first), then the rest (latest first). */
	@Transactional(readOnly = true)
	public List<MyHomework> mine(AuthenticatedUser user, UUID studentId) {
		Student child = family.child(user, studentId);
		List<AssignmentRecipient> rows = recipients.findByStudentIdIn(List.of(child.getId()));
		if (rows.isEmpty()) {
			return List.of();
		}
		Map<UUID, Assignment> byId = assignments.findByIdIn(rows.stream().map(AssignmentRecipient::getAssignmentId).toList()).stream()
				.collect(Collectors.toMap(Assignment::getId, Function.identity()));
		Map<UUID, Submission> latest = homework.latestSubmissions(rows);
		Instant now = clock.instant();
		Places places = places(byId.values());
		return rows.stream()
				.map(r -> item(byId.get(r.getAssignmentId()), r, latest.get(r.getId()), places, now))
				.sorted(Comparator.comparing((MyHomework h) -> !"TODO".equals(h.status()))
						.thenComparing(h -> "TODO".equals(h.status()) ? h.deadlineAt().toEpochMilli() : -h.deadlineAt().toEpochMilli()))
				.toList();
	}

	@Transactional(readOnly = true)
	public MyHomeworkDetail detail(AuthenticatedUser user, UUID assignmentId, UUID studentId) {
		AssignmentRecipient recipient = recipientOf(user, assignmentId, studentId);
		Assignment assignment = assignments.findById(assignmentId).orElseThrow();
		Submission submission = submissions.findFirstByRecipientIdOrderBySubmittedAtDesc(recipient.getId()).orElse(null);
		Instant now = clock.instant();
		Places places = places(List.of(assignment));
		ContentItem item = places.items().get(assignment.getContentItemId());
		return new MyHomeworkDetail(
				item(assignment, recipient, submission, places, now),
				assignment.getInstructions(),
				new ContentRef(item.getId(), item.getTitle(), item.getFile().kind().name(), item.getTag().name(), item.getFile().getPageCount()),
				submission == null ? null : new SubmissionInfo(
						submission.getId(),
						submission.getSubmittedAt(),
						submission.isLate(),
						submission.getFile().getOriginalName(),
						submission.getFile().getPageCount()),
				canSubmit(assignment, recipient, now),
				recipient.getStatus() == HomeworkStatus.CORRECTED
						? new CorrectionInfo(recipient.getScore(), assignment.getMaxScore(), recipient.getComment(), recipient.getCorrectedAt(),
								CorrectionService.fileOf(recipient))
						: null);
	}

	/** Photos made into one PDF on the device, or a PDF or a photo; it replaces what was sent before. */
	@Transactional
	public MyHomeworkDetail submit(AuthenticatedUser user, UUID assignmentId, UUID studentId, byte[] data, String fileName) {
		AssignmentRecipient recipient = recipientOf(user, assignmentId, studentId);
		Assignment assignment = assignments.findById(assignmentId).orElseThrow();
		Instant now = clock.instant();
		if (assignment.getSubmissionMode() == SubmissionMode.NONE) {
			throw ApiException.badRequest("nothing_to_submit");
		}
		if (assignment.getClosedAt() != null) {
			throw new ApiException(HttpStatus.CONFLICT, "assignment_closed");
		}
		if (recipient.getStatus() == HomeworkStatus.CORRECTED) {
			throw new ApiException(HttpStatus.CONFLICT, "already_corrected");
		}
		boolean late = !assignment.getDeadlineAt().isAfter(now);
		if (late && !assignment.isAllowLate()) {
			throw new ApiException(HttpStatus.CONFLICT, "deadline_passed");
		}
		Inspected inspected = inspector.inspectWork(data, fileName);
		FileAsset asset = files.save(FileAsset.builder()
				.teacherId(assignment.getTeacherId())
				.storageKey(storage.save(data))
				.mimeType(inspected.mimeType())
				.sizeBytes(data.length)
				.originalName(fileName == null || fileName.isBlank() ? "travail.pdf" : fileName.trim())
				.pageCount(inspected.pageCount())
				.build());
		submissions.save(Submission.builder()
				.recipientId(recipient.getId())
				.file(asset)
				.submittedAt(now)
				.late(late)
				.submittedBy(user.id())
				.build());
		recipient.setStatus(late ? HomeworkStatus.LATE : HomeworkStatus.SUBMITTED);
		recipient.setStatusChangedAt(now);
		recipients.saveAndFlush(recipient);
		ClassGroup group = groups.findById(assignment.getGroupId()).orElseThrow();
		notifications.workSubmitted(assignment.getTeacherId(), group, assignment.getId(), assignment.getTitle(), assignment.getDeadlineAt(),
				family.child(user, studentId), late);
		return detail(user, assignmentId, studentId);
	}

	/** The work sent for the child, page by page. */
	@Transactional(readOnly = true)
	public ContentViewResponse submissionView(AuthenticatedUser user, UUID assignmentId, UUID studentId) {
		AssignmentRecipient recipient = recipientOf(user, assignmentId, studentId);
		Assignment assignment = assignments.findById(assignmentId).orElseThrow();
		Submission submission = submissions.findFirstByRecipientIdOrderBySubmittedAtDesc(recipient.getId())
				.orElseThrow(() -> ApiException.notFound("submission_not_found"));
		Student child = family.child(user, studentId);
		return homework.view(submission, assignment, child.getUser().getFirstName());
	}

	/** The teacher's corrected copy, once the homework is corrected. */
	@Transactional(readOnly = true)
	public ContentViewResponse correctionView(AuthenticatedUser user, UUID assignmentId, UUID studentId) {
		AssignmentRecipient recipient = recipientOf(user, assignmentId, studentId);
		if (recipient.getStatus() != HomeworkStatus.CORRECTED || recipient.getCorrectionFile() == null) {
			throw ApiException.notFound("correction_not_found");
		}
		Assignment assignment = assignments.findById(assignmentId).orElseThrow();
		return homework.correctionView(recipient, assignment, family.child(user, studentId).getUser().getFirstName());
	}

	/** Whether one of the user's children has homework on this document: they may open it (spec 06). */
	@Transactional(readOnly = true)
	public boolean assignedToFamily(AuthenticatedUser user, UUID contentItemId) {
		List<UUID> children = family.children(user).stream().map(Student::getId).toList();
		if (children.isEmpty()) {
			return false;
		}
		List<UUID> assignmentIds = recipients.findByStudentIdIn(children).stream().map(AssignmentRecipient::getAssignmentId).toList();
		return !assignmentIds.isEmpty() && assignments.findByIdIn(assignmentIds).stream().anyMatch(a -> a.getContentItemId().equals(contentItemId));
	}

	private AssignmentRecipient recipientOf(AuthenticatedUser user, UUID assignmentId, UUID studentId) {
		Student child = family.child(user, studentId);
		return recipients.findByAssignmentIdAndStudentId(assignmentId, child.getId())
				.orElseThrow(() -> ApiException.notFound("assignment_not_found"));
	}

	private static boolean canSubmit(Assignment a, AssignmentRecipient r, Instant now) {
		return a.getSubmissionMode() == SubmissionMode.FILE
				&& a.getClosedAt() == null
				&& r.getStatus() != HomeworkStatus.CORRECTED
				&& (a.getDeadlineAt().isAfter(now) || a.isAllowLate());
	}

	private record Places(Map<UUID, ContentItem> items, Map<UUID, Subject> subjects, Map<UUID, ClassGroup> groups) {
	}

	private Places places(Collection<Assignment> list) {
		Map<UUID, ContentItem> itemById = items.findAllById(list.stream().map(Assignment::getContentItemId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ContentItem::getId, Function.identity()));
		Map<UUID, Subject> subjectById = subjects.findAllById(itemById.values().stream().map(ContentItem::getSubjectId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(Subject::getId, Function.identity()));
		Map<UUID, ClassGroup> groupById = groups.findByIdIn(list.stream().map(Assignment::getGroupId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ClassGroup::getId, Function.identity()));
		return new Places(itemById, subjectById, groupById);
	}

	private static MyHomework item(Assignment a, AssignmentRecipient r, Submission submission, Places places, Instant now) {
		ContentItem item = places.items().get(a.getContentItemId());
		Subject subject = places.subjects().get(item.getSubjectId());
		return new MyHomework(
				a.getId(),
				a.getTitle(),
				new SubjectRef(subject.getId(), subject.name(), subject.getColor(), subject.getPosition()),
				places.groups().get(a.getGroupId()).getName(),
				a.getDeadlineAt(),
				a.getSubmissionMode().name(),
				a.isAllowLate(),
				a.getClosedAt() != null,
				HomeworkService.status(r, a, now),
				submission == null ? null : submission.getSubmittedAt(),
				r.getStatus() == HomeworkStatus.CORRECTED ? r.getScore() : null,
				a.getMaxScore());
	}
}
