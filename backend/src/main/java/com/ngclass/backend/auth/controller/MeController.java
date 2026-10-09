package com.ngclass.backend.auth.controller;

import com.ngclass.backend.auth.dto.AuthDtos.ChangePasswordRequest;
import com.ngclass.backend.auth.dto.AuthDtos.LanguageRequest;
import com.ngclass.backend.auth.dto.AuthDtos.MeResponse;
import com.ngclass.backend.auth.service.AuthService;
import com.ngclass.backend.auth.service.AuthenticatedUser;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me")
@RequiredArgsConstructor
public class MeController {
	private final AuthService authService;

	@GetMapping
	public MeResponse me(@AuthenticationPrincipal AuthenticatedUser principal) {
		return authService.me(principal.id());
	}

	@PostMapping("/password")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void changePassword(
			@AuthenticationPrincipal AuthenticatedUser principal,
			@Valid @RequestBody ChangePasswordRequest request) {
		authService.changePassword(principal.id(), request);
	}

	@PutMapping("/language")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void updateLanguage(
			@AuthenticationPrincipal AuthenticatedUser principal,
			@Valid @RequestBody LanguageRequest request) {
		authService.updateLanguage(principal.id(), request.language());
	}
}
