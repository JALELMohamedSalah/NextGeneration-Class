package com.ngclass.backend.work.dto;

import com.ngclass.backend.planning.dto.PlanningDtos.GroupRef;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/** Paper evaluations (spec 06 "Évaluations"), teacher side. */
public final class EvaluationDtos {
	private EvaluationDtos() {
	}

	/** A new evaluation for one of the teacher's groups; [maxScore] 20 by default in the app. */
	public record EvaluationRequest(
			@NotNull UUID groupId,
			@NotBlank @Size(max = 160) String title,
			@NotNull LocalDate heldOn,
			@NotNull @Min(1) @Max(100) Integer maxScore,
			UUID chapterId) {
	}

	/** "Modifier": the group stays. */
	public record EvaluationUpdate(
			@NotBlank @Size(max = 160) String title,
			@NotNull LocalDate heldOn,
			@NotNull @Min(1) @Max(100) Integer maxScore,
			UUID chapterId) {
	}

	public record ChapterRef(UUID id, String title) {
	}

	/**
	 * A row of the "Évaluations" tab. [pupils]: who is graded or could be (current members); [graded]: scores typed;
	 * [absent]: marked absent; [average] on the evaluation's own scale, null before a score.
	 */
	public record EvaluationItem(
			UUID id,
			String title,
			GroupRef group,
			LocalDate heldOn,
			int maxScore,
			ChapterRef chapter,
			int pupils,
			int graded,
			int absent,
			BigDecimal average) {
	}

	/** One pupil of the score table: nothing typed yet, a score, or absent. */
	public record GradeRow(UUID studentId, String firstName, String lastName, BigDecimal score, boolean absent, String comment) {
	}

	public record EvaluationDetail(EvaluationItem evaluation, List<GradeRow> grades) {
	}

	/** [score] null and not [absent]: nothing for this pupil (a typed score can be erased). */
	public record GradeInput(@NotNull UUID studentId, BigDecimal score, boolean absent, @Size(max = 2000) String comment) {
	}

	public record GradesRequest(@NotNull @Valid List<GradeInput> grades) {
	}
}
