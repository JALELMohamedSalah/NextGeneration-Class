package com.ngclass.backend.admin.service;

import com.ngclass.backend.admin.dto.AdminDtos.CreatedTeacher;
import com.ngclass.backend.admin.dto.AdminDtos.TeacherCredential;
import com.ngclass.backend.admin.dto.AdminDtos.TeacherItem;
import com.ngclass.backend.admin.dto.AdminDtos.TeacherRequest;
import com.ngclass.backend.admin.dto.AdminDtos.TeachersPage;
import com.ngclass.backend.admin.dto.AdminDtos.Totals;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.RefreshTokenRepository;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.auth.service.Credentials;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The owner of the platform adds teachers, gives them a temporary password, and closes or reopens
 * their access. Each teacher then works in her own space (V6); the owner never sees inside it.
 */
@Service
@RequiredArgsConstructor
public class AdminService {
	private static final Pattern USERNAME = Pattern.compile("[a-z0-9][a-z0-9._-]{2,63}");

	private final UserRepository users;
	private final StudentRepository students;
	private final ParentRepository parents;
	private final ClassGroupRepository groups;
	private final RefreshTokenRepository refreshTokens;
	private final PasswordEncoder passwordEncoder;

	@Transactional(readOnly = true)
	public TeachersPage teachers() {
		Map<UUID, Long> pupils = counts(students.countActiveByTeacher());
		Map<UUID, Long> families = counts(parents.countActiveByTeacher());
		Map<UUID, Long> classes = counts(groups.countActiveByTeacher());
		List<TeacherItem> items = users.findByRoleOrderByCreatedAtAsc(Role.TEACHER).stream()
				.map(u -> item(u, pupils.getOrDefault(u.getId(), 0L), families.getOrDefault(u.getId(), 0L), classes.getOrDefault(u.getId(), 0L)))
				.toList();
		Totals totals = new Totals(
				items.size(),
				items.stream().filter(TeacherItem::active).count(),
				items.stream().mapToLong(TeacherItem::students).sum(),
				items.stream().mapToLong(TeacherItem::parents).sum(),
				items.stream().mapToLong(TeacherItem::groups).sum());
		return new TeachersPage(totals, items);
	}

	/** A new teacher with an empty space and a temporary password, to replace at her first login. */
	@Transactional
	public CreatedTeacher create(TeacherRequest request) {
		String username = Credentials.normalizeUsername(request.username());
		if (!USERNAME.matcher(username).matches()) {
			throw ApiException.badRequest("invalid_username");
		}
		if (users.existsByUsername(username)) {
			throw ApiException.badRequest("username_taken", username);
		}
		String phone = phone(request.phone());
		String temporary = Credentials.temporaryPassword();
		User user = users.save(User.builder()
				.role(Role.TEACHER)
				.username(username)
				.phone(phone)
				.email(blank(request.email()) ? null : request.email().trim())
				.firstName(request.firstName().trim())
				.lastName(request.lastName().trim())
				.passwordHash(passwordEncoder.encode(temporary))
				.mustChangePassword(true)
				.build());
		return new CreatedTeacher(item(user, 0, 0, 0), credential(user, temporary));
	}

	/** A forgotten password: a new temporary one, every device signed out. */
	@Transactional
	public TeacherCredential resetPassword(UUID teacherId) {
		User user = teacher(teacherId);
		String temporary = Credentials.temporaryPassword();
		user.setPasswordHash(passwordEncoder.encode(temporary));
		user.setMustChangePassword(true);
		user.setFailedLoginAttempts(0);
		user.setLockedUntil(null);
		refreshTokens.revokeAllForUser(user.getId());
		return credential(user, temporary);
	}

	/** Closing signs her out everywhere; her pupils and their parents keep their access. Nothing is deleted. */
	@Transactional
	public void setActive(UUID teacherId, boolean active) {
		User user = teacher(teacherId);
		user.setActive(active);
		if (!active) {
			refreshTokens.revokeAllForUser(user.getId());
		}
	}

	private User teacher(UUID id) {
		return users.findById(id)
				.filter(u -> u.getRole() == Role.TEACHER)
				.orElseThrow(() -> ApiException.notFound("teacher_not_found"));
	}

	private String phone(String phone) {
		if (blank(phone)) {
			return null;
		}
		String digits = Credentials.phoneDigits(phone).orElseThrow(() -> ApiException.badRequest("invalid_phone"));
		// A phone also signs in: it must be free as a phone and as a username.
		if (users.existsByPhone(digits) || users.existsByUsername(digits)) {
			throw ApiException.badRequest("phone_taken", digits);
		}
		return digits;
	}

	private static TeacherItem item(User u, long students, long parents, long groups) {
		return new TeacherItem(
				u.getId(),
				u.getFirstName(),
				u.getLastName(),
				u.getUsername(),
				u.getPhone(),
				u.getEmail(),
				u.isActive(),
				u.isMustChangePassword(),
				u.getLastLoginAt(),
				u.getCreatedAt(),
				students,
				parents,
				groups);
	}

	private static TeacherCredential credential(User user, String temporary) {
		return new TeacherCredential(user.getId(), user.getFirstName(), user.getLastName(), user.getUsername(), temporary);
	}

	private static Map<UUID, Long> counts(List<Object[]> rows) {
		Map<UUID, Long> out = new HashMap<>();
		for (Object[] row : rows) {
			out.put((UUID) row[0], (Long) row[1]);
		}
		return out;
	}

	private static boolean blank(String value) {
		return value == null || value.isBlank();
	}
}
