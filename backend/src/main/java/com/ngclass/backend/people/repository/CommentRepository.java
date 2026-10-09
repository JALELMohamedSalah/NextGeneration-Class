package com.ngclass.backend.people.repository;

import com.ngclass.backend.people.domain.Comment;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommentRepository extends JpaRepository<Comment, UUID> {
	List<Comment> findByStudentIdOrderByCreatedAtDesc(UUID studentId);
}
