package com.ngclass.backend.people.repository;

import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.dto.ChildResponse;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ParentRepository extends JpaRepository<Parent, UUID> {
	Optional<Parent> findByUser_Id(UUID userId);

	/** The children a parent account can see: archived children are hidden. */
	@Query("""
			select new com.ngclass.backend.people.dto.ChildResponse(s.id, u.firstName, u.lastName, l.nameFr, l.nameAr)
			from Parent p join p.children s join s.user u join s.level l
			where p.user.id = :userId and s.archivedAt is null
			order by u.firstName""")
	List<ChildResponse> findActiveChildrenOfUser(@Param("userId") UUID userId);

	/** Parents of these students, with their account, for lists and profiles. */
	@EntityGraph(attributePaths = {"user", "children"})
	@Query("select distinct p from Parent p join p.children s where s.id in :studentIds")
	List<Parent> findByChildren(@Param("studentIds") Collection<UUID> studentIds);

	@EntityGraph(attributePaths = {"user", "children", "children.user"})
	@Query("select p from Parent p join p.user u where p.teacherId = :teacherId order by lower(u.firstName), lower(u.lastName)")
	List<Parent> findAllWithChildren(@Param("teacherId") UUID teacherId);

	/** Parent accounts still open, per teacher (owner dashboard). Rows: teacherId, count. */
	@Query("select p.teacherId, count(p) from Parent p where p.user.active = true group by p.teacherId")
	List<Object[]> countActiveByTeacher();

	@Query("select count(p) from Parent p join p.children s where s.id = :studentId")
	long countParentsOf(@Param("studentId") UUID studentId);

	/** "mère", "père", "tuteur": stored on the link. Rows: parentId, studentId, relation. */
	@Query(value = "select parent_id, student_id, relation from parent_students where student_id in (:studentIds)", nativeQuery = true)
	List<Object[]> findRelations(@Param("studentIds") Collection<UUID> studentIds);

	@Modifying
	@Query(value = "update parent_students set relation = :relation where parent_id = :parentId and student_id = :studentId", nativeQuery = true)
	void setRelation(@Param("parentId") UUID parentId, @Param("studentId") UUID studentId, @Param("relation") String relation);
}
