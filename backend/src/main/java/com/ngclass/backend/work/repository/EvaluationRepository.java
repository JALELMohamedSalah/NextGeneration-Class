package com.ngclass.backend.work.repository;

import com.ngclass.backend.work.domain.Evaluation;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EvaluationRepository extends JpaRepository<Evaluation, UUID> {
	List<Evaluation> findByTeacherIdOrderByHeldOnDescCreatedAtDesc(UUID teacherId);

	Optional<Evaluation> findByIdAndTeacherId(UUID id, UUID teacherId);
}
