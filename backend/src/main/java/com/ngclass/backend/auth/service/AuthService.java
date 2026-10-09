package com.ngclass.backend.auth.service;

import com.ngclass.backend.auth.domain.RefreshToken;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.dto.AuthDtos.AuthResponse;
import com.ngclass.backend.auth.dto.AuthDtos.ChangePasswordRequest;
import com.ngclass.backend.auth.dto.AuthDtos.LoginRequest;
import com.ngclass.backend.auth.dto.AuthDtos.MeResponse;
import com.ngclass.backend.auth.repository.RefreshTokenRepository;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.common.Languages;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.people.repository.ParentRepository;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {
	private final UserRepository users;
	private final RefreshTokenRepository refreshTokens;
	private final ParentRepository parents;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;
	private final AppProperties properties;
	private final Clock clock;
	private final SecureRandom random = new SecureRandom();

	/** A refused login still records the failed attempt, hence no rollback on ApiException. */
	@Transactional(noRollbackFor = ApiException.class)
	public AuthResponse login(LoginRequest request, Locale locale) {
		User user = findByLogin(request.login())
				.filter(User::isLoginEnabled)
				.orElseThrow(AuthService::invalidCredentials);
		Instant now = clock.instant();
		if (!user.isActive()) {
			// A teacher's access is closed by the owner of the platform, a child's or parent's by the teacher.
			throw new ApiException(HttpStatus.FORBIDDEN, user.getRole() == Role.TEACHER ? "teacher_disabled" : "account_disabled");
		}
		if (user.getLockedUntil() != null && user.getLockedUntil().isAfter(now)) {
			throw locked(user.getLockedUntil(), now);
		}
		if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
			int attempts = user.getFailedLoginAttempts() + 1;
			if (attempts >= properties.security().maxLoginAttempts()) {
				user.setFailedLoginAttempts(0);
				user.setLockedUntil(now.plus(properties.security().lockDuration()));
				throw locked(user.getLockedUntil(), now);
			}
			user.setFailedLoginAttempts(attempts);
			throw invalidCredentials();
		}
		user.setFailedLoginAttempts(0);
		user.setLockedUntil(null);
		user.setLastLoginAt(now);
		user.setLanguage(Languages.of(locale));
		return openSession(user, now);
	}

	/** Same refresh token back, valid one more year from now (client decision: stay signed in). */
	@Transactional
	public AuthResponse refresh(String rawToken) {
		Instant now = clock.instant();
		RefreshToken stored = refreshTokens.findByTokenHash(hash(rawToken))
				.filter(token -> !token.isRevoked() && token.getExpiresAt().isAfter(now))
				.orElseThrow(AuthService::invalidRefreshToken);
		User user = users.findById(stored.getUserId())
				.filter(u -> u.isActive() && u.isLoginEnabled())
				.orElseThrow(AuthService::invalidRefreshToken);
		stored.setExpiresAt(now.plus(properties.jwt().refreshTokenTtl()));
		return new AuthResponse(jwtService.createAccessToken(user), rawToken, jwtService.accessTokenTtlSeconds(), toMe(user));
	}

	@Transactional
	public void logout(String rawToken) {
		if (rawToken == null || rawToken.isBlank()) {
			return;
		}
		refreshTokens.findByTokenHash(hash(rawToken)).ifPresent(token -> token.setRevoked(true));
	}

	@Transactional(readOnly = true)
	public MeResponse me(UUID userId) {
		return toMe(requireUser(userId));
	}

	@Transactional
	public void changePassword(UUID userId, ChangePasswordRequest request) {
		User user = requireUser(userId);
		if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
			throw ApiException.badRequest("wrong_password");
		}
		if (!Credentials.isAcceptablePassword(request.newPassword())) {
			throw ApiException.badRequest("weak_password");
		}
		user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
		user.setMustChangePassword(false);
	}

	@Transactional
	public void updateLanguage(UUID userId, String language) {
		if (!Languages.isSupported(language)) {
			throw ApiException.badRequest("unsupported_language");
		}
		requireUser(userId).setLanguage(language);
	}

	private Optional<User> findByLogin(String login) {
		Optional<String> phone = Credentials.phoneDigits(login);
		return phone.isPresent()
				? users.findByPhone(phone.get())
				: users.findByUsername(Credentials.normalizeUsername(login));
	}

	private AuthResponse openSession(User user, Instant now) {
		byte[] bytes = new byte[32];
		random.nextBytes(bytes);
		String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
		refreshTokens.save(RefreshToken.builder()
				.tokenHash(hash(rawToken))
				.userId(user.getId())
				.expiresAt(now.plus(properties.jwt().refreshTokenTtl()))
				.build());
		return new AuthResponse(jwtService.createAccessToken(user), rawToken, jwtService.accessTokenTtlSeconds(), toMe(user));
	}

	private MeResponse toMe(User user) {
		return new MeResponse(
				user.getId(),
				user.getRole(),
				user.getUsername(),
				user.getFirstName(),
				user.getLastName(),
				user.getPhone(),
				user.getEmail(),
				user.getLanguage(),
				user.isMustChangePassword(),
				user.getRole() == Role.PARENT ? parents.findActiveChildrenOfUser(user.getId()) : List.of());
	}

	private User requireUser(UUID userId) {
		return users.findById(userId).orElseThrow(() -> ApiException.notFound("user_not_found"));
	}

	static String hash(String rawToken) {
		try {
			byte[] digest = MessageDigest.getInstance("SHA-256").digest(rawToken.getBytes(StandardCharsets.UTF_8));
			return HexFormat.of().formatHex(digest);
		} catch (NoSuchAlgorithmException ex) {
			throw new IllegalStateException(ex);
		}
	}

	private static ApiException invalidCredentials() {
		return new ApiException(HttpStatus.UNAUTHORIZED, "invalid_credentials");
	}

	private static ApiException invalidRefreshToken() {
		return new ApiException(HttpStatus.UNAUTHORIZED, "invalid_refresh_token");
	}

	private static ApiException locked(Instant until, Instant now) {
		long minutes = Math.max(1, (Duration.between(now, until).toSeconds() + 59) / 60);
		return new ApiException(HttpStatus.LOCKED, "account_locked", minutes);
	}
}
