package com.ngclass.backend.content.repository;

import com.ngclass.backend.content.domain.Chapter;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChapterRepository extends JpaRepository<Chapter, UUID> {
	List<Chapter> findByTeacherIdOrderByPositionAscCreatedAtAsc(UUID teacherId);

	Optional<Chapter> findByIdAndTeacherId(UUID id, UUID teacherId);

	List<Chapter> findByIdIn(Collection<UUID> ids);

	List<Chapter> findByTeacherIdAndSubjectIdAndLevelIdAndTitleIgnoreCase(UUID teacherId, UUID subjectId, UUID levelId, String title);

	@Query("select coalesce(max(c.position), 0) from Chapter c where c.teacherId = :teacherId and c.subjectId = :subjectId and c.levelId = :levelId")
	int lastPosition(@Param("teacherId") UUID teacherId, @Param("subjectId") UUID subjectId, @Param("levelId") UUID levelId);

	boolean existsBySubjectId(UUID subjectId);
}
