package com.ngclass.backend.school.repository;

import com.ngclass.backend.school.domain.Subject;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubjectRepository extends JpaRepository<Subject, UUID> {
	List<Subject> findByTeacherIdOrderByPositionAsc(UUID teacherId);

	Optional<Subject> findByIdAndTeacherId(UUID id, UUID teacherId);

	boolean existsByTeacherIdAndNameFrIgnoreCase(UUID teacherId, String nameFr);
}
