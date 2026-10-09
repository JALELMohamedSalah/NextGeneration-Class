package com.ngclass.backend.content.repository;

import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.ContentStatus;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ContentItemRepository extends JpaRepository<ContentItem, UUID> {
	List<ContentItem> findByTeacherIdAndStatusNotOrderByUpdatedAtDesc(UUID teacherId, ContentStatus status);

	Optional<ContentItem> findByIdAndTeacherId(UUID id, UUID teacherId);

	boolean existsBySubjectId(UUID subjectId);

	/** A deleted chapter leaves its documents in "Sans chapitre". */
	@Modifying
	@Query("update ContentItem i set i.chapterId = null where i.chapterId = :chapterId")
	void clearChapter(@Param("chapterId") UUID chapterId);

	/**
	 * Published documents a pupil of these groups may open: shared with one of the groups, directly or
	 * through their chapter (a shared chapter also shows documents added later).
	 */
	@Query("""
			select i from ContentItem i where i.status = com.ngclass.backend.content.domain.ContentStatus.PUBLISHED and (
				exists (select 1 from ContentShare s where s.itemId = i.id and s.groupId in :groupIds)
				or (i.chapterId is not null and exists (select 1 from ContentShare s where s.chapterId = i.chapterId and s.groupId in :groupIds)))""")
	List<ContentItem> visibleTo(@Param("groupIds") Collection<UUID> groupIds);
}
