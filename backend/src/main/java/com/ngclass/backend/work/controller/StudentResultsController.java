package com.ngclass.backend.work.controller;

import com.ngclass.backend.work.dto.ResultsDtos.MyResults;
import com.ngclass.backend.work.service.ResultsService;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** A pupil's "Résultats" for the teacher's Fiche élève (only her own pupils). */
@RestController
@RequestMapping("/api/v1/students")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class StudentResultsController {
	private final ResultsService results;

	@GetMapping("/{id}/results")
	public MyResults results(@PathVariable UUID id) {
		return results.forTeacher(id);
	}
}
