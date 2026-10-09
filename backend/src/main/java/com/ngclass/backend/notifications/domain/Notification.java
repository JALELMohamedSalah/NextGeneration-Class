package com.ngclass.backend.notifications.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Builder.Default;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * Something a parent or a child should know about their sessions and homework, or the teacher about the work of
 * her pupils. It keeps the facts, not a sentence: the app words it in the reader's language.
 */
@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false)
	private UUID userId;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 24)
	private NotificationType type;

	/** The child it is about (for a parent: one of their children; for a child: themselves). */
	private UUID studentId;

	@Column(length = 80)
	private String childFirstName;

	private UUID groupId;

	@Column(nullable = false, length = 80)
	private String groupName;

	/** The first session concerned. */
	private UUID sessionId;

	@Column(nullable = false)
	private Instant startsAt;

	/** A moved session: when it was planned before. */
	private Instant previousStartsAt;

	@Default
	@Column(nullable = false)
	private int sessionCount = 1;

	@Column(length = 300)
	private String reason;

	/** HOMEWORK_ASSIGNED and HOMEWORK_CORRECTED: the homework and its title; [startsAt] is then its deadline. */
	private UUID assignmentId;

	@Column(length = 160)
	private String title;

	/** EVALUATION_GRADED: the evaluation (its title in [title], [startsAt] the day it was held). */
	private UUID evaluationId;

	/** The teacher's notifications: who sent work (WORK_SUBMITTED) or who did not (DEADLINE_PASSED), in order. */
	@Default
	@JdbcTypeCode(SqlTypes.JSON)
	@Column(nullable = false, columnDefinition = "jsonb")
	private List<NamedPupil> pupils = new ArrayList<>();

	/** WORK_SUBMITTED: at least one of the works arrived after the deadline. */
	@Default
	@Column(nullable = false)
	private boolean late = false;

	/** When it happened; a WORK_SUBMITTED row that gathers more work moves to the latest. */
	@CreationTimestamp
	@Column(nullable = false)
	private Instant createdAt;

	private Instant readAt;
}
