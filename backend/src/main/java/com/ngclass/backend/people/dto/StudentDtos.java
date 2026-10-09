package com.ngclass.backend.people.dto;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.common.LocalizedText;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Teacher-side student and parent DTOs. Student and parent views use their own classes. */
public final class StudentDtos {
	private StudentDtos() {
	}

	/**
	 * Username null: generated as prenom.nom. Parents: existing ones by id, or new ones (2 at most).
	 * [createLogin] false: the child does not sign in (parents follow); null keeps the current setting
	 * (true for a new student, for older API clients).
	 */
	public record StudentRequest(
			@NotBlank @Size(max = 80) String firstName,
			@NotBlank @Size(max = 80) String lastName,
			@NotNull UUID levelId,
			@Size(max = 30) String phone,
			@Size(max = 64) String username,
			List<UUID> groupIds,
			@Valid List<ParentInput> parents,
			Boolean createLogin) {
	}

	public record ParentInput(
			UUID existingParentId,
			@Size(max = 80) String firstName,
			@Size(max = 80) String lastName,
			@Size(max = 30) String phone,
			@Size(max = 254) String email,
			@Size(max = 20) String relation) {
	}

	public record GroupTag(UUID id, String name, String code, String color, boolean privateLesson) {
	}

	public record ParentTag(UUID id, UUID userId, String firstName, String lastName, String phone, String relation) {
	}

	public record StudentRow(
			UUID id,
			UUID userId,
			String firstName,
			String lastName,
			String username,
			String phone,
			UUID levelId,
			LocalizedText level,
			List<GroupTag> groups,
			List<ParentTag> parents,
			/** The child signs in with their own username. */
			boolean loginEnabled,
			boolean archived,
			Integer attendanceRate,
			int absences) {
	}

	public record AttendanceMark(Instant sessionStart, String status) {
	}

	public record AttendanceSummary(int present, int absent, int late, Integer rate, List<AttendanceMark> recent) {
	}

	public record UpcomingSession(UUID id, UUID groupId, String groupName, String groupColor, Instant startsAt, Instant endsAt, String mode, String location) {
	}

	public record StudentDetail(StudentRow student, Instant lastLoginAt, AttendanceSummary attendance, List<UpcomingSession> nextSessions) {
	}

	/** Shown once after creation: the passwords are never shown again. */
	public record Credential(UUID userId, Role role, String firstName, String lastName, String username, String temporaryPassword) {
	}

	public record CreatedStudent(StudentRow student, List<Credential> credentials) {
	}

	public record UsernameSuggestion(String username, boolean available) {
	}

	public record NoteRequest(@NotBlank @Size(max = 5000) String body) {
	}

	public record NoteResponse(UUID id, String body, Instant createdAt, Instant updatedAt) {
	}

	public record ParentRow(UUID id, UUID userId, String firstName, String lastName, String phone, List<String> children) {
	}
}
