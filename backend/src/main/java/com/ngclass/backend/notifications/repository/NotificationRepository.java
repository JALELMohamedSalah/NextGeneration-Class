package com.ngclass.backend.notifications.repository;

import com.ngclass.backend.notifications.domain.Notification;
import com.ngclass.backend.notifications.domain.NotificationType;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
	/** The latest first, within the kept period. */
	List<Notification> findTop100ByUserIdAndCreatedAtAfterOrderByCreatedAtDesc(UUID userId, Instant after);

	long countByUserIdAndReadAtIsNullAndCreatedAtAfter(UUID userId, Instant after);

	Optional<Notification> findByIdAndUserId(UUID id, UUID userId);

	/** The teacher's unread "work sent" row of a homework, to gather the next work into it. */
	Optional<Notification> findFirstByUserIdAndTypeAndAssignmentIdAndReadAtIsNull(UUID userId, NotificationType type, UUID assignmentId);

	@Modifying
	@Query("update Notification n set n.readAt = :now where n.userId = :userId and n.readAt is null")
	int markAllRead(@Param("userId") UUID userId, @Param("now") Instant now);
}
