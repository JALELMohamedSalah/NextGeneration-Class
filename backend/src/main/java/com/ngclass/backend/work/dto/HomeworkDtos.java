package com.ngclass.backend.work.dto;

import com.ngclass.backend.content.dto.ContentDtos.SubjectRef;
import com.ngclass.backend.planning.dto.PlanningDtos.GroupRef;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Homework (spec 06): the teacher's side, then the pupil's and parent's; correction comes with step 4. */
public final class HomeworkDtos {
	private HomeworkDtos() {
	}

	/** [studentIds] empty: the whole group. [submissionMode]: FILE or NONE. */
	public record AssignRequest(
			@NotNull UUID contentItemId,
			@NotBlank @Size(max = 160) String title,
			@NotNull UUID groupId,
			List<UUID> studentIds,
			@NotNull Instant deadlineAt,
			@NotBlank String submissionMode,
			boolean allowLate,
			@Size(max = 2000) String instructions,
			@Min(1) @Max(100) Integer maxScore) {
	}

	public record DeadlineRequest(@NotNull Instant deadlineAt) {
	}

	/** How many pupils are in each status (MISSING already counted once the deadline is past). */
	public record StatusCounts(int todo, int submitted, int late, int missing, int corrected) {
	}

	/**
	 * [done]: closed, or past its deadline ("Terminés"). [subjectId]: the document's subject. [average]: the mean of
	 * the scores on /20 given so far, null before the first.
	 */
	public record AssignmentItem(
			UUID id,
			String title,
			UUID contentItemId,
			String contentKind,
			GroupRef group,
			boolean wholeGroup,
			Instant deadlineAt,
			String submissionMode,
			boolean allowLate,
			String instructions,
			int maxScore,
			boolean closed,
			boolean done,
			int recipients,
			StatusCounts counts,
			Instant createdAt,
			UUID subjectId,
			BigDecimal average) {
	}

	/** [score]: out of the homework's max score, once corrected. */
	public record RecipientRow(UUID studentId, String firstName, String lastName, String status, Instant submittedAt, UUID submissionId, BigDecimal score) {
	}

	public record AssignmentDetail(AssignmentItem assignment, List<RecipientRow> recipients) {
	}

	/** A homework in a pupil's or parent's list. [status] is null for something to read only; [score] once corrected. */
	public record MyHomework(
			UUID id,
			String title,
			SubjectRef subject,
			String groupName,
			Instant deadlineAt,
			String submissionMode,
			boolean allowLate,
			boolean closed,
			String status,
			Instant submittedAt,
			BigDecimal score,
			int maxScore) {
	}

	public record ContentRef(UUID id, String title, String kind, String tag, Integer pageCount) {
	}

	public record SubmissionInfo(UUID id, Instant submittedAt, boolean late, String fileName, Integer pageCount) {
	}

	/**
	 * [canSubmit]: a file is expected, the homework is open and on time (or late is accepted), and not corrected.
	 * [correction]: the score, comment and corrected copy, once corrected.
	 */
	public record MyHomeworkDetail(MyHomework homework, String instructions, ContentRef content, SubmissionInfo submission, boolean canSubmit,
			CorrectionInfo correction) {
	}

	// ── Correction (step 4) ──

	/** [score]: from 0 to the homework's max score, in half points. [comment]: seen by the pupil and the parents. */
	public record CorrectionRequest(@NotNull BigDecimal score, @Size(max = 2000) String comment) {
	}

	/** The teacher's corrected copy: [kind] PDF or IMAGE. */
	public record CorrectionFile(String fileName, String kind, Integer pageCount) {
	}

	public record CorrectionInfo(BigDecimal score, int maxScore, String comment, Instant correctedAt, CorrectionFile file) {
	}

	/** One pupil's copy on the correction screen; [score] and [correctedAt] null until saved, [file] attached any time. */
	public record CorrectionView(
			UUID assignmentId,
			UUID studentId,
			String firstName,
			String lastName,
			String status,
			int maxScore,
			SubmissionInfo submission,
			BigDecimal score,
			String comment,
			Instant correctedAt,
			CorrectionFile file) {
	}

	public record ToCorrectItem(UUID studentId, String firstName, String lastName, String status, Instant submittedAt, UUID submissionId) {
	}

	/** "À corriger": one homework and its copies waiting, oldest first. */
	public record ToCorrectGroup(AssignmentItem assignment, List<ToCorrectItem> items) {
	}

	public record StudentName(UUID studentId, String firstName, String lastName) {
	}

	/** "Travail manquant" (Ma journée): a homework past its deadline and who sent nothing. */
	public record MissingWork(AssignmentItem assignment, List<StudentName> missing) {
	}
}
