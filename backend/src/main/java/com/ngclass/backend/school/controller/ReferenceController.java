package com.ngclass.backend.school.controller;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.school.domain.SchoolYear;
import com.ngclass.backend.school.dto.ReferenceResponse;
import com.ngclass.backend.school.dto.ReferenceResponse.LevelItem;
import com.ngclass.backend.school.dto.ReferenceResponse.SchoolYearItem;
import com.ngclass.backend.school.dto.ReferenceResponse.SubjectItem;
import com.ngclass.backend.school.repository.LevelRepository;
import com.ngclass.backend.school.repository.SubjectRepository;
import com.ngclass.backend.school.service.SchoolYearService;
import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/reference")
@RequiredArgsConstructor
public class ReferenceController {
	private final SubjectRepository subjects;
	private final CurrentTeacher teacher;
	private final LevelRepository levels;
	private final SchoolYearService schoolYearService;
	private final AppProperties properties;
	private final Clock clock;

	@GetMapping
	@Transactional
	public ReferenceResponse reference() {
		SchoolYear year = schoolYearService.ensureCurrent(LocalDate.now(clock.withZone(properties.zoneId())));
		return new ReferenceResponse(
				// The subjects of the teacher's space; the owner of the platform has none.
				teacher.find().map(subjects::findByTeacherIdOrderByPositionAsc).orElse(List.of()).stream()
						.map(subject -> new SubjectItem(subject.getId(), subject.name(), subject.getColor()))
						.toList(),
				levels.findAllByOrderByPositionAsc().stream()
						.map(level -> new LevelItem(level.getId(), level.name()))
						.toList(),
				new SchoolYearItem(year.getId(), year.getLabel(), year.getStartsOn(), year.getEndsOn()));
	}
}
