package com.ngclass.backend.content.controller;

import com.ngclass.backend.content.dto.ContentDtos.ContentItemResponse;
import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.dto.ContentDtos.LibraryResponse;
import com.ngclass.backend.content.dto.ContentDtos.ShareRequest;
import com.ngclass.backend.content.dto.ContentDtos.UpdateRequest;
import com.ngclass.backend.content.dto.ContentDtos.UploadRequest;
import com.ngclass.backend.content.service.ContentService;
import com.ngclass.backend.content.service.MyContentService;
import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/** The teacher's documents (spec 04); the viewer links are open to whoever may read the document. */
@RestController
@RequestMapping("/api/v1/contents")
@RequiredArgsConstructor
public class ContentController {
	private final ContentService contents;
	private final MyContentService viewer;

	@GetMapping
	@PreAuthorize("hasRole('TEACHER')")
	public LibraryResponse library() {
		return contents.library();
	}

	/** Two parts: "file" and "meta" (JSON, UploadRequest). */
	@PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	@PreAuthorize("hasRole('TEACHER')")
	@ResponseStatus(HttpStatus.CREATED)
	public ContentItemResponse upload(@RequestPart("file") MultipartFile file, @Valid @RequestPart("meta") UploadRequest meta) {
		return contents.upload(ContentService.bytes(file), file.getOriginalFilename(), meta);
	}

	@PutMapping("/{id}")
	@PreAuthorize("hasRole('TEACHER')")
	public ContentItemResponse update(@PathVariable UUID id, @Valid @RequestBody UpdateRequest request) {
		return contents.update(id, request);
	}

	@PutMapping("/{id}/shares")
	@PreAuthorize("hasRole('TEACHER')")
	public ContentItemResponse share(@PathVariable UUID id, @Valid @RequestBody ShareRequest request) {
		return contents.share(id, request.groupIds());
	}

	@PostMapping("/{id}/archive")
	@PreAuthorize("hasRole('TEACHER')")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void archive(@PathVariable UUID id) {
		contents.archive(id);
	}

	@GetMapping("/{id}/view")
	@PreAuthorize("hasAnyRole('TEACHER', 'STUDENT', 'PARENT')")
	public ContentViewResponse view(@PathVariable UUID id) {
		return viewer.view(id);
	}
}
