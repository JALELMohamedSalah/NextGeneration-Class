package com.ngclass.backend.planning;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.school.repository.LevelRepository;
import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/** Release 1 acceptance criteria (specs 02 and 03), end to end through the API on PostgreSQL. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class OrganizeMyWeekTest {
	private static final String PASSWORD = "Secret2026x";
	private static final ZoneId TUNIS = ZoneId.of("Africa/Tunis");

	@Container
	@ServiceConnection
	static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

	@Autowired
	private MockMvc mvc;
	@Autowired
	private ObjectMapper json;
	@Autowired
	private JdbcTemplate jdbc;
	@Autowired
	private UserRepository users;
	@Autowired
	private LevelRepository levels;
	@Autowired
	private PasswordEncoder passwordEncoder;

	private String teacher;
	private String levelId;
	private String subjectId;

	@BeforeEach
	void cleanAndSignIn() throws Exception {
		jdbc.execute("""
				truncate attendance, sessions, recurrence_rules, comments, private_notes, group_members, class_groups,
				parent_students, parents, students, refresh_tokens, users cascade""");
		users.save(User.builder()
				.role(Role.TEACHER)
				.username("enseignante")
				.firstName("Ines")
				.lastName("Haddad")
				.passwordHash(passwordEncoder.encode(PASSWORD))
				.build());
		teacher = token("enseignante", PASSWORD);
		levelId = levels.findAllByOrderByPositionAsc().get(1).getId().toString();
		// No subject is predefined: the teacher creates hers.
		jdbc.execute("delete from subjects");
		subjectId = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON)
				.content("{\"nameFr\":\"Mathématiques\",\"nameAr\":\"الرياضيات\"}"), teacher)
				.andExpect(status().isCreated())).at("/id").asText();
	}

	@Test
	void primarySchoolLevelsAndTheTeachersOwnSubjects() throws Exception {
		JsonNode reference = body(call(get("/api/v1/reference"), teacher));
		assertThat(reference.at("/levels/0/name/fr").asText()).isEqualTo("1ère année");
		assertThat(reference.at("/levels/5/name/fr").asText()).isEqualTo("6ème année");
		assertThat(reference.at("/subjects")).hasSize(1);

		call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON).content("{\"nameFr\":\"mathématiques\"}"), teacher)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("subject_exists"));
		String eveil = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON)
				.content("{\"nameFr\":\"Éveil scientifique\"}"), teacher)).at("/id").asText();
		assertThat(body(call(get("/api/v1/reference"), teacher)).at("/subjects/1/name/ar").asText()).isEmpty();

		createGroup("2ème année · Math");
		call(delete("/api/v1/subjects/" + subjectId), teacher)
				.andExpect(status().isConflict())
				.andExpect(jsonPath("$.code").value("subject_in_use"));
		call(delete("/api/v1/subjects/" + eveil), teacher).andExpect(status().isNoContent());
	}

	@Test
	void settingsListEachSubjectWithTheGroupsThatUseIt() throws Exception {
		String lecture = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON)
				.content("{\"nameFr\":\"Lecture\",\"nameAr\":\"القراءة\"}"), teacher)
				.andExpect(status().isCreated())).at("/id").asText();
		createGroup("2ème année · Math");
		String archived = createGroup("3ème année · Math");
		call(post("/api/v1/groups/" + archived + "/archive"), teacher).andExpect(status().isNoContent());

		JsonNode subjects = body(call(get("/api/v1/subjects"), teacher).andExpect(status().isOk()));
		assertThat(subjects).hasSize(2);
		assertThat(subjects.at("/0/name/fr").asText()).isEqualTo("Mathématiques");
		// An archived group still holds its subject: it counts, as it blocks a deletion.
		assertThat(subjects.at("/0/groupCount").asLong()).isEqualTo(2);
		assertThat(subjects.at("/1/name/ar").asText()).isEqualTo("القراءة");
		assertThat(subjects.at("/1/groupCount").asLong()).isZero();

		call(put("/api/v1/subjects/" + lecture).contentType(MediaType.APPLICATION_JSON)
				.content("{\"nameFr\":\"Lecture et écriture\",\"nameAr\":\"\",\"color\":\"#7048E8\"}"), teacher)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.name.fr").value("Lecture et écriture"))
				.andExpect(jsonPath("$.name.ar").value(""))
				.andExpect(jsonPath("$.color").value("#7048E8"));

		JsonNode created = createStudent("Omar", "Saidi", parent("Nadia", "Saidi", "22345679"));
		String parent = firstLogin(created.at("/credentials/1"));
		call(get("/api/v1/subjects"), parent).andExpect(status().isForbidden());
	}

	@Test
	void aChildCanBeFollowedWithoutSigningInAndGetAnAccessLater() throws Exception {
		Map<String, Object> body = studentBody("Adam", "Gharbi");
		body.put("createLogin", false);
		body.put("parents", List.of(parent("Mouna", "Gharbi", "22345682")));
		JsonNode created = body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(body)), teacher).andExpect(status().isCreated()));
		String studentId = created.at("/student/id").asText();
		assertThat(created.at("/student/loginEnabled").asBoolean()).isFalse();
		assertThat(created.at("/credentials")).hasSize(1);
		assertThat(created.at("/credentials/0/role").asText()).isEqualTo("PARENT");

		call(post("/api/v1/users/" + created.at("/student/userId").asText() + "/reset-password"), teacher)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("login_not_enabled"));

		JsonNode access = body(call(post("/api/v1/students/" + studentId + "/login"), teacher).andExpect(status().isOk()));
		String token = token(access.at("/username").asText(), access.at("/temporaryPassword").asText());
		call(get("/api/v1/me"), token).andExpect(jsonPath("$.mustChangePassword").value(true));

		call(delete("/api/v1/students/" + studentId + "/login"), teacher).andExpect(status().isNoContent());
		login(access.at("/username").asText(), access.at("/temporaryPassword").asText())
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("invalid_credentials"));
	}

	@Test
	void aStudentWithANewParentGetsTwoAccountsAndTheirLoginDetailsOnce() throws Exception {
		JsonNode created = createStudent("Éya", "Ben Salah", parent("Nadia", "Ben Salah", "22 345 678"));

		assertThat(created.at("/student/username").asText()).isEqualTo("eya.bensalah");
		assertThat(created.at("/credentials")).hasSize(2);
		assertThat(created.at("/credentials/1/username").asText()).isEqualTo("22345678");
		assertThat(created.at("/credentials/0/temporaryPassword").asText()).hasSizeGreaterThanOrEqualTo(8);
		assertThat(created.at("/student/parents/0/relation").asText()).isEqualTo("mère");

		// The password is never shown again.
		call(get("/api/v1/students/" + created.at("/student/id").asText()), teacher)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.student.parents[0].phone").value("22345678"))
				.andExpect(jsonPath("$..temporaryPassword").doesNotExist());
	}

	@Test
	void duplicateNamesGetASuffixAndTheTeacherCanChooseAnother() throws Exception {
		createStudent("Amine", "Kefi");
		assertThat(createStudent("Amine", "Kefi").at("/student/username").asText()).isEqualTo("amine.kefi2");

		call(get("/api/v1/students/username-suggestion?username=amine.kefi"), teacher)
				.andExpect(jsonPath("$.available").value(false));
		Map<String, Object> body = studentBody("Amine", "Kefi");
		body.put("username", "amine.kefi");
		call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), teacher)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("username_taken"))
				.andExpect(jsonPath("$.message").value("L'identifiant amine.kefi est déjà utilisé."));
	}

	@Test
	void privateNotesNeverReachAStudentOrParent() throws Exception {
		JsonNode created = createStudent("Omar", "Saidi", parent("Nadia", "Saidi", "22345679"));
		String studentId = created.at("/student/id").asText();
		call(post("/api/v1/students/" + studentId + "/private-notes").contentType(MediaType.APPLICATION_JSON)
				.content("{\"body\":\"Plus à l'aise à l'oral.\"}"), teacher)
				.andExpect(status().isCreated());

		String student = firstLogin(created.at("/credentials/0"));
		String parent = firstLogin(created.at("/credentials/1"));
		for (String token : List.of(student, parent)) {
			call(get("/api/v1/students/" + studentId + "/private-notes"), token).andExpect(status().isForbidden());
			call(get("/api/v1/students/" + studentId), token).andExpect(status().isForbidden());
		}
		call(get("/api/v1/students/" + studentId + "/private-notes"), teacher)
				.andExpect(jsonPath("$[0].body").value("Plus à l'aise à l'oral."));
	}

	@Test
	void aTemporaryPasswordOpensNothingButThePasswordChange() throws Exception {
		JsonNode created = createStudent("Lina", "Bouzid");
		String token = token(created.at("/credentials/0/username").asText(), created.at("/credentials/0/temporaryPassword").asText());

		call(get("/api/v1/me"), token).andExpect(status().isOk()).andExpect(jsonPath("$.mustChangePassword").value(true));
		call(get("/api/v1/me/sessions?from=2026-01-01T00:00:00Z&to=2026-01-02T00:00:00Z"), token)
				.andExpect(status().isForbidden())
				.andExpect(jsonPath("$.code").value("password_change_required"));
	}

	@Test
	void aWeeklyRuleCreatesEverySessionAtTheRightLocalTime() throws Exception {
		String groupId = createGroup("7ème A · Math");
		LocalDate firstTuesday = LocalDate.now(TUNIS).plusWeeks(1).with(TemporalAdjusters.nextOrSame(DayOfWeek.TUESDAY));
		JsonNode created = createSeries(groupId, firstTuesday, firstTuesday.plusWeeks(3));

		assertThat(created.at("/count").asInt()).isEqualTo(4);
		Instant expected = firstTuesday.atTime(10, 0).atZone(TUNIS).toInstant();
		assertThat(Instant.parse(created.at("/first/startsAt").asText())).isEqualTo(expected);
		assertThat(created.at("/first/group/code").asText()).isEqualTo("7A");

		JsonNode groups = body(call(get("/api/v1/groups"), teacher));
		assertThat(groups.at("/0/schedule/0/weekday").asInt()).isEqualTo(2);
	}

	@Test
	void editingOneSessionOrTheFollowingOnes() throws Exception {
		String groupId = createGroup("9ème B · Math");
		LocalDate first = LocalDate.now(TUNIS).plusWeeks(1).with(TemporalAdjusters.nextOrSame(DayOfWeek.MONDAY));
		createSeries(groupId, first, first.plusWeeks(3));
		List<JsonNode> week = sessions(first, first.plusWeeks(4));
		assertThat(week).hasSize(4);

		// This session only: 17:00 instead of 10:00, the others do not move.
		call(put("/api/v1/sessions/" + week.get(1).at("/id").asText() + "?scope=ONE").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(update(first.plusWeeks(1), "17:00", "18:30"))), teacher)
				.andExpect(status().isOk());
		List<JsonNode> after = sessions(first, first.plusWeeks(4));
		assertThat(localHours(after)).containsExactly(10, 17, 10, 10);

		// This one and the following: from the third on, 14:00; the first two stay.
		call(put("/api/v1/sessions/" + after.get(2).at("/id").asText() + "?scope=FOLLOWING").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(update(first.plusWeeks(2), "14:00", "15:30"))), teacher)
				.andExpect(status().isOk());
		assertThat(localHours(sessions(first, first.plusWeeks(4)))).containsExactly(10, 17, 14, 14);
	}

	@Test
	void cancellingTheFollowingSessionsKeepsThemVisibleWithTheReason() throws Exception {
		String groupId = createGroup("Bac Math");
		LocalDate first = LocalDate.now(TUNIS).plusWeeks(1).with(TemporalAdjusters.nextOrSame(DayOfWeek.SATURDAY));
		createSeries(groupId, first, first.plusWeeks(2));
		List<JsonNode> list = sessions(first, first.plusWeeks(3));

		call(post("/api/v1/sessions/" + list.get(1).at("/id").asText() + "/cancel?scope=FOLLOWING")
				.contentType(MediaType.APPLICATION_JSON).content("{\"reason\":\"Examen au lycée\"}"), teacher)
				.andExpect(status().isOk());

		List<JsonNode> after = sessions(first, first.plusWeeks(3));
		assertThat(after.stream().map(s -> s.at("/status").asText())).containsExactly("PLANNED", "CANCELLED", "CANCELLED");
		assertThat(after.get(2).at("/cancelReason").asText()).isEqualTo("Examen au lycée");
	}

	@Test
	void attendanceEndsAPastSessionAndFeedsTheStatistics() throws Exception {
		JsonNode amine = createStudent("Amine", "Kefi");
		JsonNode omar = createStudent("Omar", "Saidi");
		String groupId = createGroup("7ème A · Math");
		call(put("/api/v1/groups/" + groupId + "/members").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("studentIds", List.of(amine.at("/student/id").asText(), omar.at("/student/id").asText())))), teacher)
				.andExpect(jsonPath("$.members.length()").value(2));

		LocalDate yesterday = LocalDate.now(TUNIS).minusDays(1);
		JsonNode created = body(call(post("/api/v1/sessions").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				session(groupId, yesterday, false, null))), teacher));
		String sessionId = created.at("/first/id").asText();

		// One tap: Omar absent, Amine present by default.
		call(put("/api/v1/sessions/" + sessionId + "/attendance").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("entries", List.of(
						Map.of("studentId", amine.at("/student/id").asText(), "status", "PRESENT"),
						Map.of("studentId", omar.at("/student/id").asText(), "status", "ABSENT"))))), teacher)
				.andExpect(jsonPath("$.session.status").value("DONE"))
				.andExpect(jsonPath("$.session.absent").value(1));

		call(get("/api/v1/students/" + omar.at("/student/id").asText()), teacher)
				.andExpect(jsonPath("$.attendance.absent").value(1))
				.andExpect(jsonPath("$.attendance.rate").value(0))
				.andExpect(jsonPath("$.attendance.recent[0].status").value("ABSENT"));
		call(get("/api/v1/students"), teacher)
				.andExpect(jsonPath("$[0].firstName").value("Amine"))
				.andExpect(jsonPath("$[0].attendanceRate").value(100));
	}

	@Test
	void onlyTheStudentOfTheGroupSeesTheMeetLinkAndParentsNever() throws Exception {
		JsonNode sara = createStudent("Sara", "Ben Amor", parent("Leila", "Ben Amor", "22345680"));
		JsonNode other = createStudent("Rayen", "Mansour");
		JsonNode lesson = body(call(post("/api/v1/groups/private-lessons").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("studentId", sara.at("/student/id").asText(), "subjectId", subjectId))), teacher));
		assertThat(lesson.at("/privateLesson").asBoolean()).isTrue();
		assertThat(lesson.at("/name").asText()).startsWith("Sara Ben Amor · ");

		LocalDate tomorrow = LocalDate.now(TUNIS).plusDays(1);
		call(post("/api/v1/sessions").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				session(lesson.at("/id").asText(), tomorrow, false, "https://meet.google.com/abc-defg-hij"))), teacher)
				.andExpect(status().isCreated());
		String range = "?from=" + tomorrow.atStartOfDay(TUNIS).toInstant() + "&to=" + tomorrow.plusDays(1).atStartOfDay(TUNIS).toInstant();

		String student = firstLogin(sara.at("/credentials/0"));
		call(get("/api/v1/me/sessions" + range), student)
				.andExpect(jsonPath("$[0].meetUrl").value("https://meet.google.com/abc-defg-hij"))
				.andExpect(jsonPath("$[0].prepNote").doesNotExist());
		String parent = firstLogin(sara.at("/credentials/1"));
		call(get("/api/v1/me/sessions" + range + "&studentId=" + sara.at("/student/id").asText()), parent)
				.andExpect(jsonPath("$[0].meetUrl").doesNotExist());
		call(get("/api/v1/me/sessions" + range + "&studentId=" + other.at("/student/id").asText()), parent)
				.andExpect(status().isNotFound());
		String outsider = firstLogin(other.at("/credentials/0"));
		call(get("/api/v1/me/sessions" + range), outsider).andExpect(jsonPath("$.length()").value(0));
	}

	@Test
	void archivingBlocksLoginAndClosesTheParentAccountThenRestoreBringsThemBack() throws Exception {
		JsonNode created = createStudent("Malek", "Jaziri", parent("Rim", "Jaziri", "22345681"));
		String studentId = created.at("/student/id").asText();
		String studentLogin = created.at("/credentials/0/username").asText();
		String studentPassword = created.at("/credentials/0/temporaryPassword").asText();

		call(post("/api/v1/students/" + studentId + "/archive"), teacher).andExpect(status().isNoContent());
		login(studentLogin, studentPassword).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("account_disabled"));
		login("22345681", created.at("/credentials/1/temporaryPassword").asText()).andExpect(status().isForbidden());
		call(get("/api/v1/students?archived=true"), teacher).andExpect(jsonPath("$[0].archived").value(true));
		call(get("/api/v1/students"), teacher).andExpect(jsonPath("$.length()").value(0));

		call(post("/api/v1/students/" + studentId + "/restore"), teacher).andExpect(status().isNoContent());
		login(studentLogin, studentPassword).andExpect(status().isOk());
	}

	@Test
	void familiesHearWhenASessionIsCancelledMovedOrRestored() throws Exception {
		JsonNode adam = createStudent("Adam", "Gharbi", parent("Mouna", "Gharbi", "22345680"));
		Map<String, Object> linaBody = studentBody("Lina", "Bouzid");
		linaBody.put("createLogin", false);
		linaBody.put("parents", List.of(parent("Karim", "Bouzid", "22345681")));
		JsonNode lina = body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(linaBody)), teacher).andExpect(status().isCreated()));
		String groupId = createGroup("4ème année · Maths");
		call(put("/api/v1/groups/" + groupId + "/members").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("studentIds", List.of(adam.at("/student/id").asText(), lina.at("/student/id").asText())))), teacher)
				.andExpect(status().isOk());
		LocalDate monday = LocalDate.now(TUNIS).with(TemporalAdjusters.next(DayOfWeek.MONDAY));
		createSeries(groupId, monday, monday.plusWeeks(3));
		List<JsonNode> series = sessions(monday, monday.plusWeeks(4));
		assertThat(series).hasSize(4);
		String adamToken = firstLogin(adam.at("/credentials/0"));
		String mouna = firstLogin(adam.at("/credentials/1"));
		String karim = firstLogin(credentialOf(lina, "22345681"));

		// Cancel one session: the parents and the child with a login hear it; the teacher does not.
		call(post("/api/v1/sessions/" + id(series, 0) + "/cancel").contentType(MediaType.APPLICATION_JSON)
				.content("{\"reason\":\"Sortie scolaire\"}"), teacher).andExpect(status().isOk());
		JsonNode cancelled = notifications(mouna);
		assertThat(cancelled.at("/unreadCount").asLong()).isEqualTo(1);
		assertThat(cancelled.at("/items/0/type").asText()).isEqualTo("SESSION_CANCELLED");
		assertThat(cancelled.at("/items/0/childFirstName").asText()).isEqualTo("Adam");
		assertThat(cancelled.at("/items/0/groupName").asText()).isEqualTo("4ème année · Maths");
		assertThat(cancelled.at("/items/0/reason").asText()).isEqualTo("Sortie scolaire");
		assertThat(cancelled.at("/items/0/startsAt").asText()).isEqualTo(series.get(0).at("/startsAt").asText());
		assertThat(cancelled.at("/items/0/read").asBoolean()).isFalse();
		assertThat(notifications(adamToken).at("/items/0/childFirstName").isNull()).isTrue();
		assertThat(notifications(karim).at("/items/0/childFirstName").asText()).isEqualTo("Lina");
		assertThat(notifications(teacher).at("/items")).isEmpty();
		// Lina does not sign in: her parent is told, she gets nothing of her own.
		assertThat(jdbc.queryForObject("select count(*) from notifications where student_id = ? and child_first_name is null",
				Long.class, UUID.fromString(lina.at("/student/id").asText()))).isZero();

		// A new time is worth a notification, with the former time; a new room alone is not.
		call(put("/api/v1/sessions/" + id(series, 1)).contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(update(day(series.get(1)), "15:00", "16:30"))), teacher).andExpect(status().isOk());
		JsonNode moved = notifications(mouna).at("/items/0");
		assertThat(moved.at("/type").asText()).isEqualTo("SESSION_MOVED");
		assertThat(moved.at("/previousStartsAt").asText()).isEqualTo(series.get(1).at("/startsAt").asText());
		assertThat(Instant.parse(moved.at("/startsAt").asText()).atZone(TUNIS).getHour()).isEqualTo(15);
		Map<String, Object> roomOnly = new HashMap<>(update(day(series.get(2)), "10:00", "11:30"));
		roomOnly.put("location", "Salle 3");
		call(put("/api/v1/sessions/" + id(series, 2)).contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(roomOnly)), teacher).andExpect(status().isOk());
		assertThat(notifications(mouna).at("/items")).hasSize(2);

		call(post("/api/v1/sessions/" + id(series, 0) + "/restore"), teacher).andExpect(status().isOk());
		assertThat(notifications(mouna).at("/items/0/type").asText()).isEqualTo("SESSION_RESTORED");

		// "This one and the following": one notification that says how many.
		call(post("/api/v1/sessions/" + id(series, 2) + "/cancel?scope=FOLLOWING").contentType(MediaType.APPLICATION_JSON)
				.content("{\"reason\":\"Vacances\"}"), teacher).andExpect(status().isOk());
		JsonNode page = notifications(mouna);
		assertThat(page.at("/items/0/sessionCount").asInt()).isEqualTo(2);
		assertThat(page.at("/items/0/startsAt").asText()).isEqualTo(series.get(2).at("/startsAt").asText());
		assertThat(page.at("/unreadCount").asLong()).isEqualTo(4);

		// Each person reads and clears their own notifications only.
		String latest = page.at("/items/0/id").asText();
		call(post("/api/v1/me/notifications/" + latest + "/read"), adamToken)
				.andExpect(status().isNotFound())
				.andExpect(jsonPath("$.code").value("notification_not_found"));
		call(post("/api/v1/me/notifications/" + latest + "/read"), mouna).andExpect(status().isNoContent());
		call(get("/api/v1/me/notifications/unread-count"), mouna).andExpect(jsonPath("$.count").value(3));
		call(post("/api/v1/me/notifications/read-all"), mouna).andExpect(status().isNoContent());
		assertThat(notifications(mouna).at("/unreadCount").asLong()).isZero();
		assertThat(notifications(mouna).at("/items/3/read").asBoolean()).isTrue();
		assertThat(notifications(adamToken).at("/unreadCount").asLong()).isEqualTo(4);
	}

	@Test
	void aSessionAlreadyPastChangesNothingForTheFamilies() throws Exception {
		JsonNode adam = createStudent("Adam", "Gharbi", parent("Mouna", "Gharbi", "22345682"));
		String groupId = createGroup("4ème année · Maths");
		call(put("/api/v1/groups/" + groupId + "/members").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("studentIds", List.of(adam.at("/student/id").asText())))), teacher).andExpect(status().isOk());
		String past = body(call(post("/api/v1/sessions").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				session(groupId, LocalDate.now(TUNIS).minusDays(2), false, null))), teacher)
				.andExpect(status().isCreated())).at("/first/id").asText();
		call(post("/api/v1/sessions/" + past + "/cancel"), teacher).andExpect(status().isOk());

		assertThat(notifications(firstLogin(adam.at("/credentials/1"))).at("/items")).isEmpty();
	}

	// ── Helpers ──

	private JsonNode notifications(String token) throws Exception {
		return body(call(get("/api/v1/me/notifications"), token).andExpect(status().isOk()));
	}

	private static String id(List<JsonNode> sessions, int index) {
		return sessions.get(index).at("/id").asText();
	}

	/** The Tunisian day of a session. */
	private static LocalDate day(JsonNode session) {
		return Instant.parse(session.at("/startsAt").asText()).atZone(TUNIS).toLocalDate();
	}

	private static JsonNode credentialOf(JsonNode created, String username) {
		for (JsonNode credential : created.at("/credentials")) {
			if (credential.at("/username").asText().equals(username)) {
				return credential;
			}
		}
		throw new AssertionError("no login details for " + username);
	}

	@SafeVarargs
	private JsonNode createStudent(String firstName, String lastName, Map<String, Object>... parents) throws Exception {
		Map<String, Object> body = studentBody(firstName, lastName);
		body.put("parents", List.of(parents));
		return body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), teacher)
				.andExpect(status().isCreated()));
	}

	private Map<String, Object> studentBody(String firstName, String lastName) {
		Map<String, Object> body = new HashMap<>();
		body.put("firstName", firstName);
		body.put("lastName", lastName);
		body.put("levelId", levelId);
		body.put("parents", List.of());
		return body;
	}

	private static Map<String, Object> parent(String firstName, String lastName, String phone) {
		return Map.of("firstName", firstName, "lastName", lastName, "phone", phone, "relation", "mère");
	}

	private String createGroup(String name) throws Exception {
		return body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", name, "subjectId", subjectId, "levelId", levelId))), teacher)
				.andExpect(status().isCreated())).at("/id").asText();
	}

	private JsonNode createSeries(String groupId, LocalDate first, LocalDate until) throws Exception {
		Map<String, Object> body = session(groupId, first, true, null);
		body.put("repeatUntil", until.toString());
		return body(call(post("/api/v1/sessions").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), teacher)
				.andExpect(status().isCreated()));
	}

	private static Map<String, Object> session(String groupId, LocalDate date, boolean weekly, String meetUrl) {
		Map<String, Object> body = new HashMap<>();
		body.put("groupId", groupId);
		body.put("date", date.toString());
		body.put("startTime", "10:00");
		body.put("endTime", "11:30");
		body.put("mode", meetUrl == null ? "IN_PERSON" : "ONLINE");
		body.put("meetUrl", meetUrl);
		body.put("repeatWeekly", weekly);
		return body;
	}

	private static Map<String, Object> update(LocalDate date, String start, String end) {
		return Map.of("date", date.toString(), "startTime", start, "endTime", end, "mode", "IN_PERSON");
	}

	private List<JsonNode> sessions(LocalDate from, LocalDate to) throws Exception {
		JsonNode list = body(call(get("/api/v1/sessions?from=" + from.atStartOfDay(TUNIS).toInstant() + "&to=" + to.atStartOfDay(TUNIS).toInstant()), teacher)
				.andExpect(status().isOk()));
		List<JsonNode> out = new ArrayList<>();
		list.forEach(out::add);
		return out;
	}

	private static List<Integer> localHours(List<JsonNode> sessions) {
		return sessions.stream().map(s -> Instant.parse(s.at("/startsAt").asText()).atZone(TUNIS).getHour()).toList();
	}

	/** Signs in with the temporary password and chooses a real one, as the app does. */
	private String firstLogin(JsonNode credential) throws Exception {
		String token = token(credential.at("/username").asText(), credential.at("/temporaryPassword").asText());
		call(post("/api/v1/me/password").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("currentPassword", credential.at("/temporaryPassword").asText(), "newPassword", PASSWORD))), token)
				.andExpect(status().isNoContent());
		return token;
	}

	private ResultActions login(String login, String password) throws Exception {
		return mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("login", login, "password", password))));
	}

	private String token(String login, String password) throws Exception {
		return body(login(login, password).andExpect(status().isOk())).at("/accessToken").asText();
	}

	private ResultActions call(MockHttpServletRequestBuilder request, String token) throws Exception {
		return mvc.perform(request.header(HttpHeaders.AUTHORIZATION, "Bearer " + token));
	}

	private JsonNode body(ResultActions result) throws Exception {
		return json.readTree(result.andReturn().getResponse().getContentAsString());
	}
}
