package com.ngclass.backend.planning.service;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.service.FamilyAccess;
import com.ngclass.backend.planning.domain.Attendance;
import com.ngclass.backend.planning.domain.ClassSession;
import com.ngclass.backend.planning.dto.PlanningDtos.MySession;
import com.ngclass.backend.planning.repository.AttendanceRepository;
import com.ngclass.backend.planning.repository.ClassSessionRepository;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Sessions as a student or a parent sees them: only their own groups, no private notes, and the
 * online link only for the student (spec 03: parents do not see the link).
 */
@Service
@RequiredArgsConstructor
public class MyPlanningService {
	private static final long MAX_RANGE_DAYS = 62;

	private final FamilyAccess family;
	private final GroupMemberRepository members;
	private final ClassGroupRepository groups;
	private final ClassSessionRepository sessions;
	private final AttendanceRepository attendance;

	/** [studentId] is required for a parent (one of their children) and ignored for a student. */
	@Transactional(readOnly = true)
	public List<MySession> sessions(AuthenticatedUser user, UUID studentId, Instant from, Instant to) {
		if (!to.isAfter(from) || Duration.between(from, to).toDays() > MAX_RANGE_DAYS) {
			throw ApiException.badRequest("invalid_date_range");
		}
		Student student = family.child(user, studentId);
		boolean withLink = user.role() == Role.STUDENT;
		List<UUID> groupIds = members.findById_StudentIdAndLeftAtIsNull(student.getId()).stream()
				.map(m -> m.getId().getGroupId())
				.toList();
		if (groupIds.isEmpty()) {
			return List.of();
		}
		Map<UUID, ClassGroup> groupById = groups.findByIdIn(groupIds).stream()
				.collect(Collectors.toMap(ClassGroup::getId, Function.identity()));
		List<ClassSession> found = sessions.findByGroupIdInAndStartsAtLessThanAndEndsAtGreaterThanOrderByStartsAtAsc(groupIds, to, from);
		return found.stream()
				.map(s -> {
					ClassGroup g = groupById.get(s.getGroupId());
					String mark = attendance.findById(new Attendance.Key(s.getId(), student.getId()))
							.map(a -> a.getStatus().name())
							.orElse(null);
					String link = s.getMeetUrl() != null ? s.getMeetUrl() : g.getDefaultMeetUrl();
					return new MySession(
							s.getId(),
							PlanningService.ref(g),
							s.getStartsAt(),
							s.getEndsAt(),
							s.getMode().name(),
							s.getLocation(),
							withLink ? link : null,
							s.getStatus().name(),
							s.getCancelReason(),
							mark);
				})
				.toList();
	}
}
