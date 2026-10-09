package com.ngclass.backend.groups.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.work.service.HomeworkJoins;
import com.ngclass.backend.groups.domain.GroupMember;
import com.ngclass.backend.groups.dto.GroupDtos.GroupDetail;
import com.ngclass.backend.groups.dto.GroupDtos.GroupRequest;
import com.ngclass.backend.groups.dto.GroupDtos.GroupResponse;
import com.ngclass.backend.groups.dto.GroupDtos.MemberItem;
import com.ngclass.backend.groups.dto.GroupDtos.PrivateLessonRequest;
import com.ngclass.backend.groups.dto.GroupDtos.ScheduleItem;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.planning.domain.RecurrenceRule;
import com.ngclass.backend.planning.repository.RecurrenceRuleRepository;
import com.ngclass.backend.planning.service.AttendanceStats;
import com.ngclass.backend.school.domain.Level;
import com.ngclass.backend.school.domain.SchoolYear;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.LevelRepository;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.school.service.SchoolYearService;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Groups and private lessons of the current school year (docs/02-specification/02-students-groups.md). */
@Service
@RequiredArgsConstructor
public class GroupService {
	/** Group colors in order of creation (UI design spec 1.1). */
	private static final List<String> PALETTE = List.of("#2B3990", "#12A39A", "#FFB020", "#7048E8", "#3B5BDB", "#E8590C");

	private final ClassGroupRepository groups;
	private final GroupMemberRepository members;
	private final StudentRepository students;
	private final SubjectRepository subjects;
	private final LevelRepository levels;
	private final RecurrenceRuleRepository rules;
	private final SchoolYearService schoolYears;
	private final AttendanceStats attendance;
	private final AppProperties properties;
	private final Clock clock;
	private final HomeworkJoins homeworkJoins;
	private final CurrentTeacher teacher;

	@Transactional(readOnly = true)
	public List<GroupResponse> list() {
		List<ClassGroup> all = groups.findBySchoolYear_IdAndTeacherIdAndArchivedAtIsNullOrderByPrivateLessonAscNameAsc(currentYear().getId(), teacher.id());
		return toResponses(all);
	}

	@Transactional(readOnly = true)
	public GroupDetail detail(UUID groupId) {
		ClassGroup group = require(groupId);
		List<UUID> studentIds = members.findById_GroupIdAndLeftAtIsNull(groupId).stream()
				.map(m -> m.getId().getStudentId())
				.toList();
		Map<UUID, AttendanceStats.Summary> stats = attendance.of(studentIds);
		List<MemberItem> items = students.findByIdIn(studentIds).stream()
				.filter(s -> s.getArchivedAt() == null)
				.sorted(Comparator.comparing((Student s) -> s.getUser().getFirstName().toLowerCase(Locale.ROOT)))
				.map(s -> new MemberItem(
						s.getId(),
						s.getUser().getFirstName(),
						s.getUser().getLastName(),
						s.getUser().getUsername(),
						stats.get(s.getId()).rate()))
				.toList();
		return new GroupDetail(toResponses(List.of(group)).getFirst(), items);
	}

	@Transactional
	public GroupResponse create(GroupRequest request) {
		SchoolYear year = currentYear();
		ClassGroup group = ClassGroup.builder()
				.teacherId(teacher.id())
				.schoolYear(year)
				.subject(subject(request.subjectId()))
				.level(level(request.levelId()))
				.name(request.name().trim())
				.defaultMeetUrl(meetUrl(request.defaultMeetUrl()))
				.color(request.color() != null ? request.color() : nextColor(year))
				.build();
		return toResponses(List.of(groups.save(group))).getFirst();
	}

	@Transactional
	public GroupResponse update(UUID groupId, GroupRequest request) {
		ClassGroup group = require(groupId);
		group.setName(request.name().trim());
		group.setSubject(subject(request.subjectId()));
		group.setLevel(level(request.levelId()));
		group.setDefaultMeetUrl(meetUrl(request.defaultMeetUrl()));
		if (request.color() != null) {
			group.setColor(request.color());
		}
		return toResponses(List.of(group)).getFirst();
	}

	@Transactional
	public void archive(UUID groupId) {
		require(groupId).setArchivedAt(clock.instant());
	}

	/** Makes the current members exactly [studentIds]; people who leave keep their history. */
	@Transactional
	public GroupDetail setMembers(UUID groupId, Collection<UUID> studentIds) {
		ClassGroup group = require(groupId);
		Set<UUID> wanted = new HashSet<>(studentIds);
		UUID me = teacher.id();
		if (students.findAllById(wanted).stream().filter(s -> me.equals(s.getTeacherId())).count() != wanted.size()) {
			throw ApiException.notFound("student_not_found");
		}
		Instant now = clock.instant();
		for (GroupMember member : members.findById_GroupIdAndLeftAtIsNull(groupId)) {
			if (!wanted.remove(member.getId().getStudentId())) {
				member.setLeftAt(now);
			}
		}
		for (UUID studentId : wanted) {
			join(group.getId(), studentId, now);
		}
		return detail(groupId);
	}

	/** Puts a student in groups, leaving the others (student form). */
	@Transactional
	public void setGroupsOf(UUID studentId, Collection<UUID> groupIds) {
		Set<UUID> wanted = new HashSet<>(groupIds);
		UUID me = teacher.id();
		if (groups.findAllById(wanted).stream().filter(g -> me.equals(g.getTeacherId())).count() != wanted.size()) {
			throw ApiException.notFound("group_not_found");
		}
		Instant now = clock.instant();
		for (GroupMember member : members.findById_StudentIdAndLeftAtIsNull(studentId)) {
			if (!wanted.remove(member.getId().getGroupId())) {
				member.setLeftAt(now);
			}
		}
		for (UUID groupId : wanted) {
			join(groupId, studentId, now);
		}
	}

	/** "Prénom Nom · Matière", private, with the student as its only member. */
	@Transactional
	public GroupResponse createPrivateLesson(PrivateLessonRequest request) {
		UUID me = teacher.id();
		Student student = students.findWithUser(request.studentId())
				.filter(s -> me.equals(s.getTeacherId()))
				.orElseThrow(() -> ApiException.notFound("student_not_found"));
		Subject subject = subject(request.subjectId());
		SchoolYear year = currentYear();
		ClassGroup group = groups.save(ClassGroup.builder()
				.teacherId(me)
				.schoolYear(year)
				.subject(subject)
				.level(student.getLevel())
				.name(student.getUser().getFirstName() + " " + student.getUser().getLastName() + " · " + subject.getNameFr())
				.privateLesson(true)
				.color(PALETTE.get(3))
				.build());
		join(group.getId(), student.getId(), clock.instant());
		return toResponses(List.of(group)).getFirst();
	}

	/** One of the signed-in teacher's groups, not archived. */
	public ClassGroup require(UUID groupId) {
		UUID me = teacher.id();
		return groups.findById(groupId)
				.filter(g -> me.equals(g.getTeacherId()) && g.getArchivedAt() == null)
				.orElseThrow(() -> ApiException.notFound("group_not_found"));
	}

	/** Whether the group, archived or not, is the signed-in teacher's. */
	public boolean owns(UUID groupId) {
		return groups.existsByIdAndTeacherId(groupId, teacher.id());
	}

	/** All of the signed-in teacher's groups, archived ones included. */
	public List<UUID> ownIds() {
		return groups.findIdsByTeacherId(teacher.id());
	}

	/** Group cards: names, members count and weekly schedule. */
	public List<GroupResponse> toResponses(List<ClassGroup> list) {
		Map<UUID, Long> counts = new HashMap<>();
		for (Object[] row : members.countActiveMembers()) {
			counts.put((UUID) row[0], (Long) row[1]);
		}
		LocalDate today = LocalDate.now(clock.withZone(properties.zoneId()));
		Map<UUID, List<ScheduleItem>> schedules = rules
				.findByGroupIdInAndEndsOnGreaterThanEqualOrderByWeekdayAscStartTimeAsc(
						list.stream().map(ClassGroup::getId).toList(), today)
				.stream()
				.collect(Collectors.groupingBy(RecurrenceRule::getGroupId, Collectors.mapping(GroupService::schedule, Collectors.toList())));
		return list.stream()
				.map(g -> new GroupResponse(
						g.getId(),
						g.getName(),
						code(g.getName()),
						g.getSubject().getId(),
						g.getSubject().name(),
						g.getLevel().getId(),
						g.getLevel().name(),
						g.isPrivateLesson(),
						g.getDefaultMeetUrl(),
						g.getColor(),
						counts.getOrDefault(g.getId(), 0L).intValue(),
						schedules.getOrDefault(g.getId(), List.of())))
				.toList();
	}

	/** "7ème A · Math" gives "7A", "Bac Math" gives "BM": the two-letter square of the sidebar. */
	public static String code(String name) {
		StringBuilder out = new StringBuilder(2);
		for (String word : name.split("[\\s·\\-]+")) {
			if (!word.isEmpty() && out.length() < 2) {
				out.appendCodePoint(Character.toUpperCase(word.codePointAt(0)));
			}
		}
		return out.toString();
	}

	/** Online links must be real web addresses; Meet by default but any https link works. */
	public static String meetUrl(String url) {
		if (url == null || url.isBlank()) {
			return null;
		}
		String trimmed = url.trim();
		if (!trimmed.startsWith("https://") || trimmed.length() < 12 || trimmed.contains(" ")) {
			throw ApiException.badRequest("invalid_meet_url");
		}
		return trimmed;
	}

	private static ScheduleItem schedule(RecurrenceRule rule) {
		return new ScheduleItem(rule.getId(), rule.getWeekday(), rule.getStartTime(), rule.getEndTime(), rule.getMode().name(), rule.getLocation());
	}

	private void join(UUID groupId, UUID studentId, Instant now) {
		GroupMember.Key key = new GroupMember.Key(groupId, studentId);
		GroupMember member = members.findById(key).orElseGet(() -> GroupMember.builder().id(key).build());
		// A new member, or one coming back: membership starts again today.
		if (member.getJoinedAt() == null || member.getLeftAt() != null) {
			member.setJoinedAt(now);
		}
		member.setLeftAt(null);
		members.save(member);
		homeworkJoins.joined(groupId, studentId);
	}

	private String nextColor(SchoolYear year) {
		return PALETTE.get((int) (groups.countBySchoolYear_IdAndTeacherId(year.getId(), teacher.id()) % PALETTE.size()));
	}

	private SchoolYear currentYear() {
		return schoolYears.ensureCurrent(LocalDate.now(clock.withZone(properties.zoneId())));
	}

	private Subject subject(UUID id) {
		return subjects.findByIdAndTeacherId(id, teacher.id()).orElseThrow(() -> ApiException.notFound("subject_not_found"));
	}

	private Level level(UUID id) {
		return levels.findById(id).orElseThrow(() -> ApiException.notFound("level_not_found"));
	}
}
