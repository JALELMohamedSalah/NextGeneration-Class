package com.ngclass.backend.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** The owner's dashboard: teachers and what each one has in her space. */
public final class AdminDtos {
	private AdminDtos() {
	}

	/** A new teacher: she signs in with [username] (or [phone]) and the temporary password shown once. */
	public record TeacherRequest(
			@NotBlank @Size(max = 80) String firstName,
			@NotBlank @Size(max = 80) String lastName,
			@NotBlank @Size(max = 64) String username,
			@Size(max = 30) String phone,
			@Size(max = 254) String email) {
	}

	/** [awaitingFirstLogin]: she has not chosen her own password yet. */
	public record TeacherItem(
			UUID id,
			String firstName,
			String lastName,
			String username,
			String phone,
			String email,
			boolean active,
			boolean awaitingFirstLogin,
			Instant lastLoginAt,
			Instant createdAt,
			long students,
			long parents,
			long groups) {
	}

	public record Totals(long teachers, long activeTeachers, long students, long parents, long groups) {
	}

	public record TeachersPage(Totals totals, List<TeacherItem> teachers) {
	}

	/** Shown once to the owner, who passes it on to the teacher. */
	public record TeacherCredential(UUID userId, String firstName, String lastName, String username, String temporaryPassword) {
	}

	public record CreatedTeacher(TeacherItem teacher, TeacherCredential credential) {
	}
}
