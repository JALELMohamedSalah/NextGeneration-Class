package com.ngclass.backend.work.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** One pupil in an evaluation: a score in half points, or absent (never counted as 0), and a comment. */
@Entity
@Table(name = "evaluation_grades")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvaluationGrade {
	@EmbeddedId
	private Key id;

	@Column(precision = 5, scale = 2)
	private BigDecimal score;

	@Column(nullable = false)
	private boolean absent;

	@Column(length = 2000)
	private String comment;

	@Column(nullable = false)
	private Instant gradedAt;

	@Embeddable
	@Getter
	@NoArgsConstructor
	@AllArgsConstructor
	@EqualsAndHashCode
	public static class Key implements Serializable {
		@Column(name = "evaluation_id")
		private UUID evaluationId;

		@Column(name = "student_id")
		private UUID studentId;
	}
}
