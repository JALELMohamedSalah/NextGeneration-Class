package com.ngclass.backend.content.repository;

import com.ngclass.backend.content.domain.ContentView;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ContentViewRepository extends JpaRepository<ContentView, ContentView.Key> {
	@Query("select v.id.itemId from ContentView v where v.id.userId = :userId and v.id.itemId in :itemIds")
	List<UUID> viewedBy(@Param("userId") UUID userId, @Param("itemIds") Collection<UUID> itemIds);
}
