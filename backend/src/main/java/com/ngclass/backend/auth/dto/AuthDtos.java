package com.ngclass.backend.auth.dto;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.people.dto.ChildResponse;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.UUID;

/** Requests and responses of /auth and /me. */
public final class AuthDtos {
	private AuthDtos() {
	}

	/** [login] is a username or a Tunisian phone number. */
	public record LoginRequest(@NotBlank String login, @NotBlank String password) {
	}

	public record RefreshRequest(@NotBlank String refreshToken) {
	}

	public record LogoutRequest(String refreshToken) {
	}

	public record ChangePasswordRequest(@NotBlank String currentPassword, @NotBlank String newPassword) {
	}

	public record LanguageRequest(@NotBlank String language) {
	}

	/** [expiresIn]: seconds before the access token must be refreshed. */
	public record AuthResponse(String accessToken, String refreshToken, long expiresIn, MeResponse user) {
	}

	public record MeResponse(
			UUID id,
			Role role,
			String username,
			String firstName,
			String lastName,
			String phone,
			String email,
			String language,
			boolean mustChangePassword,
			List<ChildResponse> children) {
	}
}
