package com.ngclass.backend.auth.controller;

import com.ngclass.backend.auth.dto.AuthDtos.AuthResponse;
import com.ngclass.backend.auth.dto.AuthDtos.LoginRequest;
import com.ngclass.backend.auth.dto.AuthDtos.LogoutRequest;
import com.ngclass.backend.auth.dto.AuthDtos.RefreshRequest;
import com.ngclass.backend.auth.service.AuthService;
import jakarta.validation.Valid;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
	private final AuthService authService;

	/** [locale]: from Accept-Language; it becomes the user's language for server messages. */
	@PostMapping("/login")
	public AuthResponse login(@Valid @RequestBody LoginRequest request, Locale locale) {
		return authService.login(request, locale);
	}

	@PostMapping("/refresh")
	public AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
		return authService.refresh(request.refreshToken());
	}

	@PostMapping("/logout")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void logout(@RequestBody(required = false) LogoutRequest request) {
		authService.logout(request == null ? null : request.refreshToken());
	}
}
