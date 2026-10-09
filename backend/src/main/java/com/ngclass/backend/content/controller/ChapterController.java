package com.ngclass.backend.content.controller;

import com.ngclass.backend.content.dto.ContentDtos.ChapterItem;
import com.ngclass.backend.content.dto.ContentDtos.ChapterRename;
import com.ngclass.backend.content.dto.ContentDtos.ChapterRequest;
import com.ngclass.backend.content.dto.ContentDtos.ShareRequest;
import com.ngclass.backend.content.service.ContentService;
import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Chapters of the library; the list comes with GET /contents. */
@RestController
@RequestMapping("/api/v1/chapters")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class ChapterController {
	private final ContentService contents;

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public ChapterItem create(@Valid @RequestBody ChapterRequest request) {
		return contents.createChapter(request);
	}

	@PutMapping("/{id}")
	public ChapterItem rename(@PathVariable UUID id, @Valid @RequestBody ChapterRename request) {
		return contents.renameChapter(id, request.title());
	}

	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable UUID id) {
		contents.deleteChapter(id);
	}

	@PutMapping("/{id}/shares")
	public ChapterItem share(@PathVariable UUID id, @Valid @RequestBody ShareRequest request) {
		return contents.shareChapter(id, request.groupIds());
	}
}
