package com.ngclass.backend.planning.service;

import com.ngclass.backend.planning.domain.AttendanceStatus;
import com.ngclass.backend.planning.repository.AttendanceRepository;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Attendance % = (present + late) / sessions counted × 100 (docs/03-conception/03-BUSINESS_RULES.md). */
@Service
@RequiredArgsConstructor
public class AttendanceStats {
	private final AttendanceRepository attendance;

	public record Summary(int present, int absent, int late) {
		public static final Summary NONE = new Summary(0, 0, 0);

		public int counted() {
			return present + absent + late;
		}

		/** Null while no session has been counted: the app shows "—". */
		public Integer rate() {
			return counted() == 0 ? null : Math.round((present + late) * 100f / counted());
		}
	}

	@Transactional(readOnly = true)
	public Map<UUID, Summary> of(Collection<UUID> studentIds) {
		Map<UUID, int[]> counts = new HashMap<>();
		if (!studentIds.isEmpty()) {
			for (Object[] row : attendance.countByStudentAndStatus(studentIds)) {
				int[] c = counts.computeIfAbsent((UUID) row[0], id -> new int[3]);
				c[((AttendanceStatus) row[1]).ordinal()] = ((Number) row[2]).intValue();
			}
		}
		Map<UUID, Summary> result = new HashMap<>();
		for (UUID id : studentIds) {
			int[] c = counts.get(id);
			result.put(id, c == null ? Summary.NONE : new Summary(c[0], c[1], c[2]));
		}
		return result;
	}
}
