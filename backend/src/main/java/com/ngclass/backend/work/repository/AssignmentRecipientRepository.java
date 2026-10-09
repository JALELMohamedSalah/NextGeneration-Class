package com.ngclass.backend.work.repository;

import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AssignmentRecipientRepository extends JpaRepository<AssignmentRecipient, UUID> {
	List<AssignmentRecipient> findByAssignmentId(UUID assignmentId);

	List<AssignmentRecipient> findByAssignmentIdIn(Collection<UUID> assignmentIds);

	List<AssignmentRecipient> findByStudentIdIn(Collection<UUID> studentIds);

	Optional<AssignmentRecipient> findByAssignmentIdAndStudentId(UUID assignmentId, UUID studentId);

	/** The teacher's corrected copy of one pupil, for a signed link. */
	@Query("select r.correctionFile from AssignmentRecipient r where r.id = :id and r.correctionFile is not null")
	Optional<FileAsset> findCorrectionFile(@Param("id") UUID id);

	/** The "Manquant" job (spec 06): what was still to do when the deadline passed. */
	@Modifying
	@Query(value = """
			update assignment_recipients r set status = 'MISSING', status_changed_at = :now
			from assignments a
			where r.assignment_id = a.id and r.status = 'TODO' and a.submission_mode = 'FILE' and a.deadline_at <= :now""",
			nativeQuery = true)
	int markMissing(@Param("now") Instant now);

	/** A later deadline gives back their chance to those marked missing. */
	@Modifying
	@Query("update AssignmentRecipient r set r.status = com.ngclass.backend.work.domain.HomeworkStatus.TODO, r.statusChangedAt = :now "
			+ "where r.assignmentId = :assignmentId and r.status = com.ngclass.backend.work.domain.HomeworkStatus.MISSING")
	int reopenMissing(@Param("assignmentId") UUID assignmentId, @Param("now") Instant now);
}
