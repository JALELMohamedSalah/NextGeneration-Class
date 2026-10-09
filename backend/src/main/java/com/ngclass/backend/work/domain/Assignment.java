package com.ngclass.backend.work.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

/** A published document given to a group, or some pupils of it, with a deadline (spec 06). */
@Entity
@Table(name = "assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Assignment {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false)
	private UUID teacherId;

	@Column(name = "content_item_id", nullable = false)
	private UUID contentItemId;

	@Column(nullable = false)
	private UUID groupId;

	@Column(nullable = false, length = 160)
	private String title;

	@Column(length = 2000)
	private String instructions;

	@Column(nullable = false)
	private Instant deadlineAt;

	@Column(nullable = false)
	private int maxScore;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 8)
	private SubmissionMode submissionMode;

	@Column(nullable = false)
	private boolean allowLate;

	/** The whole group, rather than some of its pupils. */
	@Column(nullable = false)
	private boolean wholeGroup;

	private Instant closedAt;

	/** When the teacher was told that the deadline passed (DEADLINE_PASSED); a later deadline clears it. */
	private Instant deadlineNotifiedAt;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private Instant createdAt;

	/** Over: closed, or past its deadline. */
	public boolean isDone(Instant now) {
		return closedAt != null || !deadlineAt.isAfter(now);
	}
}
