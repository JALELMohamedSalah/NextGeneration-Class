package com.ngclass.backend.school.repository;

import com.ngclass.backend.school.domain.SchoolYear;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SchoolYearRepository extends JpaRepository<SchoolYear, UUID> {
	Optional<SchoolYear> findByCurrentTrue();

	Optional<SchoolYear> findByLabel(String label);
}
