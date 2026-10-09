package com.ngclass.backend.planning.service;

import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.domain.GroupMember;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.notifications.service.NotificationService;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.planning.domain.Attendance;
import com.ngclass.backend.planning.domain.AttendanceStatus;
import com.ngclass.backend.planning.domain.ClassSession;
import com.ngclass.backend.planning.domain.RecurrenceRule;
import com.ngclass.backend.planning.domain.SessionMode;
import com.ngclass.backend.planning.domain.SessionStatus;
import com.ngclass.backend.planning.dto.PlanningDtos.AttendanceEntry;
import com.ngclass.backend.planning.dto.PlanningDtos.CreatedSessions;
import com.ngclass.backend.planning.dto.PlanningDtos.GroupRef;
import com.ngclass.backend.planning.dto.PlanningDtos.NotesRequest;
import com.ngclass.backend.planning.dto.PlanningDtos.PreviousSession;
import com.ngclass.backend.planning.dto.PlanningDtos.RosterEntry;
import com.ngclass.backend.planning.dto.PlanningDtos.Scope;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionDetail;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionRequest;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionResponse;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionUpdate;
import com.ngclass.backend.planning.repository.AttendanceRepository;
import com.ngclass.backend.planning.repository.ClassSessionRepository;
import com.ngclass.backend.planning.repository.RecurrenceRuleRepository;
import com.ngclass.backend.school.service.SchoolYearService;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Sessions, weekly series and attendance (docs/02-specification/03-planning-sessions-attendance.md,
 * rules in docs/03-conception/03-BUSINESS_RULES.md sections 1 and 2). Times are stored in UTC and
 * entered in Africa/Tunis.
 */
@Service
@RequiredArgsConstructor
public class PlanningService {
	private static final UUID NONE = new UUID(0, 0);
	/** A week view or a month list at most. */
	private static final long MAX_RANGE_DAYS = 62;

	private final ClassSessionRepository sessions;
	private final RecurrenceRuleRepository rules;
	private final AttendanceRepository attendance;
	private final ClassGroupRepository groups;
	private final GroupMemberRepository members;
	private final StudentRepository students;
	private final GroupService groupService;
	private final SchoolYearService schoolYears;
	private final NotificationService notificationService;
	private final AppProperties properties;
	private final Clock clock;

	// ── Reading ──

	@Transactional(readOnly = true)
	public List<SessionResponse> list(Instant from, Instant to, UUID groupId) {
		checkRange(from, to);
		if (groupId != null && !groupService.owns(groupId)) {
			throw ApiException.notFound("group_not_found");
		}
		List<UUID> groupIds = groupId == null ? groupService.ownIds() : List.of(groupId);
		if (groupIds.isEmpty()) {
			return List.of();
		}
		return responses(sessions.findByGroupIdInAndStartsAtLessThanAndEndsAtGreaterThanOrderByStartsAtAsc(groupIds, to, from));
	}

	@Transactional(readOnly = true)
	public SessionDetail detail(UUID sessionId) {
		ClassSession session = require(sessionId);
		Map<UUID, AttendanceStatus> marks = attendance.findById_SessionId(sessionId).stream()
				.collect(Collectors.toMap(a -> a.getId().getStudentId(), Attendance::getStatus));
		List<UUID> memberIds = members.findById_GroupIdAndLeftAtIsNull(session.getGroupId()).stream()
				.map(m -> m.getId().getStudentId())
				.toList();
		// Everyone marked for this session, plus current members: a student who left still shows on past sessions.
		Set<UUID> rosterIds = new HashSet<>(memberIds);
		rosterIds.addAll(marks.keySet());
		List<RosterEntry> roster = students.findByIdIn(rosterIds).stream()
				.filter(s -> s.getArchivedAt() == null || marks.containsKey(s.getId()))
				.sorted(Comparator.comparing((Student s) -> s.getUser().getFirstName().toLowerCase(Locale.ROOT)))
				.map(s -> new RosterEntry(
						s.getId(),
						s.getUser().getFirstName(),
						s.getUser().getLastName(),
						marks.containsKey(s.getId()) ? marks.get(s.getId()).name() : null))
				.toList();
		PreviousSession previous = sessions.findPreviousDone(session.getGroupId(), session.getStartsAt()).stream()
				.findFirst()
				.map(p -> new PreviousSession(p.getStartsAt(), p.getSessionNote(), p.getQuickNote()))
				.orElse(null);
		return new SessionDetail(withSeries(responses(List.of(session)).getFirst(), session), roster, session.getQuickNote(), session.getSessionNote(), previous);
	}

	/** Sessions that would overlap [date start-end], for the warning in the form (allowed anyway). */
	@Transactional(readOnly = true)
	public List<SessionResponse> overlaps(LocalDate date, LocalTime start, LocalTime end, UUID excluded) {
		ZoneId zone = properties.zoneId();
		return responses(overlapping(
				date.atTime(start).atZone(zone).toInstant(),
				date.atTime(end).atZone(zone).toInstant(),
				excluded == null ? NONE : excluded));
	}

	// ── Creating ──

	/** One session, or a weekly series from [date] until [repeatUntil] (default: end of the school year). */
	@Transactional
	public CreatedSessions create(SessionRequest request) {
		ClassGroup group = groupService.require(request.groupId());
		checkTimes(request.startTime(), request.endTime());
		SessionMode mode = mode(request.mode());
		String meetUrl = GroupService.meetUrl(request.meetUrl());
		List<ClassSession> created;
		if (request.repeatWeekly()) {
			LocalDate until = request.repeatUntil() != null ? request.repeatUntil() : schoolYearEnd();
			if (until.isBefore(request.date())) {
				throw ApiException.badRequest("invalid_date_range");
			}
			RecurrenceRule rule = rules.save(RecurrenceRule.builder()
					.groupId(group.getId())
					.weekday(request.date().getDayOfWeek().getValue())
					.startTime(request.startTime())
					.endTime(request.endTime())
					.mode(mode)
					.location(trimmed(request.location()))
					.meetUrl(meetUrl)
					.startsOn(request.date())
					.endsOn(until)
					.build());
			created = generate(rule, request.date(), request.prepNote());
		} else {
			created = List.of(sessions.save(ClassSession.builder()
					.groupId(group.getId())
					.startsAt(at(request.date(), request.startTime()))
					.endsAt(at(request.date(), request.endTime()))
					.mode(mode)
					.location(trimmed(request.location()))
					.meetUrl(meetUrl)
					.prepNote(trimmed(request.prepNote()))
					.build()));
		}
		if (created.isEmpty()) {
			throw ApiException.badRequest("invalid_date_range");
		}
		ClassSession first = created.getFirst();
		List<SessionResponse> overlaps = responses(overlapping(first.getStartsAt(), first.getEndsAt(), first.getId()));
		return new CreatedSessions(created.size(), responses(List.of(first)).getFirst(), overlaps);
	}

	// ── Editing ──

	/**
	 * ONE: this session changes and becomes an exception of its series. FOLLOWING: the series ends the day
	 * before, a new series starts from this session, and its future sessions are regenerated (past ones never move).
	 */
	@Transactional
	public SessionResponse update(UUID sessionId, Scope scope, SessionUpdate update) {
		ClassSession session = requireEditable(sessionId);
		checkTimes(update.startTime(), update.endTime());
		SessionMode mode = mode(update.mode());
		String meetUrl = GroupService.meetUrl(update.meetUrl());
		// Families hear about a new day or time (not about a new room or link).
		Instant before = session.getStartsAt();
		Instant after = at(update.date(), update.startTime());
		if (scope == Scope.FOLLOWING && session.getRecurrenceRuleId() != null) {
			RecurrenceRule old = rules.findById(session.getRecurrenceRuleId()).orElseThrow();
			LocalDate from = localDate(session.getStartsAt());
			RecurrenceRule next = rules.save(RecurrenceRule.builder()
					.groupId(old.getGroupId())
					.weekday(update.date().getDayOfWeek().getValue())
					.startTime(update.startTime())
					.endTime(update.endTime())
					.mode(mode)
					.location(trimmed(update.location()))
					.meetUrl(meetUrl)
					.startsOn(update.date())
					.endsOn(old.getEndsOn())
					.build());
			old.setEndsOn(from.minusDays(1));
			String prep = update.prepNote() != null ? trimmed(update.prepNote()) : session.getPrepNote();
			// This session is rebuilt with the others, unless attendance was already taken on it.
			boolean keepThis = !attendance.findById_SessionId(session.getId()).isEmpty();
			for (ClassSession s : sessions.findByRecurrenceRuleIdAndStartsAtGreaterThanEqualOrderByStartsAtAsc(old.getId(), session.getStartsAt())) {
				boolean isThis = s.getId().equals(session.getId());
				if (isThis ? !keepThis : !s.isException() && s.getStatus() == SessionStatus.PLANNED && attendance.findById_SessionId(s.getId()).isEmpty()) {
					sessions.delete(s);
				}
			}
			sessions.flush();
			if (keepThis) {
				applyToOne(session, update, mode, meetUrl);
				session.setRecurrenceRuleId(next.getId());
			}
			List<ClassSession> regenerated = generate(next, keepThis ? update.date().plusDays(1) : update.date(), keepThis ? null : prep);
			ClassSession first = keepThis || regenerated.isEmpty() ? session : regenerated.getFirst();
			notificationService.sessionsMoved(group(old.getGroupId()), first.getId(), before, after, regenerated.size() + (keepThis ? 1 : 0));
			return responses(List.of(first)).getFirst();
		}
		applyToOne(session, update, mode, meetUrl);
		session.setException(session.getRecurrenceRuleId() != null);
		notificationService.sessionsMoved(group(session.getGroupId()), session.getId(), before, after, 1);
		return responses(List.of(session)).getFirst();
	}

	private void applyToOne(ClassSession session, SessionUpdate update, SessionMode mode, String meetUrl) {
		session.setStartsAt(at(update.date(), update.startTime()));
		session.setEndsAt(at(update.date(), update.endTime()));
		session.setMode(mode);
		session.setLocation(trimmed(update.location()));
		session.setMeetUrl(meetUrl);
		if (update.prepNote() != null) {
			session.setPrepNote(trimmed(update.prepNote()));
		}
	}

	/** Cancelled sessions stay visible (struck through) with their reason; they do not count in statistics. */
	@Transactional
	public SessionResponse cancel(UUID sessionId, Scope scope, String reason) {
		ClassSession session = requireEditable(sessionId);
		String why = trimmed(reason);
		List<ClassSession> cancelled = new ArrayList<>();
		if (scope == Scope.FOLLOWING && session.getRecurrenceRuleId() != null) {
			RecurrenceRule rule = rules.findById(session.getRecurrenceRuleId()).orElseThrow();
			rule.setEndsOn(localDate(session.getStartsAt()).minusDays(1));
			for (ClassSession s : sessions.findByRecurrenceRuleIdAndStartsAtGreaterThanEqualOrderByStartsAtAsc(rule.getId(), session.getStartsAt())) {
				if (s.getStatus() == SessionStatus.PLANNED) {
					s.setStatus(SessionStatus.CANCELLED);
					s.setCancelReason(why);
					cancelled.add(s);
				}
			}
		} else {
			session.setStatus(SessionStatus.CANCELLED);
			session.setCancelReason(why);
			cancelled.add(session);
		}
		notificationService.sessionsCancelled(group(session.getGroupId()), cancelled, why);
		return responses(List.of(session)).getFirst();
	}

	/** "Rétablir": a cancelled session is planned again. */
	@Transactional
	public SessionResponse restore(UUID sessionId) {
		ClassSession session = require(sessionId);
		if (session.getStatus() != SessionStatus.CANCELLED) {
			throw new ApiException(HttpStatus.CONFLICT, "session_not_cancelled");
		}
		session.setStatus(SessionStatus.PLANNED);
		session.setCancelReason(null);
		notificationService.sessionRestored(group(session.getGroupId()), session);
		return responses(List.of(session)).getFirst();
	}

	// ── Session mode ──

	@Transactional
	public SessionDetail start(UUID sessionId) {
		ClassSession session = require(sessionId);
		if (session.getStatus() == SessionStatus.CANCELLED) {
			throw new ApiException(HttpStatus.CONFLICT, "session_cancelled");
		}
		if (session.getStatus() == SessionStatus.PLANNED) {
			session.setStatus(SessionStatus.IN_PROGRESS);
		}
		return detail(sessionId);
	}

	@Transactional
	public SessionDetail end(UUID sessionId) {
		ClassSession session = require(sessionId);
		if (session.getStatus() == SessionStatus.CANCELLED) {
			throw new ApiException(HttpStatus.CONFLICT, "session_cancelled");
		}
		markUnmarkedPresent(session);
		session.setStatus(SessionStatus.DONE);
		return detail(sessionId);
	}

	/**
	 * Saves the marks of the roster. A session whose end has passed becomes "Terminée" once attendance is saved
	 * (business rules, section 1).
	 */
	@Transactional
	public SessionDetail saveAttendance(UUID sessionId, List<AttendanceEntry> entries) {
		ClassSession session = require(sessionId);
		if (session.getStatus() == SessionStatus.CANCELLED) {
			throw new ApiException(HttpStatus.CONFLICT, "session_cancelled");
		}
		Instant now = clock.instant();
		Map<UUID, AttendanceStatus> wanted = new HashMap<>();
		for (AttendanceEntry entry : entries) {
			if (!members.isMember(session.getGroupId(), entry.studentId()) && !attendance.existsById(new Attendance.Key(sessionId, entry.studentId()))) {
				throw ApiException.badRequest("not_group_member");
			}
			wanted.put(entry.studentId(), status(entry.status()));
		}
		for (Map.Entry<UUID, AttendanceStatus> e : wanted.entrySet()) {
			Attendance.Key key = new Attendance.Key(sessionId, e.getKey());
			Attendance mark = attendance.findById(key).orElseGet(() -> Attendance.builder().id(key).build());
			mark.setStatus(e.getValue());
			mark.setMarkedAt(now);
			attendance.save(mark);
		}
		if (session.getStatus() == SessionStatus.PLANNED && !session.getEndsAt().isAfter(now)) {
			session.setStatus(SessionStatus.DONE);
		}
		return detail(sessionId);
	}

	@Transactional
	public void saveNotes(UUID sessionId, NotesRequest notes) {
		ClassSession session = require(sessionId);
		if (notes.prepNote() != null) {
			session.setPrepNote(trimmed(notes.prepNote()));
		}
		if (notes.quickNote() != null) {
			session.setQuickNote(trimmed(notes.quickNote()));
		}
		if (notes.sessionNote() != null) {
			session.setSessionNote(trimmed(notes.sessionNote()));
		}
	}

	/** Deleting a weekly rule cancels its future sessions that have no attendance (business rules, section 2). */
	@Transactional
	public void deleteRule(UUID ruleId) {
		RecurrenceRule rule = rules.findById(ruleId)
				.filter(r -> groupService.owns(r.getGroupId()))
				.orElseThrow(() -> ApiException.notFound("rule_not_found"));
		Instant now = clock.instant();
		for (ClassSession s : sessions.findByRecurrenceRuleIdAndStartsAtGreaterThanEqualOrderByStartsAtAsc(rule.getId(), now)) {
			if (s.getStatus() == SessionStatus.PLANNED && attendance.findById_SessionId(s.getId()).isEmpty()) {
				s.setStatus(SessionStatus.CANCELLED);
			}
		}
		rule.setEndsOn(localDate(now).minusDays(1));
	}

	// ── Helpers ──

	/** One of the signed-in teacher's sessions (through its group). */
	public ClassSession require(UUID sessionId) {
		return sessions.findById(sessionId)
				.filter(s -> groupService.owns(s.getGroupId()))
				.orElseThrow(() -> ApiException.notFound("session_not_found"));
	}

	/** The teacher's own sessions overlapping [from, to): another teacher's planning is not hers to see. */
	private List<ClassSession> overlapping(Instant from, Instant to, UUID excluded) {
		List<UUID> groupIds = groupService.ownIds();
		return groupIds.isEmpty() ? List.of() : sessions.findOverlapping(groupIds, from, to, excluded);
	}

	public List<SessionResponse> responses(List<ClassSession> list) {
		if (list.isEmpty()) {
			return List.of();
		}
		Map<UUID, ClassGroup> groupById = groups.findByIdIn(list.stream().map(ClassSession::getGroupId).collect(Collectors.toSet())).stream()
				.collect(Collectors.toMap(ClassGroup::getId, Function.identity()));
		Map<UUID, int[]> counts = new HashMap<>();
		for (Object[] row : attendance.countBySession(list.stream().map(ClassSession::getId).toList())) {
			counts.computeIfAbsent((UUID) row[0], k -> new int[3])[((AttendanceStatus) row[1]).ordinal()] = ((Number) row[2]).intValue();
		}
		return list.stream()
				.map(s -> {
					ClassGroup g = groupById.get(s.getGroupId());
					int[] c = counts.getOrDefault(s.getId(), new int[3]);
					return new SessionResponse(
							s.getId(),
							ref(g),
							s.getStartsAt(),
							s.getEndsAt(),
							s.getMode().name(),
							s.getLocation(),
							s.getMeetUrl() != null ? s.getMeetUrl() : g.getDefaultMeetUrl(),
							s.getMeetUrl() != null,
							s.getStatus().name(),
							s.getCancelReason(),
							s.getRecurrenceRuleId() != null,
							0,
							null,
							s.getPrepNote(),
							c[0],
							c[1],
							c[2]);
				})
				.toList();
	}

	public static GroupRef ref(ClassGroup g) {
		return new GroupRef(g.getId(), g.getName(), GroupService.code(g.getName()), g.getColor(), g.getSubject().name(), g.isPrivateLesson());
	}

	/** Adds "N sessions until <date>" for the scope dialog. */
	private SessionResponse withSeries(SessionResponse r, ClassSession session) {
		if (session.getRecurrenceRuleId() == null) {
			return r;
		}
		RecurrenceRule rule = rules.findById(session.getRecurrenceRuleId()).orElse(null);
		int following = (int) sessions.findByRecurrenceRuleIdAndStartsAtGreaterThanEqualOrderByStartsAtAsc(session.getRecurrenceRuleId(), session.getStartsAt())
				.stream()
				.filter(s -> s.getStatus() != SessionStatus.CANCELLED)
				.count();
		return new SessionResponse(r.id(), r.group(), r.startsAt(), r.endsAt(), r.mode(), r.location(), r.meetUrl(), r.ownMeetUrl(),
				r.status(), r.cancelReason(), true, following, rule == null ? null : rule.getEndsOn(), r.prepNote(), r.present(), r.absent(), r.late());
	}

	/** Every weekday of the rule from [from] to its end; the rule's link stays on the rule. */
	private List<ClassSession> generate(RecurrenceRule rule, LocalDate from, String prepNote) {
		List<ClassSession> created = new ArrayList<>();
		LocalDate day = from.with(TemporalAdjusters.nextOrSame(DayOfWeek.of(rule.getWeekday())));
		boolean first = true;
		while (!day.isAfter(rule.getEndsOn())) {
			created.add(ClassSession.builder()
					.groupId(rule.getGroupId())
					.recurrenceRuleId(rule.getId())
					.startsAt(at(day, rule.getStartTime()))
					.endsAt(at(day, rule.getEndTime()))
					.mode(rule.getMode())
					.location(rule.getLocation())
					.meetUrl(rule.getMeetUrl())
					.prepNote(first ? trimmed(prepNote) : null)
					.build());
			first = false;
			day = day.plusWeeks(1);
		}
		return sessions.saveAll(created);
	}

	/** Ending a session: students nobody tapped are present, the default of session mode. */
	private void markUnmarkedPresent(ClassSession session) {
		Instant now = clock.instant();
		Set<UUID> marked = attendance.findById_SessionId(session.getId()).stream()
				.map(a -> a.getId().getStudentId())
				.collect(Collectors.toSet());
		for (GroupMember m : members.findById_GroupIdAndLeftAtIsNull(session.getGroupId())) {
			UUID studentId = m.getId().getStudentId();
			if (!marked.contains(studentId)) {
				attendance.save(Attendance.builder()
						.id(new Attendance.Key(session.getId(), studentId))
						.status(AttendanceStatus.PRESENT)
						.markedAt(now)
						.build());
			}
		}
	}

	private ClassGroup group(UUID groupId) {
		return groups.findById(groupId).orElseThrow(() -> ApiException.notFound("group_not_found"));
	}

	private ClassSession requireEditable(UUID sessionId) {
		ClassSession session = require(sessionId);
		if (session.getStatus() == SessionStatus.DONE || session.getStatus() == SessionStatus.CANCELLED) {
			throw new ApiException(HttpStatus.CONFLICT, "session_not_editable");
		}
		return session;
	}

	private Instant at(LocalDate date, LocalTime time) {
		return date.atTime(time).atZone(properties.zoneId()).toInstant();
	}

	private LocalDate localDate(Instant instant) {
		return instant.atZone(properties.zoneId()).toLocalDate();
	}

	private LocalDate schoolYearEnd() {
		return schoolYears.ensureCurrent(LocalDate.now(clock.withZone(properties.zoneId()))).getEndsOn();
	}

	private static void checkTimes(LocalTime start, LocalTime end) {
		if (!end.isAfter(start)) {
			throw ApiException.badRequest("invalid_time_range");
		}
	}

	private static void checkRange(Instant from, Instant to) {
		if (!to.isAfter(from) || Duration.between(from, to).toDays() > MAX_RANGE_DAYS) {
			throw ApiException.badRequest("invalid_date_range");
		}
	}

	private static SessionMode mode(String value) {
		try {
			return SessionMode.valueOf(value);
		} catch (IllegalArgumentException ex) {
			throw ApiException.badRequest("invalid_mode");
		}
	}

	private static AttendanceStatus status(String value) {
		try {
			return AttendanceStatus.valueOf(value);
		} catch (IllegalArgumentException ex) {
			throw ApiException.badRequest("invalid_attendance");
		}
	}

	private static String trimmed(String value) {
		return value == null || value.isBlank() ? null : value.trim();
	}
}
