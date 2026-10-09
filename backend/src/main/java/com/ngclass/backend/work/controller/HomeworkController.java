package com.ngclass.backend.work.controller;

import com.ngclass.backend.content.dto.ContentDtos.ContentViewResponse;
import com.ngclass.backend.content.service.ContentService;
import com.ngclass.backend.work.dto.HomeworkDtos.AssignRequest;
import com.ngclass.backend.work.dto.HomeworkDtos.AssignmentDetail;
import com.ngclass.backend.work.dto.HomeworkDtos.AssignmentItem;
import com.ngclass.backend.work.dto.HomeworkDtos.CorrectionRequest;
import com.ngclass.backend.work.dto.HomeworkDtos.CorrectionView;
import com.ngclass.backend.work.dto.HomeworkDtos.DeadlineRequest;
import com.ngclass.backend.work.dto.HomeworkDtos.MissingWork;
import com.ngclass.backend.work.dto.HomeworkDtos.ToCorrectGroup;
import com.ngclass.backend.work.service.CorrectionService;
import com.ngclass.backend.work.service.HomeworkService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
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

/** The teacher's homework (spec 06). */
@RestController
@RequestMapping("/api/v1/assignments")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class HomeworkController {
	private final HomeworkService homework;
	private final CorrectionService corrections;

	@GetMapping
	public List<AssignmentItem> list() {
		return homework.list();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public AssignmentItem create(@Valid @RequestBody AssignRequest request) {
		return homework.create(request);
	}

	@GetMapping("/{id}")
	public AssignmentDetail detail(@PathVariable UUID id) {
		return homework.detail(id);
	}

	@PutMapping("/{id}/deadline")
	public AssignmentItem deadline(@PathVariable UUID id, @Valid @RequestBody DeadlineRequest request) {
		return homework.changeDeadline(id, request.deadlineAt());
	}

	@PostMapping("/{id}/close")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void close(@PathVariable UUID id) {
		homework.close(id);
	}

	@GetMapping("/submissions/{submissionId}/view")
	public ContentViewResponse submission(@PathVariable UUID submissionId) {
		return homework.submissionView(submissionId);
	}

	// ── Correction (step 4) ──

	/** "À corriger": copies waiting, grouped by homework, the oldest first. */
	@GetMapping("/to-correct")
	public List<ToCorrectGroup> toCorrect() {
		return corrections.queue();
	}

	/** "Travail manquant" (Ma journée): homework past its deadline in the last two weeks, with who sent nothing. */
	@GetMapping("/missing")
	public List<MissingWork> missing() {
		return corrections.missing();
	}

	@GetMapping("/{id}/corrections/{studentId}")
	public CorrectionView correction(@PathVariable UUID id, @PathVariable UUID studentId) {
		return corrections.view(id, studentId);
	}

	@PutMapping("/{id}/corrections/{studentId}")
	public CorrectionView correct(@PathVariable UUID id, @PathVariable UUID studentId, @Valid @RequestBody CorrectionRequest request) {
		return corrections.correct(id, studentId, request);
	}

	@PutMapping(path = "/{id}/corrections/{studentId}/file", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public CorrectionView attach(@PathVariable UUID id, @PathVariable UUID studentId, @RequestPart("file") MultipartFile file) {
		return corrections.attach(id, studentId, ContentService.bytes(file), file.getOriginalFilename());
	}

	@DeleteMapping("/{id}/corrections/{studentId}/file")
	public CorrectionView detach(@PathVariable UUID id, @PathVariable UUID studentId) {
		return corrections.detach(id, studentId);
	}

	@GetMapping("/{id}/corrections/{studentId}/file/view")
	public ContentViewResponse correctionFile(@PathVariable UUID id, @PathVariable UUID studentId) {
		return corrections.fileView(id, studentId);
	}
}
