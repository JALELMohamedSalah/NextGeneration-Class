package com.ngclass.backend.planning.repository;

import com.ngclass.backend.planning.domain.ClassSession;
import com.ngclass.backend.planning.domain.SessionStatus;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ClassSessionRepository extends JpaRepository<ClassSession, UUID> {
	List<ClassSession> findByGroupIdInAndStartsAtLessThanAndEndsAtGreaterThanOrderByStartsAtAsc(
			Collection<UUID> groupIds, Instant to, Instant from);

	/** The rule's sessions from a date on, for "this and following". */
	List<ClassSession> findByRecurrenceRuleIdAndStartsAtGreaterThanEqualOrderByStartsAtAsc(UUID ruleId, Instant from);

	List<ClassSession> findByGroupIdInAndStartsAtGreaterThanEqualAndStatusNotOrderByStartsAtAsc(
			Collection<UUID> groupIds, Instant from, SessionStatus excluded);

	/** The last finished session of a group before this one, for "Dernière séance". */
	@Query("""
			select s from ClassSession s
			where s.groupId = :groupId and s.startsAt < :before and s.status = com.ngclass.backend.planning.domain.SessionStatus.DONE
			order by s.startsAt desc limit 1""")
	List<ClassSession> findPreviousDone(@Param("groupId") UUID groupId, @Param("before") Instant before);

	/** Sessions of [groupIds] overlapping [from, to), except cancelled ones and [excluded]: the overlap warning. */
	@Query("""
			select s from ClassSession s
			where s.groupId in :groupIds and s.startsAt < :to and s.endsAt > :from
			and s.status <> com.ngclass.backend.planning.domain.SessionStatus.CANCELLED and s.id <> :excluded""")
	List<ClassSession> findOverlapping(
			@Param("groupIds") Collection<UUID> groupIds,
			@Param("from") Instant from,
			@Param("to") Instant to,
			@Param("excluded") UUID excluded);
}
