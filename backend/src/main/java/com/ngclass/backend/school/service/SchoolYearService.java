package com.ngclass.backend.school.service;

import com.ngclass.backend.school.domain.SchoolYear;
import com.ngclass.backend.school.repository.SchoolYearRepository;
import java.time.LocalDate;
import java.time.Month;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SchoolYearService {
	private final SchoolYearRepository schoolYears;

	/**
	 * Makes sure a current school year exists (September 1st to June 30th). The yearly rollover
	 * screen (docs/03-conception/03-BUSINESS_RULES.md, section 11) replaces it later.
	 */
	@Transactional
	public SchoolYear ensureCurrent(LocalDate today) {
		return schoolYears.findByCurrentTrue().orElseGet(() -> {
			int startYear = today.getMonthValue() >= Month.SEPTEMBER.getValue() ? today.getYear() : today.getYear() - 1;
			String label = startYear + "-" + (startYear + 1);
			SchoolYear year = schoolYears.findByLabel(label).orElseGet(() -> SchoolYear.builder()
					.label(label)
					.startsOn(LocalDate.of(startYear, Month.SEPTEMBER, 1))
					.endsOn(LocalDate.of(startYear + 1, Month.JUNE, 30))
					.build());
			year.setCurrent(true);
			return schoolYears.save(year);
		});
	}
}
