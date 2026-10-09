package com.ngclass.backend.school.controller;

import com.ngclass.backend.school.dto.ReferenceResponse.SubjectItem;
import com.ngclass.backend.school.dto.SubjectRequest;
import com.ngclass.backend.school.dto.SubjectUsageItem;
import com.ngclass.backend.school.service.SubjectService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Everyone reads subjects through /reference; the teacher lists them with their use, creates and edits them here. */
@RestController
@RequestMapping("/api/v1/subjects")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class SubjectController {
	private final SubjectService subjectService;

	@GetMapping
	public List<SubjectUsageItem> list() {
		return subjectService.listWithUsage();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public SubjectItem create(@Valid @RequestBody SubjectRequest request) {
		return subjectService.create(request);
	}

	@PutMapping("/{id}")
	public SubjectItem update(@PathVariable UUID id, @Valid @RequestBody SubjectRequest request) {
		return subjectService.update(id, request);
	}

	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable UUID id) {
		subjectService.delete(id);
	}
}
