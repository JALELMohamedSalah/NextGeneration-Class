package com.ngclass.backend.notifications.domain;

public enum NotificationType {
	SESSION_CANCELLED,
	SESSION_MOVED,
	SESSION_RESTORED,
	HOMEWORK_ASSIGNED,
	HOMEWORK_CORRECTED,
	/** A paper evaluation's grade, first saved (Release 2, step 5). */
	EVALUATION_GRADED,
	/** The teacher: work sent by a pupil or a parent; one unread row per homework gathers them. */
	WORK_SUBMITTED,
	/** The teacher: a homework's deadline passed; who did not send. */
	DEADLINE_PASSED
}
