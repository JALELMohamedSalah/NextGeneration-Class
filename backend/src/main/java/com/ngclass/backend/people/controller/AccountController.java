package com.ngclass.backend.people.controller;

import com.ngclass.backend.people.dto.ResetPasswordResponse;
import com.ngclass.backend.people.service.AccountService;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class AccountController {
	private final AccountService accountService;

	@PostMapping("/{id}/reset-password")
	@PreAuthorize("hasRole('TEACHER')")
	public ResetPasswordResponse resetPassword(@PathVariable UUID id) {
		return accountService.resetPassword(id);
	}
}
