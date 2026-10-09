package com.ngclass.backend.planning.controller;

import com.ngclass.backend.planning.dto.PlanningDtos.AttendanceRequest;
import com.ngclass.backend.planning.dto.PlanningDtos.CancelRequest;
import com.ngclass.backend.planning.dto.PlanningDtos.CreatedSessions;
import com.ngclass.backend.planning.dto.PlanningDtos.NotesRequest;
import com.ngclass.backend.planning.dto.PlanningDtos.Scope;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionDetail;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionRequest;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionResponse;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionUpdate;
import com.ngclass.backend.planning.service.PlanningService;
import jakarta.validation.Valid;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class PlanningController {
	private final PlanningService planning;

	@GetMapping("/sessions")
	public List<SessionResponse> list(
			@RequestParam Instant from,
			@RequestParam Instant to,
			@RequestParam(required = false) UUID groupId) {
		return planning.list(from, to, groupId);
	}

	@GetMapping("/sessions/{id}")
	public SessionDetail detail(@PathVariable UUID id) {
		return planning.detail(id);
	}

	@GetMapping("/sessions/overlaps")
	public List<SessionResponse> overlaps(
			@RequestParam LocalDate date,
			@RequestParam LocalTime start,
			@RequestParam LocalTime end,
			@RequestParam(required = false) UUID exclude) {
		return planning.overlaps(date, start, end, exclude);
	}

	@PostMapping("/sessions")
	@ResponseStatus(HttpStatus.CREATED)
	public CreatedSessions create(@Valid @RequestBody SessionRequest request) {
		return planning.create(request);
	}

	@PutMapping("/sessions/{id}")
	public SessionResponse update(
			@PathVariable UUID id,
			@RequestParam(defaultValue = "ONE") Scope scope,
			@Valid @RequestBody SessionUpdate update) {
		return planning.update(id, scope, update);
	}

	@PostMapping("/sessions/{id}/cancel")
	public SessionResponse cancel(
			@PathVariable UUID id,
			@RequestParam(defaultValue = "ONE") Scope scope,
			@Valid @RequestBody(required = false) CancelRequest request) {
		return planning.cancel(id, scope, request == null ? null : request.reason());
	}

	@PostMapping("/sessions/{id}/restore")
	public SessionResponse restore(@PathVariable UUID id) {
		return planning.restore(id);
	}

	@PostMapping("/sessions/{id}/start")
	public SessionDetail start(@PathVariable UUID id) {
		return planning.start(id);
	}

	@PostMapping("/sessions/{id}/end")
	public SessionDetail end(@PathVariable UUID id) {
		return planning.end(id);
	}

	@PutMapping("/sessions/{id}/attendance")
	public SessionDetail attendance(@PathVariable UUID id, @Valid @RequestBody AttendanceRequest request) {
		return planning.saveAttendance(id, request.entries());
	}

	@PutMapping("/sessions/{id}/notes")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void notes(@PathVariable UUID id, @Valid @RequestBody NotesRequest request) {
		planning.saveNotes(id, request);
	}

	@DeleteMapping("/recurrence-rules/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deleteRule(@PathVariable UUID id) {
		planning.deleteRule(id);
	}
}
