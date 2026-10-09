package com.ngclass.backend.search.dto;

import com.ngclass.backend.common.LocalizedText;
import com.ngclass.backend.planning.dto.PlanningDtos.GroupRef;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/** The teacher's search (design `r2/Recherche.png`): a few results per family, the best placed first. */
public final class SearchDtos {
	private SearchDtos() {
	}

	public record StudentHit(UUID id, String firstName, String lastName, LocalizedText level, List<String> groups) {
	}

	public record ChildRef(UUID id, String firstName) {
	}

	/** A parent leads to their (first) child. */
	public record ParentHit(UUID id, String firstName, String lastName, String phone, List<ChildRef> children) {
	}

	public record GroupHit(UUID id, String name, String code, String color, boolean privateLesson, int memberCount) {
	}

	public record DocumentHit(UUID id, String title, String tag, String kind, LocalizedText subject, LocalizedText level, String chapter) {
	}

	public record ChapterHit(UUID id, String title, LocalizedText subject, LocalizedText level, int documents) {
	}

	/** [toCorrect]: copies sent and not corrected yet. */
	public record HomeworkHit(UUID id, String title, GroupRef group, Instant deadlineAt, int toCorrect, boolean done) {
	}

	public record EvaluationHit(UUID id, String title, GroupRef group, LocalDate heldOn) {
	}

	public record SearchResults(
			List<StudentHit> students,
			List<ParentHit> parents,
			List<GroupHit> groups,
			List<DocumentHit> documents,
			List<ChapterHit> chapters,
			List<HomeworkHit> homework,
			List<EvaluationHit> evaluations) {
	}
}
