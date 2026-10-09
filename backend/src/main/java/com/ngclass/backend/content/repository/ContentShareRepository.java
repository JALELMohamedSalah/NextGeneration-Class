package com.ngclass.backend.content.repository;

import com.ngclass.backend.content.domain.ContentShare;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ContentShareRepository extends JpaRepository<ContentShare, UUID> {
	List<ContentShare> findByItemId(UUID itemId);

	List<ContentShare> findByChapterId(UUID chapterId);

	List<ContentShare> findByItemIdIn(Collection<UUID> itemIds);

	List<ContentShare> findByChapterIdIn(Collection<UUID> chapterIds);

	List<ContentShare> findByGroupIdIn(Collection<UUID> groupIds);

	@Modifying
	@Query("delete from ContentShare s where s.itemId = :itemId")
	void deleteByItemId(@Param("itemId") UUID itemId);
}
