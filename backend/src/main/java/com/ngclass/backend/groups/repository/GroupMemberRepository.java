package com.ngclass.backend.groups.repository;

import com.ngclass.backend.groups.domain.GroupMember;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface GroupMemberRepository extends JpaRepository<GroupMember, GroupMember.Key> {
	/** Current members only. */
	List<GroupMember> findById_GroupIdAndLeftAtIsNull(UUID groupId);

	List<GroupMember> findById_StudentIdAndLeftAtIsNull(UUID studentId);

	List<GroupMember> findById_StudentIdInAndLeftAtIsNull(Collection<UUID> studentIds);

	/** Current, non-archived members per group, for the group cards. */
	@Query("""
			select m.id.groupId, count(m) from GroupMember m, Student s
			where s.id = m.id.studentId and m.leftAt is null and s.archivedAt is null
			group by m.id.groupId""")
	List<Object[]> countActiveMembers();

	@Query("""
			select count(m) > 0 from GroupMember m
			where m.id.groupId = :groupId and m.id.studentId = :studentId and m.leftAt is null""")
	boolean isMember(@Param("groupId") UUID groupId, @Param("studentId") UUID studentId);
}
