package com.ngclass.backend.people.service;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.RefreshTokenRepository;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.auth.service.Credentials;
import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.domain.GroupMember;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.GroupMemberRepository;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.people.domain.Comment;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.PrivateNote;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.dto.StudentDtos.AttendanceMark;
import com.ngclass.backend.people.dto.StudentDtos.AttendanceSummary;
import com.ngclass.backend.people.dto.StudentDtos.CreatedStudent;
import com.ngclass.backend.people.dto.StudentDtos.Credential;
import com.ngclass.backend.people.dto.StudentDtos.GroupTag;
import com.ngclass.backend.people.dto.StudentDtos.NoteResponse;
import com.ngclass.backend.people.dto.StudentDtos.ParentInput;
import com.ngclass.backend.people.dto.StudentDtos.ParentRow;
import com.ngclass.backend.people.dto.StudentDtos.ParentTag;
import com.ngclass.backend.people.dto.StudentDtos.StudentDetail;
import com.ngclass.backend.people.dto.StudentDtos.StudentRequest;
import com.ngclass.backend.people.dto.StudentDtos.StudentRow;
import com.ngclass.backend.people.dto.StudentDtos.UpcomingSession;
import com.ngclass.backend.people.dto.StudentDtos.UsernameSuggestion;
import com.ngclass.backend.people.repository.CommentRepository;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.PrivateNoteRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.planning.domain.AttendanceStatus;
import com.ngclass.backend.planning.domain.ClassSession;
import com.ngclass.backend.planning.domain.SessionStatus;
import com.ngclass.backend.planning.repository.AttendanceRepository;
import com.ngclass.backend.planning.repository.ClassSessionRepository;
import com.ngclass.backend.planning.service.AttendanceStats;
import com.ngclass.backend.school.domain.Level;
import com.ngclass.backend.school.repository.LevelRepository;
import java.text.Normalizer;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Students and their parents, as the teacher manages them (docs/02-specification/02-students-groups.md). */
@Service
@RequiredArgsConstructor
public class StudentService {
	private static final Pattern USERNAME = Pattern.compile("[a-z0-9][a-z0-9._-]{2,63}");
	private static final int MAX_PARENTS = 2;

	private final StudentRepository students;
	private final ParentRepository parents;
	private final UserRepository users;
	private final RefreshTokenRepository refreshTokens;
	private final LevelRepository levels;
	private final ClassGroupRepository groups;
	private final GroupMemberRepository members;
	private final GroupService groupService;
	private final PrivateNoteRepository privateNotes;
	private final CommentRepository comments;
	private final FamilyAccess family;
	private final ClassSessionRepository sessions;
	private final AttendanceRepository attendance;
	private final AttendanceStats attendanceStats;
	private final PasswordEncoder passwordEncoder;
	private final Clock clock;
	private final CurrentTeacher teacher;

	@Transactional(readOnly = true)
	public List<StudentRow> list(boolean archived) {
		return rows(students.findAllForList(teacher.id(), archived));
	}

	@Transactional(readOnly = true)
	public StudentDetail detail(UUID studentId) {
		Student student = require(studentId);
		StudentRow row = rows(List.of(student)).getFirst();
		AttendanceStats.Summary stats = attendanceStats.of(List.of(studentId)).get(studentId);
		List<AttendanceMark> recent = attendance.findRecent(studentId).stream()
				.map(r -> new AttendanceMark((Instant) r[0], ((AttendanceStatus) r[1]).name()))
				.toList();
		List<UUID> groupIds = row.groups().stream().map(GroupTag::id).toList();
		Map<UUID, GroupTag> tags = row.groups().stream().collect(Collectors.toMap(GroupTag::id, Function.identity()));
		List<UpcomingSession> next = groupIds.isEmpty() ? List.of() : sessions
				.findByGroupIdInAndStartsAtGreaterThanEqualAndStatusNotOrderByStartsAtAsc(groupIds, clock.instant(), SessionStatus.CANCELLED)
				.stream()
				.limit(3)
				.map(s -> upcoming(s, tags.get(s.getGroupId())))
				.toList();
		return new StudentDetail(
				row,
				student.getUser().getLastLoginAt(),
				new AttendanceSummary(stats.present(), stats.absent(), stats.late(), stats.rate(), recent),
				next);
	}

	/** One form: the student, their groups and up to two parents. Every new account gets a temporary password. */
	@Transactional
	public CreatedStudent create(StudentRequest request) {
		List<Credential> credentials = new ArrayList<>();
		Level level = level(request.levelId());
		String username = request.username() == null || request.username().isBlank()
				? nextFreeUsername(request.firstName(), request.lastName())
				: checkedUsername(request.username(), null);
		boolean login = request.createLogin() == null || request.createLogin();
		// Without a login the password is random and never shown: nobody can sign in with it.
		String temporary = Credentials.temporaryPassword();
		User user = users.save(User.builder()
				.role(Role.STUDENT)
				.username(username)
				.phone(checkedPhone(request.phone(), null, false))
				.firstName(request.firstName().trim())
				.lastName(request.lastName().trim())
				.passwordHash(passwordEncoder.encode(temporary))
				.mustChangePassword(true)
				.loginEnabled(login)
				.build());
		if (login) {
			credentials.add(credential(user, temporary));
		}
		Student student = students.save(Student.builder().teacherId(teacher.id()).user(user).level(level).build());
		groupService.setGroupsOf(student.getId(), nonNull(request.groupIds()));
		linkParents(student, nonNull(request.parents()), credentials);
		return new CreatedStudent(rows(List.of(student)).getFirst(), credentials);
	}

	/** Edits the student and their groups. New parents can be added here too; existing links stay. */
	@Transactional
	public CreatedStudent update(UUID studentId, StudentRequest request) {
		Student student = require(studentId);
		User user = student.getUser();
		user.setFirstName(request.firstName().trim());
		user.setLastName(request.lastName().trim());
		user.setPhone(checkedPhone(request.phone(), user.getId(), false));
		if (request.username() != null && !request.username().isBlank()) {
			user.setUsername(checkedUsername(request.username(), user.getId()));
		}
		student.setLevel(level(request.levelId()));
		if (request.groupIds() != null) {
			groupService.setGroupsOf(studentId, request.groupIds());
		}
		List<Credential> credentials = new ArrayList<>();
		if (request.createLogin() != null && request.createLogin() != user.isLoginEnabled()) {
			if (request.createLogin()) {
				credentials.add(openLogin(user));
			} else {
				closeLogin(user);
			}
		}
		linkParents(student, nonNull(request.parents()), credentials);
		return new CreatedStudent(rows(List.of(student)).getFirst(), credentials);
	}

	/** Gives a child their own access: a temporary password, to replace at the first login. */
	@Transactional
	public Credential enableLogin(UUID studentId) {
		User user = require(studentId).getUser();
		if (user.isLoginEnabled()) {
			throw new ApiException(HttpStatus.CONFLICT, "login_already_enabled");
		}
		return openLogin(user);
	}

	/** The child stops signing in; parents keep following. Nothing is deleted. */
	@Transactional
	public void disableLogin(UUID studentId) {
		closeLogin(require(studentId).getUser());
	}

	private Credential openLogin(User user) {
		String temporary = Credentials.temporaryPassword();
		user.setPasswordHash(passwordEncoder.encode(temporary));
		user.setMustChangePassword(true);
		user.setLoginEnabled(true);
		user.setFailedLoginAttempts(0);
		user.setLockedUntil(null);
		return credential(user, temporary);
	}

	private void closeLogin(User user) {
		user.setLoginEnabled(false);
		refreshTokens.revokeAllForUser(user.getId());
	}

	/** The student cannot log in any more and leaves the lists; nothing is deleted. */
	@Transactional
	public void archive(UUID studentId) {
		Student student = require(studentId);
		student.setArchivedAt(clock.instant());
		student.getUser().setActive(false);
		refreshTokens.revokeAllForUser(student.getUser().getId());
		// A parent account closes when none of its children is active any more.
		for (Parent parent : parents.findByChildren(List.of(studentId))) {
			boolean anyActive = parent.getChildren().stream().anyMatch(c -> c.getArchivedAt() == null);
			if (!anyActive) {
				parent.getUser().setActive(false);
				refreshTokens.revokeAllForUser(parent.getUser().getId());
			}
		}
	}

	@Transactional
	public void restore(UUID studentId) {
		UUID me = teacher.id();
		Student student = students.findWithUser(studentId)
				.filter(s -> me.equals(s.getTeacherId()))
				.orElseThrow(() -> ApiException.notFound("student_not_found"));
		student.setArchivedAt(null);
		student.getUser().setActive(true);
		for (Parent parent : parents.findByChildren(List.of(studentId))) {
			parent.getUser().setActive(true);
		}
	}

	@Transactional(readOnly = true)
	public UsernameSuggestion suggestUsername(String firstName, String lastName, String wanted) {
		if (wanted != null && !wanted.isBlank()) {
			String normalized = Credentials.normalizeUsername(wanted);
			boolean valid = USERNAME.matcher(normalized).matches();
			return new UsernameSuggestion(normalized, valid && !users.existsByUsername(normalized));
		}
		return new UsernameSuggestion(nextFreeUsername(firstName, lastName), true);
	}

	@Transactional(readOnly = true)
	public List<ParentRow> parentsList() {
		return parents.findAllWithChildren(teacher.id()).stream()
				.map(p -> new ParentRow(
						p.getId(),
						p.getUser().getId(),
						p.getUser().getFirstName(),
						p.getUser().getLastName(),
						p.getUser().getPhone(),
						p.getChildren().stream().map(c -> c.getUser().getFirstName()).sorted().toList()))
				.toList();
	}

	// ── Private notes (teacher only) and comments (read by the student and parents) ──

	@Transactional(readOnly = true)
	public List<NoteResponse> privateNotes(UUID studentId) {
		require(studentId);
		return privateNotes.findByStudentIdOrderByCreatedAtDesc(studentId).stream()
				.map(n -> new NoteResponse(n.getId(), n.getBody(), n.getCreatedAt(), n.getUpdatedAt()))
				.toList();
	}

	@Transactional
	public NoteResponse addPrivateNote(UUID studentId, String body) {
		require(studentId);
		PrivateNote note = privateNotes.saveAndFlush(PrivateNote.builder().studentId(studentId).body(body.trim()).build());
		return new NoteResponse(note.getId(), note.getBody(), note.getCreatedAt(), note.getUpdatedAt());
	}

	@Transactional
	public NoteResponse editPrivateNote(UUID studentId, UUID noteId, String body) {
		require(studentId);
		PrivateNote note = privateNotes.findById(noteId)
				.filter(n -> n.getStudentId().equals(studentId))
				.orElseThrow(() -> ApiException.notFound("note_not_found"));
		note.setBody(body.trim());
		privateNotes.flush();
		return new NoteResponse(note.getId(), note.getBody(), note.getCreatedAt(), note.getUpdatedAt());
	}

	@Transactional
	public void deletePrivateNote(UUID studentId, UUID noteId) {
		require(studentId);
		PrivateNote note = privateNotes.findById(noteId)
				.filter(n -> n.getStudentId().equals(studentId))
				.orElseThrow(() -> ApiException.notFound("note_not_found"));
		privateNotes.delete(note);
	}

	@Transactional(readOnly = true)
	public List<NoteResponse> comments(UUID studentId) {
		require(studentId);
		return comments.findByStudentIdOrderByCreatedAtDesc(studentId).stream()
				.map(c -> new NoteResponse(c.getId(), c.getBody(), c.getCreatedAt(), c.getUpdatedAt()))
				.toList();
	}

	/** The comments for the pupil, or for a parent's child: what the teacher wrote "visible par l'élève et ses parents", latest first. */
	@Transactional(readOnly = true)
	public List<NoteResponse> familyComments(AuthenticatedUser user, UUID studentId) {
		Student child = family.child(user, studentId);
		return comments.findByStudentIdOrderByCreatedAtDesc(child.getId()).stream()
				.limit(20)
				.map(c -> new NoteResponse(c.getId(), c.getBody(), c.getCreatedAt(), c.getUpdatedAt()))
				.toList();
	}

	@Transactional
	public NoteResponse addComment(UUID studentId, String body) {
		require(studentId);
		Comment comment = comments.saveAndFlush(Comment.builder().studentId(studentId).body(body.trim()).build());
		return new NoteResponse(comment.getId(), comment.getBody(), comment.getCreatedAt(), comment.getUpdatedAt());
	}

	// ── Helpers ──

	/** One of the signed-in teacher's students, not archived. */
	public Student require(UUID studentId) {
		UUID me = teacher.id();
		return students.findWithUser(studentId)
				.filter(s -> me.equals(s.getTeacherId()) && s.getArchivedAt() == null)
				.orElseThrow(() -> ApiException.notFound("student_not_found"));
	}

	private void linkParents(Student student, List<ParentInput> inputs, List<Credential> credentials) {
		long already = parents.countParentsOf(student.getId());
		if (already + inputs.size() > MAX_PARENTS) {
			throw ApiException.badRequest("too_many_parents", MAX_PARENTS);
		}
		for (ParentInput input : inputs) {
			Parent parent;
			if (input.existingParentId() != null) {
				parent = parents.findById(input.existingParentId())
						.filter(p -> student.getTeacherId().equals(p.getTeacherId()))
						.orElseThrow(() -> ApiException.notFound("parent_not_found"));
				parent.getUser().setActive(true);
			} else {
				if (blank(input.firstName()) || blank(input.lastName())) {
					throw ApiException.badRequest("parent_name_required");
				}
				String phone = checkedPhone(input.phone(), null, true);
				String temporary = Credentials.temporaryPassword();
				User user = users.save(User.builder()
						.role(Role.PARENT)
						// Parents log in with their phone number (spec 02).
						.username(phone)
						.phone(phone)
						.email(blank(input.email()) ? null : input.email().trim())
						.firstName(input.firstName().trim())
						.lastName(input.lastName().trim())
						.passwordHash(passwordEncoder.encode(temporary))
						.mustChangePassword(true)
						.build());
				credentials.add(credential(user, temporary));
				parent = parents.save(Parent.builder().teacherId(student.getTeacherId()).user(user).build());
			}
			parent.getChildren().add(student);
			parents.flush();
			if (!blank(input.relation())) {
				parents.setRelation(parent.getId(), student.getId(), input.relation().trim());
			}
		}
	}

	private List<StudentRow> rows(List<Student> list) {
		if (list.isEmpty()) {
			return List.of();
		}
		Set<UUID> ids = list.stream().map(Student::getId).collect(Collectors.toSet());
		Map<UUID, List<UUID>> groupsOf = new HashMap<>();
		Set<UUID> groupIds = new HashSet<>();
		for (GroupMember m : members.findById_StudentIdInAndLeftAtIsNull(ids)) {
			groupsOf.computeIfAbsent(m.getId().getStudentId(), k -> new ArrayList<>()).add(m.getId().getGroupId());
			groupIds.add(m.getId().getGroupId());
		}
		Map<UUID, ClassGroup> groupById = groups.findByIdIn(groupIds).stream()
				.filter(g -> g.getArchivedAt() == null)
				.collect(Collectors.toMap(ClassGroup::getId, Function.identity()));
		Map<UUID, Map<UUID, String>> relations = new HashMap<>();
		for (Object[] r : parents.findRelations(ids)) {
			relations.computeIfAbsent((UUID) r[1], k -> new HashMap<>()).put((UUID) r[0], (String) r[2]);
		}
		Map<UUID, List<ParentTag>> parentsOf = new HashMap<>();
		for (Parent p : parents.findByChildren(ids)) {
			for (Student child : p.getChildren()) {
				if (ids.contains(child.getId())) {
					parentsOf.computeIfAbsent(child.getId(), k -> new ArrayList<>()).add(new ParentTag(
							p.getId(),
							p.getUser().getId(),
							p.getUser().getFirstName(),
							p.getUser().getLastName(),
							p.getUser().getPhone(),
							relations.getOrDefault(child.getId(), Map.of()).get(p.getId())));
				}
			}
		}
		Map<UUID, AttendanceStats.Summary> stats = attendanceStats.of(ids);
		return list.stream()
				.map(s -> {
					User u = s.getUser();
					List<GroupTag> tags = groupsOf.getOrDefault(s.getId(), List.of()).stream()
							.map(groupById::get)
							.filter(g -> g != null)
							.sorted(Comparator.comparing(ClassGroup::getName))
							.map(g -> new GroupTag(g.getId(), g.getName(), GroupService.code(g.getName()), g.getColor(), g.isPrivateLesson()))
							.toList();
					AttendanceStats.Summary summary = stats.get(s.getId());
					return new StudentRow(
							s.getId(),
							u.getId(),
							u.getFirstName(),
							u.getLastName(),
							u.getUsername(),
							u.getPhone(),
							s.getLevel().getId(),
							s.getLevel().name(),
							tags,
							parentsOf.getOrDefault(s.getId(), List.of()),
							u.isLoginEnabled(),
							s.getArchivedAt() != null,
							summary.rate(),
							summary.absent());
				})
				.toList();
	}

	private static UpcomingSession upcoming(ClassSession s, GroupTag group) {
		return new UpcomingSession(
				s.getId(),
				s.getGroupId(),
				group == null ? null : group.name(),
				group == null ? null : group.color(),
				s.getStartsAt(),
				s.getEndsAt(),
				s.getMode().name(),
				s.getLocation());
	}

	/** "Éya Ben Salah" gives "eya.bensalah", then "eya.bensalah2", "eya.bensalah3"... */
	String nextFreeUsername(String firstName, String lastName) {
		String base = slug(firstName) + "." + slug(lastName);
		if (base.length() < 3) {
			base = "eleve" + base;
		}
		Set<String> taken = new HashSet<>(users.findUsernamesLike(base));
		if (!taken.contains(base)) {
			return base;
		}
		int suffix = 2;
		while (taken.contains(base + suffix)) {
			suffix++;
		}
		return base + suffix;
	}

	static String slug(String text) {
		String plain = Normalizer.normalize(text == null ? "" : text, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
		return plain.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]", "");
	}

	private String checkedUsername(String username, UUID ownerId) {
		String normalized = Credentials.normalizeUsername(username);
		if (!USERNAME.matcher(normalized).matches()) {
			throw ApiException.badRequest("invalid_username");
		}
		boolean taken = ownerId == null ? users.existsByUsername(normalized) : users.existsByUsernameAndIdNot(normalized, ownerId);
		if (taken) {
			throw ApiException.badRequest("username_taken", normalized);
		}
		return normalized;
	}

	private String checkedPhone(String phone, UUID ownerId, boolean required) {
		if (blank(phone)) {
			if (required) {
				throw ApiException.badRequest("phone_required");
			}
			return null;
		}
		String digits = Credentials.phoneDigits(phone).orElseThrow(() -> ApiException.badRequest("invalid_phone"));
		boolean taken = ownerId == null ? users.existsByPhone(digits) : users.existsByPhoneAndIdNot(digits, ownerId);
		// A parent's phone is also their username: it must be free in both columns.
		if (taken || (ownerId == null && users.existsByUsername(digits))) {
			throw ApiException.badRequest("phone_taken", digits);
		}
		return digits;
	}

	private Level level(UUID id) {
		return levels.findById(id).orElseThrow(() -> ApiException.notFound("level_not_found"));
	}

	private static Credential credential(User user, String temporary) {
		return new Credential(user.getId(), user.getRole(), user.getFirstName(), user.getLastName(), user.getUsername(), temporary);
	}

	private static <T> List<T> nonNull(Collection<T> list) {
		return list == null ? List.of() : List.copyOf(list);
	}

	private static boolean blank(String value) {
		return value == null || value.isBlank();
	}
}
