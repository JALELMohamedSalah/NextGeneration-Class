package com.ngclass.backend.people.controller;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.people.dto.StudentDtos.NoteResponse;
import com.ngclass.backend.people.service.StudentService;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** The teacher's comments on a pupil ("visible par l'élève et ses parents"), for the pupil or a parent's child. */
@RestController
@RequestMapping("/api/v1/me/comments")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'PARENT')")
public class MyCommentsController {
	private final StudentService students;

	@GetMapping
	public List<NoteResponse> mine(@AuthenticationPrincipal AuthenticatedUser user, @RequestParam(required = false) UUID studentId) {
		return students.familyComments(user, studentId);
	}
}
