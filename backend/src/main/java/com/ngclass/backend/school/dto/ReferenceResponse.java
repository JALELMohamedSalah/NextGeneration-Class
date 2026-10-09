package com.ngclass.backend.school.dto;

import com.ngclass.backend.common.LocalizedText;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/** Everything the app needs to label subjects, levels and the school year, in both languages. */
public record ReferenceResponse(List<SubjectItem> subjects, List<LevelItem> levels, SchoolYearItem currentSchoolYear) {
	public record SubjectItem(UUID id, LocalizedText name, String color) {
	}

	public record LevelItem(UUID id, LocalizedText name) {
	}

	public record SchoolYearItem(UUID id, String label, LocalDate startsOn, LocalDate endsOn) {
	}
}
