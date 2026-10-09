package com.ngclass.backend.groups.dto;

import com.ngclass.backend.common.LocalizedText;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public final class GroupDtos {
	private GroupDtos() {
	}

	/** Create or edit a group. Color null: the next group color. */
	public record GroupRequest(
			@NotBlank @Size(max = 80) String name,
			@NotNull UUID subjectId,
			@NotNull UUID levelId,
			@Size(max = 500) String defaultMeetUrl,
			@Pattern(regexp = "#[0-9A-Fa-f]{6}") String color) {
	}

	/** A private lesson: one student, one subject. The name is built from them. */
	public record PrivateLessonRequest(@NotNull UUID studentId, @NotNull UUID subjectId) {
	}

	public record MembersRequest(@NotNull List<UUID> studentIds) {
	}

	/** One line of a weekly schedule, e.g. Tuesday 10:00 to 11:30. */
	public record ScheduleItem(UUID ruleId, int weekday, LocalTime startTime, LocalTime endTime, String mode, String location) {
	}

	public record GroupResponse(
			UUID id,
			String name,
			String code,
			UUID subjectId,
			LocalizedText subject,
			UUID levelId,
			LocalizedText level,
			boolean privateLesson,
			String defaultMeetUrl,
			String color,
			int memberCount,
			List<ScheduleItem> schedule) {
	}

	public record MemberItem(UUID studentId, String firstName, String lastName, String username, Integer attendanceRate) {
	}

	public record GroupDetail(GroupResponse group, List<MemberItem> members) {
	}
}
