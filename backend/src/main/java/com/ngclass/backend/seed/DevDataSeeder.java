package com.ngclass.backend.seed;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.config.AppProperties.DevData;
import com.ngclass.backend.content.dto.ContentDtos.ChapterRequest;
import com.ngclass.backend.content.dto.ContentDtos.UploadRequest;
import com.ngclass.backend.content.service.ContentService;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.school.domain.Level;
import com.ngclass.backend.school.repository.LevelRepository;
import com.ngclass.backend.groups.dto.GroupDtos.GroupRequest;
import com.ngclass.backend.groups.dto.GroupDtos.GroupResponse;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.planning.dto.PlanningDtos.SessionRequest;
import com.ngclass.backend.planning.service.PlanningService;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.repository.SubjectRepository;
import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Dev profile only: one student, their parent, a group, a weekly session and a shared document, so the
 * three role spaces have something to show. Accounts and passwords: application-dev.yaml.
 */
@Component
@Profile("dev")
@Order(2)
@RequiredArgsConstructor
@Slf4j
public class DevDataSeeder implements ApplicationRunner {
	private final UserRepository users;
	private final StudentRepository students;
	private final ParentRepository parents;
	private final LevelRepository levels;
	private final PasswordEncoder passwordEncoder;
	private final AppProperties properties;
	private final SubjectRepository subjects;
	private final GroupService groupService;
	private final PlanningService planning;
	private final ContentService contents;
	private final Clock clock;

	@Override
	@Transactional
	public void run(ApplicationArguments args) {
		DevData data = properties.devData();
		// The demo pupil and parent belong to the first teacher (the seeded one).
		User teacher = users.findByRoleOrderByCreatedAtAsc(Role.TEACHER).stream().findFirst().orElse(null);
		if (data == null || teacher == null) {
			return;
		}
		// The passwords come from backend/.env (DEV_STUDENT_PASSWORD, DEV_PARENT_PASSWORD), never from the repository.
		if (isBlank(data.studentPassword()) || isBlank(data.parentPassword())) {
			log.warn("DEV_STUDENT_PASSWORD / DEV_PARENT_PASSWORD not set in backend/.env: no demo pupil and parent");
			return;
		}
		if (!users.existsByUsername(data.studentUsername())) {
			seedAccounts(data, teacher);
		}
		CurrentTeacher.actingAs(teacher, () -> {
			if (groupService.list().isEmpty()) {
				seedWeek(data, teacher);
			}
			if (contents.library().items().isEmpty()) {
				seedLibrary();
			}
			return null;
		});
	}

	private void seedAccounts(DevData data, User teacher) {
		Level level = levels.findAllByOrderByPositionAsc().get(1);
		User studentUser = users.save(User.builder()
				.role(Role.STUDENT)
				.username(data.studentUsername())
				.passwordHash(passwordEncoder.encode(data.studentPassword()))
				.firstName("Adam")
				.lastName("Gharbi")
				.build());
		Student student = students.save(Student.builder().teacherId(teacher.getId()).user(studentUser).level(level).build());
		User parentUser = users.save(User.builder()
				.role(Role.PARENT)
				.username("parent.demo")
				.phone(data.parentPhone())
				.passwordHash(passwordEncoder.encode(data.parentPassword()))
				.firstName("Mouna")
				.lastName("Gharbi")
				.build());
		parents.save(Parent.builder().teacherId(teacher.getId()).user(parentUser).children(Set.of(student)).build());
		log.info("Seeded dev student {} and parent {}", studentUser.getUsername(), parentUser.getUsername());
	}

	/** A group with the demo student and a weekly session from last week to the end of the year. */
	private void seedWeek(DevData data, User teacher) {
		Student student = users.findByUsername(data.studentUsername())
				.flatMap(u -> students.findByUser_Id(u.getId()))
				.orElseThrow();
		Subject math = subjects.findByTeacherIdOrderByPositionAsc(teacher.getId()).stream().findFirst()
				.orElseGet(() -> subjects.save(Subject.builder()
						.teacherId(teacher.getId())
						.nameFr("Mathématiques")
						.nameAr("الرياضيات")
						.color("#2B3990")
						.position(1)
						.build()));
		GroupResponse group = groupService.create(new GroupRequest(
				student.getLevel().getNameFr() + " A · " + math.getNameFr(), math.getId(), student.getLevel().getId(), null, null));
		groupService.setMembers(group.id(), List.of(student.getId()));
		LocalDate lastWeek = LocalDate.now(clock.withZone(properties.zoneId())).minusWeeks(1);
		planning.create(new SessionRequest(
				group.id(), lastWeek, LocalTime.of(10, 0), LocalTime.of(11, 30), "IN_PERSON", "Salle 2", null, null, true, null));
		log.info("Seeded dev group {} with a weekly session", group.name());
	}

	/** A chapter of the first group's subject and level, with a PDF shared with that group. */
	private void seedLibrary() {
		GroupResponse group = groupService.list().getFirst();
		UUID chapter = contents.createChapter(new ChapterRequest(group.subjectId(), group.levelId(), "Les fractions")).id();
		contents.upload(DemoDocument.fractionsSeries(), "serie1_fractions.pdf", new UploadRequest(
				"Série 1 : les fractions", group.subjectId(), group.levelId(), chapter, "SERIE", false, List.of(group.id())));
		log.info("Seeded dev chapter and document for {}", group.name());
	}

	private static boolean isBlank(String value) {
		return value == null || value.isBlank();
	}
}
