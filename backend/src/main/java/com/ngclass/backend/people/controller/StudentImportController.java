package com.ngclass.backend.people.controller;

import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportPreview;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportRequest;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportResult;
import com.ngclass.backend.people.service.StudentImportService;
import jakarta.validation.Valid;
import java.io.IOException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/** Importing pupils from Excel or CSV: check the file, then create the lines kept (docs/HANDOVER.md, API). */
@RestController
@RequestMapping("/api/v1/students/import")
@PreAuthorize("hasRole('TEACHER')")
@RequiredArgsConstructor
public class StudentImportController {
	private final StudentImportService imports;

	@PostMapping("/preview")
	public ImportPreview preview(@RequestPart("file") MultipartFile file, @RequestParam(required = false) UUID groupId,
			@RequestParam(required = false) UUID levelId) {
		try {
			return imports.preview(file.getBytes(), file.getOriginalFilename(), groupId, levelId);
		} catch (IOException e) {
			throw ApiException.badRequest("import_file_unreadable");
		}
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public ImportResult importLines(@Valid @RequestBody ImportRequest request) {
		return imports.importLines(request);
	}
}
