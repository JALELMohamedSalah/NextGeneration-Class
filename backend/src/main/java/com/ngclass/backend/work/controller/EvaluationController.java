package com.ngclass.backend.work.controller;

import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationDetail;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationItem;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationRequest;
import com.ngclass.backend.work.dto.EvaluationDtos.EvaluationUpdate;
import com.ngclass.backend.work.dto.EvaluationDtos.GradesRequest;
import com.ngclass.backend.work.service.EvaluationService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Paper evaluations (docs/HANDOVER.md, API). */
@RestController
@RequestMapping("/api/v1/evaluations")
@PreAuthorize("hasRole('TEACHER')")
@RequiredArgsConstructor
public class EvaluationController {
	private final EvaluationService evaluations;

	@GetMapping
	public List<EvaluationItem> list() {
		return evaluations.list();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public EvaluationDetail create(@Valid @RequestBody EvaluationRequest request) {
		return evaluations.create(request);
	}

	@GetMapping("/{id}")
	public EvaluationDetail detail(@PathVariable UUID id) {
		return evaluations.detail(id);
	}

	@PutMapping("/{id}")
	public EvaluationDetail update(@PathVariable UUID id, @Valid @RequestBody EvaluationUpdate update) {
		return evaluations.update(id, update);
	}

	@PutMapping("/{id}/grades")
	public EvaluationDetail saveGrades(@PathVariable UUID id, @Valid @RequestBody GradesRequest request) {
		return evaluations.saveGrades(id, request.grades());
	}
}
