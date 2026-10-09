package com.ngclass.backend.people.controller;

import com.ngclass.backend.people.dto.StudentDtos.CreatedStudent;
import com.ngclass.backend.people.dto.StudentDtos.Credential;
import com.ngclass.backend.people.dto.StudentDtos.NoteRequest;
import com.ngclass.backend.people.dto.StudentDtos.NoteResponse;
import com.ngclass.backend.people.dto.StudentDtos.ParentRow;
import com.ngclass.backend.people.dto.StudentDtos.StudentDetail;
import com.ngclass.backend.people.dto.StudentDtos.StudentRequest;
import com.ngclass.backend.people.dto.StudentDtos.StudentRow;
import com.ngclass.backend.people.dto.StudentDtos.UsernameSuggestion;
import com.ngclass.backend.people.service.StudentService;
import jakarta.validation.Valid;
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

/** Teacher only. Students and parents read their own data through /me endpoints with separate DTOs. */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class StudentController {
	private final StudentService studentService;

	@GetMapping("/students")
	public List<StudentRow> list(@RequestParam(defaultValue = "false") boolean archived) {
		return studentService.list(archived);
	}

	@GetMapping("/students/{id}")
	public StudentDetail detail(@PathVariable UUID id) {
		return studentService.detail(id);
	}

	@PostMapping("/students")
	@ResponseStatus(HttpStatus.CREATED)
	public CreatedStudent create(@Valid @RequestBody StudentRequest request) {
		return studentService.create(request);
	}

	@PutMapping("/students/{id}")
	public CreatedStudent update(@PathVariable UUID id, @Valid @RequestBody StudentRequest request) {
		return studentService.update(id, request);
	}

	@PostMapping("/students/{id}/archive")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void archive(@PathVariable UUID id) {
		studentService.archive(id);
	}

	/** Opens the child's own access; the login details come back once. */
	@PostMapping("/students/{id}/login")
	public Credential enableLogin(@PathVariable UUID id) {
		return studentService.enableLogin(id);
	}

	@DeleteMapping("/students/{id}/login")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void disableLogin(@PathVariable UUID id) {
		studentService.disableLogin(id);
	}

	@PostMapping("/students/{id}/restore")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void restore(@PathVariable UUID id) {
		studentService.restore(id);
	}

	/** Live check while typing the student form. */
	@GetMapping("/students/username-suggestion")
	public UsernameSuggestion suggestUsername(
			@RequestParam(required = false) String firstName,
			@RequestParam(required = false) String lastName,
			@RequestParam(required = false) String username) {
		return studentService.suggestUsername(firstName, lastName, username);
	}

	@GetMapping("/students/{id}/private-notes")
	public List<NoteResponse> privateNotes(@PathVariable UUID id) {
		return studentService.privateNotes(id);
	}

	@PostMapping("/students/{id}/private-notes")
	@ResponseStatus(HttpStatus.CREATED)
	public NoteResponse addPrivateNote(@PathVariable UUID id, @Valid @RequestBody NoteRequest request) {
		return studentService.addPrivateNote(id, request.body());
	}

	@PutMapping("/students/{id}/private-notes/{noteId}")
	public NoteResponse editPrivateNote(@PathVariable UUID id, @PathVariable UUID noteId, @Valid @RequestBody NoteRequest request) {
		return studentService.editPrivateNote(id, noteId, request.body());
	}

	@DeleteMapping("/students/{id}/private-notes/{noteId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deletePrivateNote(@PathVariable UUID id, @PathVariable UUID noteId) {
		studentService.deletePrivateNote(id, noteId);
	}

	@GetMapping("/students/{id}/comments")
	public List<NoteResponse> comments(@PathVariable UUID id) {
		return studentService.comments(id);
	}

	@PostMapping("/students/{id}/comments")
	@ResponseStatus(HttpStatus.CREATED)
	public NoteResponse addComment(@PathVariable UUID id, @Valid @RequestBody NoteRequest request) {
		return studentService.addComment(id, request.body());
	}

	@GetMapping("/parents")
	public List<ParentRow> parents() {
		return studentService.parentsList();
	}
}
