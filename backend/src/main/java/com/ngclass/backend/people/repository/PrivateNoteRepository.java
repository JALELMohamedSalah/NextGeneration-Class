package com.ngclass.backend.people.repository;

import com.ngclass.backend.people.domain.PrivateNote;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PrivateNoteRepository extends JpaRepository<PrivateNote, UUID> {
	List<PrivateNote> findByStudentIdOrderByCreatedAtDesc(UUID studentId);
}
