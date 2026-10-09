package com.ngclass.backend.people.service;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.RefreshTokenRepository;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.auth.service.Credentials;
import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.people.dto.ResetPasswordResponse;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** What the teacher does on student and parent accounts. */
@Service
@RequiredArgsConstructor
public class AccountService {
	private final UserRepository users;
	private final RefreshTokenRepository refreshTokens;
	private final PasswordEncoder passwordEncoder;
	private final StudentRepository students;
	private final ParentRepository parents;
	private final CurrentTeacher teacher;

	/**
	 * A forgotten password: a new temporary one, unlocked, every signed-in device signed out,
	 * and the user chooses their own password at the next login.
	 */
	@Transactional
	public ResetPasswordResponse resetPassword(UUID userId) {
		User user = users.findById(userId).orElseThrow(() -> ApiException.notFound("user_not_found"));
		if (user.getRole() == Role.TEACHER || user.getRole() == Role.ADMIN) {
			throw ApiException.badRequest("teacher_password_reset");
		}
		// Only her own pupils and parents.
		UUID me = teacher.id();
		boolean hers = user.getRole() == Role.STUDENT
				? students.findByUser_Id(userId).filter(s -> me.equals(s.getTeacherId())).isPresent()
				: parents.findByUser_Id(userId).filter(p -> me.equals(p.getTeacherId())).isPresent();
		if (!hers) {
			throw ApiException.notFound("user_not_found");
		}
		if (!user.isLoginEnabled()) {
			throw ApiException.badRequest("login_not_enabled");
		}
		String temporaryPassword = Credentials.temporaryPassword();
		user.setPasswordHash(passwordEncoder.encode(temporaryPassword));
		user.setMustChangePassword(true);
		user.setFailedLoginAttempts(0);
		user.setLockedUntil(null);
		refreshTokens.revokeAllForUser(userId);
		return new ResetPasswordResponse(user.getId(), user.getUsername(), temporaryPassword);
	}
}
