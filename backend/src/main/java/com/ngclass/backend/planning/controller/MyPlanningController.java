package com.ngclass.backend.planning.controller;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.planning.dto.PlanningDtos.MySession;
import com.ngclass.backend.planning.service.MyPlanningService;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** A student's own sessions; a parent passes the child's id. */
@RestController
@RequestMapping("/api/v1/me")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'PARENT')")
public class MyPlanningController {
	private final MyPlanningService myPlanning;

	@GetMapping("/sessions")
	public List<MySession> sessions(
			@AuthenticationPrincipal AuthenticatedUser user,
			@RequestParam Instant from,
			@RequestParam Instant to,
			@RequestParam(required = false) UUID studentId) {
		return myPlanning.sessions(user, studentId, from, to);
	}
}
