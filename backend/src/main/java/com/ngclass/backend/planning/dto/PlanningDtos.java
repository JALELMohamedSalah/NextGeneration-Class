package com.ngclass.backend.planning.dto;

import com.ngclass.backend.common.LocalizedText;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public final class PlanningDtos {
	private PlanningDtos() {
	}

	public enum Scope {
		/** This session only. */
		ONE,
		/** This session and the following ones of its series. */
		FOLLOWING
	}

	/**
	 * A new session, or a weekly series when [repeatWeekly]. Date and times are local (Africa/Tunis).
	 * Meet link null: the group's default.
	 */
	public record SessionRequest(
			@NotNull UUID groupId,
			@NotNull LocalDate date,
			@NotNull LocalTime startTime,
			@NotNull LocalTime endTime,
			@NotNull String mode,
			@Size(max = 120) String location,
			@Size(max = 500) String meetUrl,
			@Size(max = 5000) String prepNote,
			boolean repeatWeekly,
			LocalDate repeatUntil) {
	}

	public record SessionUpdate(
			@NotNull LocalDate date,
			@NotNull LocalTime startTime,
			@NotNull LocalTime endTime,
			@NotNull String mode,
			@Size(max = 120) String location,
			@Size(max = 500) String meetUrl,
			@Size(max = 5000) String prepNote) {
	}

	public record CancelRequest(@Size(max = 300) String reason) {
	}

	public record NotesRequest(@Size(max = 5000) String prepNote, @Size(max = 5000) String quickNote, @Size(max = 5000) String sessionNote) {
	}

	public record AttendanceEntry(@NotNull UUID studentId, @NotNull String status) {
	}

	public record AttendanceRequest(@NotNull @Valid List<AttendanceEntry> entries) {
	}

	public record GroupRef(UUID id, String name, String code, String color, LocalizedText subject, boolean privateLesson) {
	}

	/** Teacher view of a session, with her private preparation note. */
	public record SessionResponse(
			UUID id,
			GroupRef group,
			Instant startsAt,
			Instant endsAt,
			String mode,
			String location,
			/** The session's own link, or the group's default. */
			String meetUrl,
			boolean ownMeetUrl,
			String status,
			String cancelReason,
			boolean recurring,
			/** Sessions of the series from this one on (for "38 séances jusqu'au 30 juin"). */
			int followingCount,
			LocalDate seriesEndsOn,
			String prepNote,
			int present,
			int absent,
			int late) {
	}

	public record CreatedSessions(int count, SessionResponse first, List<SessionResponse> overlaps) {
	}

	public record RosterEntry(UUID studentId, String firstName, String lastName, String status) {
	}

	/** Everything session mode shows. */
	public record SessionDetail(SessionResponse session, List<RosterEntry> roster, String quickNote, String sessionNote, PreviousSession previous) {
	}

	public record PreviousSession(Instant startsAt, String sessionNote, String quickNote) {
	}

	/** Student and parent view: no private notes; parents never get the link. */
	public record MySession(
			UUID id,
			GroupRef group,
			Instant startsAt,
			Instant endsAt,
			String mode,
			String location,
			String meetUrl,
			String status,
			String cancelReason,
			/** The student's own attendance, once taken. */
			String attendance) {
	}
}
