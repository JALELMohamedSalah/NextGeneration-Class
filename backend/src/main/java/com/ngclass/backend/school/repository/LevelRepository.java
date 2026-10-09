package com.ngclass.backend.school.repository;

import com.ngclass.backend.school.domain.Level;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LevelRepository extends JpaRepository<Level, UUID> {
	List<Level> findAllByOrderByPositionAsc();

	Optional<Level> findByNameFr(String nameFr);
}
