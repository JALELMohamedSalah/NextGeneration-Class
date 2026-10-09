package com.ngclass.backend.work.controller;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.work.dto.ResultsDtos.MyResults;
import com.ngclass.backend.work.service.ResultsService;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** "Résultats" of a pupil, or of a parent's child (studentId required for a parent). */
@RestController
@RequestMapping("/api/v1/me/results")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'PARENT')")
public class ResultsController {
	private final ResultsService results;

	@GetMapping
	public MyResults mine(@AuthenticationPrincipal AuthenticatedUser user, @RequestParam(required = false) UUID studentId) {
		return results.of(user, studentId);
	}
}
