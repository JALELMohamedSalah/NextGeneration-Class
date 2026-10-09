package com.ngclass.backend.notifications.service;

import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.notifications.domain.NamedPupil;
import com.ngclass.backend.notifications.domain.Notification;
import com.ngclass.backend.notifications.domain.NotificationType;
import com.ngclass.backend.notifications.dto.NotificationDtos.NotificationItem;
import com.ngclass.backend.notifications.dto.NotificationDtos.NotificationsPage;
import com.ngclass.backend.notifications.dto.NotificationDtos.UnreadCount;
import com.ngclass.backend.notifications.repository.NotificationRepository;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.planning.domain.ClassSession;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * In-app notifications (docs/02-specification/08-announcements-notifications.md): when the teacher cancels, moves or
 * restores a session, or gives or corrects homework, the parents of the children concerned and the children who have
 * their own login are told. The teacher is not: she made the change. Only sessions still to come are worth a
 * notification. The teacher hears of what the families do: work sent, and each homework's deadline.
 */
@Service
@RequiredArgsConstructor
public class NotificationService {
	/** How far back the app lists notifications: about two months of a school year. */
	static final Duration KEPT = Duration.ofDays(60);

	private final NotificationRepository notifications;
	private final GroupMemberRepository members;
	private final StudentRepository students;
	private final ParentRepository parents;
	private final Clock clock;

	// ── Created by the planning, inside the same transaction as the change ──

	/** One teacher action on [group]: [cancelled] sessions; one notification per person, with how many. */
	public void sessionsCancelled(ClassGroup group, List<ClassSession> cancelled, String reason) {
		List<ClassSession> upcoming = cancelled.stream()
				.filter(s -> s.getStartsAt().isAfter(clock.instant()))
				.sorted(Comparator.comparing(ClassSession::getStartsAt))
				.toList();
		if (upcoming.isEmpty()) {
			return;
		}
		ClassSession first = upcoming.getFirst();
		notifyGroup(group, NotificationType.SESSION_CANCELLED, first.getId(), first.getStartsAt(), null, upcoming.size(), reason);
	}

	/**
	 * A session (or a series from [firstSessionId] on, [count] sessions) now starts at [after] instead of
	 * [before]. Nothing is sent when only the place or the link changed, or when it is all in the past.
	 */
	public void sessionsMoved(ClassGroup group, UUID firstSessionId, Instant before, Instant after, int count) {
		Instant now = clock.instant();
		if (before.equals(after) || (!after.isAfter(now) && !before.isAfter(now))) {
			return;
		}
		notifyGroup(group, NotificationType.SESSION_MOVED, firstSessionId, after, before, Math.max(1, count), null);
	}

	public void sessionRestored(ClassGroup group, ClassSession session) {
		if (session.getStartsAt().isAfter(clock.instant())) {
			notifyGroup(group, NotificationType.SESSION_RESTORED, session.getId(), session.getStartsAt(), null, 1, null);
		}
	}

	/** New homework (spec 06): the pupils it is for and their parents, with its title and deadline. */
	public void homeworkAssigned(ClassGroup group, Collection<UUID> studentIds, UUID assignmentId, String title, Instant deadline) {
		notifyChildren(group, studentIds, NotificationType.HOMEWORK_ASSIGNED, null, deadline, null, 1, null, assignmentId, title, null);
	}

	/** A homework corrected (spec 06): the pupil and their parents, once, when the grade is first saved. */
	public void homeworkCorrected(ClassGroup group, UUID studentId, UUID assignmentId, String title, Instant deadline) {
		notifyChildren(group, List.of(studentId), NotificationType.HOMEWORK_CORRECTED, null, deadline, null, 1, null, assignmentId, title, null);
	}

	/** A paper evaluation's grade, first saved: the pupils and their parents ("Nouvelle note"). */
	public void evaluationGraded(ClassGroup group, Collection<UUID> studentIds, UUID evaluationId, String title, Instant heldOn) {
		notifyChildren(group, studentIds, NotificationType.EVALUATION_GRADED, null, heldOn, null, 1, null, null, title, evaluationId);
	}

	// ── For the teacher ──

	/**
	 * Work sent by [student] or a parent. While the teacher has not read it, one row per homework gathers everyone who
	 * sent ("3 travaux rendus"), in the order they first sent, and moves to the latest work; a pupil who replaces
	 * their work is not counted twice.
	 */
	public void workSubmitted(UUID teacherId, ClassGroup group, UUID assignmentId, String title, Instant deadline, Student student, boolean late) {
		NamedPupil pupil = named(student);
		Notification row = notifications
				.findFirstByUserIdAndTypeAndAssignmentIdAndReadAtIsNull(teacherId, NotificationType.WORK_SUBMITTED, assignmentId)
				.orElse(null);
		if (row == null) {
			Notification created = teacherRow(teacherId, NotificationType.WORK_SUBMITTED, group, assignmentId, title, deadline, List.of(pupil));
			created.setLate(late);
			notifications.save(created);
			return;
		}
		if (row.getPupils().stream().noneMatch(p -> p.id().equals(pupil.id()))) {
			List<NamedPupil> pupils = new ArrayList<>(row.getPupils());
			pupils.add(pupil);
			row.setPupils(pupils);
		}
		row.setLate(row.isLate() || late);
		row.setTitle(title);
		row.setStartsAt(deadline);
		row.setCreatedAt(clock.instant());
	}

	/** A homework's deadline passed: [missing] did not send (empty: everyone did). Once per deadline. */
	public void deadlinePassed(UUID teacherId, ClassGroup group, UUID assignmentId, String title, Instant deadline, List<Student> missing) {
		List<NamedPupil> pupils = missing.stream()
				.map(NotificationService::named)
				.sorted(Comparator.comparing(NamedPupil::lastName, String.CASE_INSENSITIVE_ORDER)
						.thenComparing(NamedPupil::firstName, String.CASE_INSENSITIVE_ORDER))
				.toList();
		notifications.save(teacherRow(teacherId, NotificationType.DEADLINE_PASSED, group, assignmentId, title, deadline, pupils));
	}

	private static NamedPupil named(Student student) {
		return new NamedPupil(student.getId(), student.getUser().getFirstName(), student.getUser().getLastName());
	}

	private static Notification teacherRow(UUID teacherId, NotificationType type, ClassGroup group, UUID assignmentId, String title,
			Instant deadline, List<NamedPupil> pupils) {
		return Notification.builder()
				.userId(teacherId)
				.type(type)
				.groupId(group.getId())
				.groupName(group.getName())
				.startsAt(deadline)
				.assignmentId(assignmentId)
				.title(title)
				.pupils(new ArrayList<>(pupils))
				.build();
	}

	/** Current, non-archived members: each child with an open login, and each active parent once per child. */
	private void notifyGroup(ClassGroup group, NotificationType type, UUID sessionId, Instant startsAt,
			Instant previous, int count, String reason) {
		List<UUID> memberIds = members.findById_GroupIdAndLeftAtIsNull(group.getId()).stream()
				.map(m -> m.getId().getStudentId())
				.toList();
		notifyChildren(group, memberIds, type, sessionId, startsAt, previous, count, reason, null, null, null);
	}

	private void notifyChildren(ClassGroup group, Collection<UUID> studentIds, NotificationType type, UUID sessionId,
			Instant startsAt, Instant previous, int count, String reason, UUID assignmentId, String title, UUID evaluationId) {
		if (studentIds.isEmpty()) {
			return;
		}
		Map<UUID, Student> children = students.findByIdIn(List.copyOf(studentIds)).stream()
				.filter(s -> s.getArchivedAt() == null)
				.collect(Collectors.toMap(Student::getId, Function.identity()));
		List<Notification> rows = new ArrayList<>();
		for (Student child : children.values()) {
			User user = child.getUser();
			if (user.isActive() && user.isLoginEnabled()) {
				rows.add(row(user.getId(), child, null, group, type, sessionId, startsAt, previous, count, reason, assignmentId, title, evaluationId));
			}
		}
		for (Parent parent : parents.findByChildren(children.keySet())) {
			if (!parent.getUser().isActive()) {
				continue;
			}
			for (Student own : parent.getChildren()) {
				Student child = children.get(own.getId());
				if (child != null) {
					rows.add(row(parent.getUser().getId(), child, child.getUser().getFirstName(), group, type, sessionId,
							startsAt, previous, count, reason, assignmentId, title, evaluationId));
				}
			}
		}
		notifications.saveAll(rows);
	}

	private static Notification row(UUID userId, Student child, String childFirstName, ClassGroup group,
			NotificationType type, UUID sessionId, Instant startsAt, Instant previous, int count, String reason,
			UUID assignmentId, String title, UUID evaluationId) {
		return Notification.builder()
				.userId(userId)
				.type(type)
				.studentId(child.getId())
				.childFirstName(childFirstName)
				.groupId(group.getId())
				.groupName(group.getName())
				.sessionId(sessionId)
				.startsAt(startsAt)
				.previousStartsAt(previous)
				.sessionCount(count)
				.reason(reason)
				.assignmentId(assignmentId)
				.evaluationId(evaluationId)
				.title(title)
				.build();
	}

	// ── Read by the parent or the child ──

	@Transactional(readOnly = true)
	public NotificationsPage page(UUID userId) {
		Instant since = clock.instant().minus(KEPT);
		List<NotificationItem> items = notifications.findTop100ByUserIdAndCreatedAtAfterOrderByCreatedAtDesc(userId, since)
				.stream()
				.map(NotificationService::item)
				.toList();
		return new NotificationsPage(notifications.countByUserIdAndReadAtIsNullAndCreatedAtAfter(userId, since), items);
	}

	@Transactional(readOnly = true)
	public UnreadCount unreadCount(UUID userId) {
		return new UnreadCount(notifications.countByUserIdAndReadAtIsNullAndCreatedAtAfter(userId, clock.instant().minus(KEPT)));
	}

	/** Only one's own notifications: another person's id answers "not found". */
	@Transactional
	public void markRead(UUID userId, UUID notificationId) {
		Notification notification = notifications.findByIdAndUserId(notificationId, userId)
				.orElseThrow(() -> ApiException.notFound("notification_not_found"));
		if (notification.getReadAt() == null) {
			notification.setReadAt(clock.instant());
		}
	}

	@Transactional
	public void markAllRead(UUID userId) {
		notifications.markAllRead(userId, clock.instant());
	}

	private static NotificationItem item(Notification n) {
		return new NotificationItem(
				n.getId(),
				n.getType().name(),
				n.getStudentId(),
				n.getChildFirstName(),
				n.getGroupName(),
				n.getSessionId(),
				n.getStartsAt(),
				n.getPreviousStartsAt(),
				n.getSessionCount(),
				n.getReason(),
				n.getAssignmentId(),
				n.getTitle(),
				n.getEvaluationId(),
				n.getPupils(),
				n.isLate(),
				n.getCreatedAt(),
				n.getReadAt() != null);
	}
}
