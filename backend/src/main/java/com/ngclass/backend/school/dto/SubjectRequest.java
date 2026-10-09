package com.ngclass.backend.school.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** A subject the teacher creates: French name, Arabic name (optional, French shown instead), color. */
public record SubjectRequest(
		@NotBlank @Size(max = 60) String nameFr,
		@Size(max = 60) String nameAr,
		@Pattern(regexp = "#[0-9A-Fa-f]{6}") String color) {
}
