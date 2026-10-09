package com.ngclass.backend.work.service;

import com.ngclass.backend.work.domain.Assignment;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import com.ngclass.backend.work.domain.HomeworkStatus;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.AssignmentRepository;
import java.time.Clock;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/** Spec 06: a pupil who joins a group before the deadline receives the group's open homework. */
@Component
@RequiredArgsConstructor
public class HomeworkJoins {
	private final AssignmentRepository assignments;
	private final AssignmentRecipientRepository recipients;
	private final Clock clock;

	public void joined(UUID groupId, UUID studentId) {
		var now = clock.instant();
		for (Assignment a : assignments.findByGroupIdAndWholeGroupTrueAndClosedAtIsNullAndDeadlineAtAfter(groupId, now)) {
			if (recipients.findByAssignmentIdAndStudentId(a.getId(), studentId).isEmpty()) {
				recipients.save(AssignmentRecipient.builder()
						.assignmentId(a.getId())
						.studentId(studentId)
						.status(HomeworkStatus.TODO)
						.statusChangedAt(now)
						.build());
			}
		}
	}
}
