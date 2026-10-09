package com.ngclass.backend.work.repository;

import com.ngclass.backend.work.domain.Assignment;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssignmentRepository extends JpaRepository<Assignment, UUID> {
	List<Assignment> findByTeacherIdOrderByDeadlineAtAsc(UUID teacherId);

	Optional<Assignment> findByIdAndTeacherId(UUID id, UUID teacherId);

	List<Assignment> findByIdIn(Collection<UUID> ids);

	List<Assignment> findByGroupIdAndWholeGroupTrueAndClosedAtIsNullAndDeadlineAtAfter(UUID groupId, Instant now);

	/** Deadlines passed that the teacher has not heard of yet. */
	List<Assignment> findByDeadlineNotifiedAtIsNullAndDeadlineAtLessThanEqual(Instant now);
}
