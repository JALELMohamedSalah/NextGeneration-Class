package com.ngclass.backend.groups.controller;

import com.ngclass.backend.groups.dto.GroupDtos.GroupDetail;
import com.ngclass.backend.groups.dto.GroupDtos.GroupRequest;
import com.ngclass.backend.groups.dto.GroupDtos.GroupResponse;
import com.ngclass.backend.groups.dto.GroupDtos.MembersRequest;
import com.ngclass.backend.groups.dto.GroupDtos.PrivateLessonRequest;
import com.ngclass.backend.groups.service.GroupService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/groups")
@RequiredArgsConstructor
@PreAuthorize("hasRole('TEACHER')")
public class GroupController {
	private final GroupService groupService;

	@GetMapping
	public List<GroupResponse> list() {
		return groupService.list();
	}

	@GetMapping("/{id}")
	public GroupDetail detail(@PathVariable UUID id) {
		return groupService.detail(id);
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public GroupResponse create(@Valid @RequestBody GroupRequest request) {
		return groupService.create(request);
	}

	@PutMapping("/{id}")
	public GroupResponse update(@PathVariable UUID id, @Valid @RequestBody GroupRequest request) {
		return groupService.update(id, request);
	}

	@PostMapping("/{id}/archive")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void archive(@PathVariable UUID id) {
		groupService.archive(id);
	}

	@PutMapping("/{id}/members")
	public GroupDetail setMembers(@PathVariable UUID id, @Valid @RequestBody MembersRequest request) {
		return groupService.setMembers(id, request.studentIds());
	}

	@PostMapping("/private-lessons")
	@ResponseStatus(HttpStatus.CREATED)
	public GroupResponse createPrivateLesson(@Valid @RequestBody PrivateLessonRequest request) {
		return groupService.createPrivateLesson(request);
	}
}
