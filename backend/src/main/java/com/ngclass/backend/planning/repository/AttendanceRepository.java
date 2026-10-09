package com.ngclass.backend.planning.repository;

import com.ngclass.backend.planning.domain.Attendance;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AttendanceRepository extends JpaRepository<Attendance, Attendance.Key> {
	List<Attendance> findById_SessionId(UUID sessionId);

	/**
	 * Present, absent and late counts per student over finished sessions (docs/03-conception/03-BUSINESS_RULES.md:
	 * cancelled sessions do not count). Rows: studentId, status, count.
	 */
	@Query("""
			select a.id.studentId, a.status, count(a) from Attendance a, ClassSession s
			where s.id = a.id.sessionId and s.status = com.ngclass.backend.planning.domain.SessionStatus.DONE
			and a.id.studentId in :studentIds
			group by a.id.studentId, a.status""")
	List<Object[]> countByStudentAndStatus(@Param("studentIds") Collection<UUID> studentIds);

	/** Present, absent and late counts of one student per subject of the group (Résultats). Rows: subjectId, status, count. */
	@Query("""
			select g.subject.id, a.status, count(a) from Attendance a, ClassSession s, ClassGroup g
			where s.id = a.id.sessionId and g.id = s.groupId and s.status = com.ngclass.backend.planning.domain.SessionStatus.DONE
			and a.id.studentId = :studentId
			group by g.subject.id, a.status""")
	List<Object[]> countBySubject(@Param("studentId") UUID studentId);

	/** The last attendance marks of a student, newest first. Rows: startsAt, status. */
	@Query("""
			select s.startsAt, a.status from Attendance a, ClassSession s
			where s.id = a.id.sessionId and s.status = com.ngclass.backend.planning.domain.SessionStatus.DONE
			and a.id.studentId = :studentId
			order by s.startsAt desc limit 10""")
	List<Object[]> findRecent(@Param("studentId") UUID studentId);

	/** Rows: sessionId, status, count. */
	@Query("""
			select a.id.sessionId, a.status, count(a) from Attendance a
			where a.id.sessionId in :sessionIds
			group by a.id.sessionId, a.status""")
	List<Object[]> countBySession(@Param("sessionIds") Collection<UUID> sessionIds);
}
