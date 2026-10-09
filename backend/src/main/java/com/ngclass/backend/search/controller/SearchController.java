package com.ngclass.backend.search.controller;

import com.ngclass.backend.search.dto.SearchDtos.SearchResults;
import com.ngclass.backend.search.service.SearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** The teacher's search (docs/HANDOVER.md, API). */
@RestController
@RequestMapping("/api/v1/search")
@PreAuthorize("hasRole('TEACHER')")
@RequiredArgsConstructor
public class SearchController {
	private final SearchService search;

	@GetMapping
	public SearchResults search(@RequestParam(defaultValue = "") String q) {
		return search.search(q);
	}
}
