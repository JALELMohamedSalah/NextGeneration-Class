package com.ngclass.backend.work.repository;

import com.ngclass.backend.work.domain.Submission;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubmissionRepository extends JpaRepository<Submission, UUID> {
	Optional<Submission> findFirstByRecipientIdOrderBySubmittedAtDesc(UUID recipientId);

	List<Submission> findByRecipientIdInOrderBySubmittedAtDesc(Collection<UUID> recipientIds);
}
