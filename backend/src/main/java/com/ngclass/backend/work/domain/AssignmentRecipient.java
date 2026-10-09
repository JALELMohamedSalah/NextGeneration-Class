package com.ngclass.backend.work.domain;

import com.ngclass.backend.content.domain.FileAsset;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** One pupil of one homework, with their status and, once corrected, the score, comment and corrected copy. */
@Entity
@Table(name = "assignment_recipients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AssignmentRecipient {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false)
	private UUID assignmentId;

	@Column(nullable = false)
	private UUID studentId;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 10)
	private HomeworkStatus status;

	@Column(nullable = false)
	private Instant statusChangedAt;

	/** Out of the homework's max score, half points allowed; null until corrected. */
	@Column(precision = 5, scale = 2)
	private BigDecimal score;

	@Column(length = 2000)
	private String comment;

	private Instant correctedAt;

	/** The teacher's corrected copy, optional. */
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "correction_file_id")
	private FileAsset correctionFile;

	/** MISSING as soon as the deadline is past, even before the job writes it. */
	public HomeworkStatus statusAt(Assignment assignment, Instant now) {
		if (status == HomeworkStatus.TODO && assignment.getSubmissionMode() == SubmissionMode.FILE && !assignment.getDeadlineAt().isAfter(now)) {
			return HomeworkStatus.MISSING;
		}
		return status;
	}
}
