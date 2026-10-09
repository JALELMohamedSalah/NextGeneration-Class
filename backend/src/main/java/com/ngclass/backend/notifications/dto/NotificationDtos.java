package com.ngclass.backend.notifications.dto;

import com.ngclass.backend.notifications.domain.NamedPupil;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Responses of /me/notifications. */
public final class NotificationDtos {
	private NotificationDtos() {
	}

	public record NotificationsPage(long unreadCount, List<NotificationItem> items) {
	}

	public record UnreadCount(long count) {
	}

	/**
	 * [type]: SESSION_CANCELLED, SESSION_MOVED, SESSION_RESTORED, HOMEWORK_ASSIGNED or HOMEWORK_CORRECTED (then [title]
	 * is the homework's and [startsAt] its deadline), EVALUATION_GRADED, and for the teacher WORK_SUBMITTED and
	 * DEADLINE_PASSED (the homework in [assignmentId], [title], [startsAt]; [pupils] who sent, or who did not;
	 * [late]: some work came after the deadline). [childFirstName]: the child it is about
	 * (null for a child's own notifications). [previousStartsAt]: a moved session's former time.
	 * [sessionCount]: more than 1 when a whole series changed at once.
	 */
	public record NotificationItem(
			UUID id,
			String type,
			UUID studentId,
			String childFirstName,
			String groupName,
			UUID sessionId,
			Instant startsAt,
			Instant previousStartsAt,
			int sessionCount,
			String reason,
			UUID assignmentId,
			String title,
			UUID evaluationId,
			List<NamedPupil> pupils,
			boolean late,
			Instant createdAt,
			boolean read) {
	}
}
