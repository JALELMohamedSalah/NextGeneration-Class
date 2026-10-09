package com.ngclass.backend.work.controller;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.service.ContentService;
import com.ngclass.backend.work.dto.HomeworkDtos.MyHomework;
import com.ngclass.backend.work.dto.HomeworkDtos.MyHomeworkDetail;
import com.ngclass.backend.work.service.MyHomeworkService;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/** "Devoirs" of a pupil, or of a parent's child (studentId required for a parent, who may also send the work). */
@RestController
@RequestMapping("/api/v1/me/assignments")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'PARENT')")
public class MyHomeworkController {
	private final MyHomeworkService homework;

	@GetMapping
	public List<MyHomework> mine(@AuthenticationPrincipal AuthenticatedUser user, @RequestParam(required = false) UUID studentId) {
		return homework.mine(user, studentId);
	}

	@GetMapping("/{id}")
	public MyHomeworkDetail detail(@AuthenticationPrincipal AuthenticatedUser user, @PathVariable UUID id, @RequestParam(required = false) UUID studentId) {
		return homework.detail(user, id, studentId);
	}

	@PostMapping(path = "/{id}/submission", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public MyHomeworkDetail submit(
			@AuthenticationPrincipal AuthenticatedUser user,
			@PathVariable UUID id,
			@RequestParam(required = false) UUID studentId,
			@RequestPart("file") MultipartFile file) {
		return homework.submit(user, id, studentId, ContentService.bytes(file), file.getOriginalFilename());
	}

	@GetMapping("/{id}/submission/view")
	public ContentViewResponse submission(@AuthenticationPrincipal AuthenticatedUser user, @PathVariable UUID id, @RequestParam(required = false) UUID studentId) {
		return homework.submissionView(user, id, studentId);
	}

	/** The teacher's corrected copy, once corrected. */
	@GetMapping("/{id}/correction/view")
	public ContentViewResponse correction(@AuthenticationPrincipal AuthenticatedUser user, @PathVariable UUID id, @RequestParam(required = false) UUID studentId) {
		return homework.correctionView(user, id, studentId);
	}
}
