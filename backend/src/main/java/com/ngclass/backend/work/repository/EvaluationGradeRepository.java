package com.ngclass.backend.work.repository;

import com.ngclass.backend.work.domain.EvaluationGrade;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EvaluationGradeRepository extends JpaRepository<EvaluationGrade, EvaluationGrade.Key> {
	List<EvaluationGrade> findById_EvaluationId(UUID evaluationId);

	List<EvaluationGrade> findById_EvaluationIdIn(Collection<UUID> evaluationIds);

	/** A pupil's grades, for Résultats. */
	List<EvaluationGrade> findById_StudentId(UUID studentId);
}
