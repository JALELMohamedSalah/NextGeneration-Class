package com.ngclass.backend.admin.controller;

import com.ngclass.backend.admin.dto.AdminDtos.CreatedTeacher;
import com.ngclass.backend.admin.dto.AdminDtos.TeacherCredential;
import com.ngclass.backend.admin.dto.AdminDtos.TeacherRequest;
import com.ngclass.backend.admin.dto.AdminDtos.TeachersPage;
import com.ngclass.backend.admin.service.AdminService;
import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** The owner's dashboard (docs/HANDOVER.md, API). */
@RestController
@RequestMapping("/api/v1/admin/teachers")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {
	private final AdminService admin;

	@GetMapping
	public TeachersPage list() {
		return admin.teachers();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public CreatedTeacher create(@Valid @RequestBody TeacherRequest request) {
		return admin.create(request);
	}

	@PostMapping("/{id}/reset-password")
	public TeacherCredential resetPassword(@PathVariable UUID id) {
		return admin.resetPassword(id);
	}

	@PostMapping("/{id}/disable")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void disable(@PathVariable UUID id) {
		admin.setActive(id, false);
	}

	@PostMapping("/{id}/enable")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void enable(@PathVariable UUID id) {
		admin.setActive(id, true);
	}
}
