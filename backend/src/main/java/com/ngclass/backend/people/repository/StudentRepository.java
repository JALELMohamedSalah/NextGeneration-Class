package com.ngclass.backend.people.repository;

import com.ngclass.backend.people.domain.Student;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StudentRepository extends JpaRepository<Student, UUID> {
	Optional<Student> findByUser_Id(UUID userId);

	@EntityGraph(attributePaths = {"user", "level"})
	@Query("""
			select s from Student s join s.user u
			where s.teacherId = :teacherId
			and ((:archived = true and s.archivedAt is not null) or (:archived = false and s.archivedAt is null))
			order by lower(u.firstName), lower(u.lastName)""")
	List<Student> findAllForList(@Param("teacherId") UUID teacherId, @Param("archived") boolean archived);

	/** Students still followed, per teacher (owner dashboard). Rows: teacherId, count. */
	@Query("select s.teacherId, count(s) from Student s where s.archivedAt is null group by s.teacherId")
	List<Object[]> countActiveByTeacher();

	@EntityGraph(attributePaths = {"user", "level"})
	List<Student> findByIdIn(Collection<UUID> ids);

	@EntityGraph(attributePaths = {"user", "level"})
	@Query("select s from Student s where s.id = :id")
	Optional<Student> findWithUser(@Param("id") UUID id);
}
