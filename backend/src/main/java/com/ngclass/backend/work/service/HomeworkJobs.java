package com.ngclass.backend.work.service;

import com.ngclass.backend.groups.domain.ClassGroup;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.notifications.service.NotificationService;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.work.domain.Assignment;
import com.ngclass.backend.work.domain.AssignmentRecipient;
import com.ngclass.backend.work.domain.HomeworkStatus;
import com.ngclass.backend.work.domain.SubmissionMode;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.AssignmentRepository;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Spec 06: at the deadline, what was not sent becomes "Manquant" within a minute. Reads never wait for it.
 * Spec 08: the teacher then hears who did not send (or that everyone did), once per deadline.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class HomeworkJobs {
	private final AssignmentRecipientRepository recipients;
	private final AssignmentRepository assignments;
	private final ClassGroupRepository groups;
	private final StudentRepository students;
	private final NotificationService notifications;
	private final Clock clock;

	@Scheduled(fixedDelayString = "PT1M", initialDelayString = "PT1M")
	@Transactional
	public void markMissing() {
		int changed = recipients.markMissing(clock.instant());
		if (changed > 0) {
			log.info("{} homework statuses set to MISSING", changed);
		}
	}

	/** Homework closed before its deadline, or with nothing to send, says nothing: there is nothing to wait for. */
	@Scheduled(fixedDelayString = "PT1M", initialDelayString = "PT1M")
	@Transactional
	public void tellDeadlines() {
		Instant now = clock.instant();
		for (Assignment assignment : assignments.findByDeadlineNotifiedAtIsNullAndDeadlineAtLessThanEqual(now)) {
			assignment.setDeadlineNotifiedAt(now);
			boolean closedBefore = assignment.getClosedAt() != null && !assignment.getClosedAt().isAfter(assignment.getDeadlineAt());
			if (closedBefore || assignment.getSubmissionMode() == SubmissionMode.NONE) {
				continue;
			}
			List<UUID> missingIds = recipients.findByAssignmentId(assignment.getId()).stream()
					.filter(r -> r.getStatus() == HomeworkStatus.TODO || r.getStatus() == HomeworkStatus.MISSING)
					.map(AssignmentRecipient::getStudentId)
					.toList();
			List<Student> missing = missingIds.isEmpty() ? List.of()
					: students.findByIdIn(missingIds).stream().filter(s -> s.getArchivedAt() == null).toList();
			ClassGroup group = groups.findById(assignment.getGroupId()).orElseThrow();
			notifications.deadlinePassed(assignment.getTeacherId(), group, assignment.getId(), assignment.getTitle(),
					assignment.getDeadlineAt(), missing);
		}
	}
}
