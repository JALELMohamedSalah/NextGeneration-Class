package com.ngclass.backend.content.controller;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.content.dto.ContentDtos.MyContentItem;
import com.ngclass.backend.content.service.MyContentService;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** "Cours": a pupil's documents, or a parent's view of one child's (studentId required for a parent). */
@RestController
@RequestMapping("/api/v1/me/contents")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'PARENT')")
public class MyContentController {
	private final MyContentService contents;

	@GetMapping
	public List<MyContentItem> mine(@AuthenticationPrincipal AuthenticatedUser user, @RequestParam(required = false) UUID studentId) {
		return contents.mine(user, studentId);
	}
}
