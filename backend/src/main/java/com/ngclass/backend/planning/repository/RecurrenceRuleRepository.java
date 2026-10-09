package com.ngclass.backend.planning.repository;

import com.ngclass.backend.planning.domain.RecurrenceRule;
import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecurrenceRuleRepository extends JpaRepository<RecurrenceRule, UUID> {
	/** Rules still running on [today], for the "horaire habituel" of each group. */
	List<RecurrenceRule> findByGroupIdInAndEndsOnGreaterThanEqualOrderByWeekdayAscStartTimeAsc(
			Collection<UUID> groupIds, LocalDate today);
}
