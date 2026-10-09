package com.ngclass.backend.planning.domain;

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
import lombok.Builder.Default;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/** One session of a group ("séance"). Notes are private to the teacher. */
@Entity
@Table(name = "sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassSession {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false)
	private UUID groupId;

	private UUID recurrenceRuleId;

	@Column(nullable = false)
	private Instant startsAt;

	@Column(nullable = false)
	private Instant endsAt;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 12)
	private SessionMode mode;

	@Column(length = 120)
	private String location;

	/** Null: the group's default link. */
	@Column(length = 500)
	private String meetUrl;

	@Default
	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 12)
	private SessionStatus status = SessionStatus.PLANNED;

	@Column(length = 300)
	private String cancelReason;

	@Column(columnDefinition = "text")
	private String prepNote;

	@Column(columnDefinition = "text")
	private String quickNote;

	@Column(columnDefinition = "text")
	private String sessionNote;

	/** Changed on this date only: later edits of the whole series leave it alone. */
	@Column(name = "is_exception", nullable = false)
	private boolean exception;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private Instant createdAt;

	@UpdateTimestamp
	@Column(nullable = false)
	private Instant updatedAt;
}
