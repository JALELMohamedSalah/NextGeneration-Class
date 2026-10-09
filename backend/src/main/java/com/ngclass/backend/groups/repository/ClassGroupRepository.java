package com.ngclass.backend.groups.repository;

import com.ngclass.backend.groups.domain.ClassGroup;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ClassGroupRepository extends JpaRepository<ClassGroup, UUID> {
	@EntityGraph(attributePaths = {"subject", "level"})
	List<ClassGroup> findBySchoolYear_IdAndTeacherIdAndArchivedAtIsNullOrderByPrivateLessonAscNameAsc(UUID schoolYearId, UUID teacherId);

	/** Every group of a teacher, archived ones included: her sessions are theirs. */
	@Query("select g.id from ClassGroup g where g.teacherId = :teacherId")
	List<UUID> findIdsByTeacherId(@Param("teacherId") UUID teacherId);

	boolean existsByIdAndTeacherId(UUID id, UUID teacherId);

	/** Groups still running, per teacher (owner dashboard). Rows: teacherId, count. */
	@Query("select g.teacherId, count(g) from ClassGroup g where g.archivedAt is null group by g.teacherId")
	List<Object[]> countActiveByTeacher();

	@EntityGraph(attributePaths = {"subject", "level"})
	List<ClassGroup> findByIdIn(Iterable<UUID> ids);

	long countBySchoolYear_IdAndTeacherId(UUID schoolYearId, UUID teacherId);

	boolean existsBySubject_Id(UUID subjectId);

	/** How many groups use each subject, archived ones included: they block a deletion too. */
	@Query("select g.subject.id as subjectId, count(g) as groupCount from ClassGroup g group by g.subject.id")
	List<SubjectUse> countGroupsBySubject();

	interface SubjectUse {
		UUID getSubjectId();

		long getGroupCount();
	}
}
