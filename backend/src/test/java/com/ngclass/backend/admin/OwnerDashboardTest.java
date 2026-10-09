package com.ngclass.backend.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
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
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/** The owner adds teachers; each teacher works in her own space and never reaches another one's (V6). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class OwnerDashboardTest {
	private static final String PASSWORD = "Secret2026x";

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

	private String admin;
	private String ines;
	private String levelId;

	@BeforeEach
	void cleanAndSignIn() throws Exception {
		jdbc.execute("""
				truncate notifications, attendance, sessions, recurrence_rules, comments, private_notes, group_members,
				class_groups, parent_students, parents, students, subjects, refresh_tokens, users cascade""");
		account(Role.ADMIN, "admin");
		account(Role.TEACHER, "enseignante");
		admin = token("admin", PASSWORD);
		ines = token("enseignante", PASSWORD);
		levelId = levels.findAllByOrderByPositionAsc().get(3).getId().toString();
	}

	@Test
	void theOwnerAddsATeacherWhoStartsWithAnEmptySpaceOfHerOwn() throws Exception {
		// Ines already teaches: a subject, a group with a pupil and a parent, a session.
		String lecture = createSubject(ines, "Lecture");
		String group = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "4ème année · Lecture", "subjectId", lecture, "levelId", levelId))), ines)
				.andExpect(status().isCreated())).at("/id").asText();
		Map<String, Object> pupil = new HashMap<>(Map.of("firstName", "Adam", "lastName", "Gharbi", "levelId", levelId,
				"groupIds", List.of(group), "createLogin", false));
		pupil.put("parents", List.of(Map.of("firstName", "Mouna", "lastName", "Gharbi", "phone", "20000001")));
		String adam = body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(pupil)), ines)
				.andExpect(status().isCreated())).at("/student/id").asText();
		LocalDate day = LocalDate.now(ZoneId.of("Africa/Tunis")).plusDays(2);
		String session = body(call(post("/api/v1/sessions").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("groupId", group, "date", day.toString(), "startTime", "10:00", "endTime", "11:30", "mode", "IN_PERSON",
						"repeatWeekly", false))), ines)
				.andExpect(status().isCreated())).at("/first/id").asText();

		// The owner adds Sonia.
		JsonNode created = body(call(post("/api/v1/admin/teachers").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("firstName", "Sonia", "lastName", "Ben Ali", "username", " Sonia.BenAli ", "phone", "22 345 678"))), admin)
				.andExpect(status().isCreated()));
		assertThat(created.at("/credential/username").asText()).isEqualTo("sonia.benali");
		assertThat(created.at("/credential/temporaryPassword").asText()).hasSizeGreaterThanOrEqualTo(8);
		assertThat(created.at("/teacher/awaitingFirstLogin").asBoolean()).isTrue();
		assertThat(created.at("/teacher/phone").asText()).isEqualTo("22345678");

		call(post("/api/v1/admin/teachers").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("firstName", "Autre", "lastName", "Compte", "username", "sonia.benali"))), admin)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("username_taken"));
		call(post("/api/v1/admin/teachers").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("firstName", "Autre", "lastName", "Compte", "username", "autre.compte", "phone", "1234"))), admin)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("invalid_phone"));

		// Sonia signs in (also with her phone), chooses her password, and finds an empty space.
		String temporary = created.at("/credential/temporaryPassword").asText();
		login("22345678", temporary).andExpect(status().isOk()).andExpect(jsonPath("$.user.mustChangePassword").value(true));
		String sonia = token("sonia.benali", temporary);
		call(post("/api/v1/me/password").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("currentPassword", temporary, "newPassword", PASSWORD))), sonia)
				.andExpect(status().isNoContent());
		sonia = token("sonia.benali", PASSWORD);

		assertThat(body(call(get("/api/v1/students"), sonia).andExpect(status().isOk()))).isEmpty();
		assertThat(body(call(get("/api/v1/groups"), sonia).andExpect(status().isOk()))).isEmpty();
		assertThat(body(call(get("/api/v1/parents"), sonia).andExpect(status().isOk()))).isEmpty();
		assertThat(body(call(get("/api/v1/subjects"), sonia).andExpect(status().isOk()))).isEmpty();
		assertThat(body(call(get("/api/v1/reference"), sonia)).at("/subjects")).isEmpty();
		Instant from = Instant.now().minus(1, ChronoUnit.DAYS);
		String range = "?from=" + from + "&to=" + from.plus(30, ChronoUnit.DAYS);
		assertThat(body(call(get("/api/v1/sessions" + range), sonia).andExpect(status().isOk()))).isEmpty();
		assertThat(body(call(get("/api/v1/sessions" + range), ines))).hasSize(1);

		// Nothing of Ines's is reachable for Sonia, even by id.
		call(get("/api/v1/students/" + adam), sonia).andExpect(status().isNotFound());
		call(get("/api/v1/groups/" + group), sonia).andExpect(status().isNotFound());
		call(get("/api/v1/sessions/" + session), sonia).andExpect(status().isNotFound());
		call(get("/api/v1/sessions" + range + "&groupId=" + group), sonia).andExpect(status().isNotFound());
		call(post("/api/v1/sessions/" + session + "/cancel"), sonia).andExpect(status().isNotFound());
		call(put("/api/v1/subjects/" + lecture).contentType(MediaType.APPLICATION_JSON).content("{\"nameFr\":\"Pris\"}"), sonia)
				.andExpect(status().isNotFound());
		call(get("/api/v1/students/" + adam + "/private-notes"), sonia).andExpect(status().isNotFound());
		call(get("/api/v1/students/" + adam + "/results"), sonia).andExpect(status().isNotFound());
		assertThat(body(call(get("/api/v1/search?q=adam"), ines)).at("/students")).hasSize(1);
		assertThat(body(call(get("/api/v1/search?q=adam"), sonia).andExpect(status().isOk())).at("/students")).isEmpty();

		// Ines's paper evaluations too; Sonia cannot give one to Ines's group.
		Map<String, Object> dictation = Map.of("groupId", group, "title", "Dictée n° 1", "heldOn", LocalDate.now().toString(), "maxScore", 20);
		String evaluation = body(call(post("/api/v1/evaluations").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(dictation)), ines)
				.andExpect(status().isCreated())).at("/evaluation/id").asText();
		assertThat(body(call(get("/api/v1/evaluations"), sonia).andExpect(status().isOk()))).isEmpty();
		call(get("/api/v1/evaluations/" + evaluation), sonia).andExpect(status().isNotFound());
		call(put("/api/v1/evaluations/" + evaluation + "/grades").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("grades", List.of(Map.of("studentId", adam, "score", 20))))), sonia)
				.andExpect(status().isNotFound());
		call(post("/api/v1/evaluations").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(dictation)), sonia)
				.andExpect(status().isNotFound());
		call(multipart("/api/v1/students/import/preview")
				.file(new MockMultipartFile("file", "classe.csv", "text/csv", "Prénom;Nom\nA;B\n".getBytes(StandardCharsets.UTF_8)))
				.param("groupId", group), sonia)
				.andExpect(status().isNotFound());

		// Her own work stays hers: same subject name, her own group, Ines's pupil cannot join it.
		String hers = createSubject(sonia, "Lecture");
		String sonias = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "5ème année · Lecture", "subjectId", hers, "levelId", levelId))), sonia)
				.andExpect(status().isCreated())).at("/id").asText();
		call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "Avec la matière d'Ines", "subjectId", lecture, "levelId", levelId))), sonia)
				.andExpect(status().isNotFound());
		call(put("/api/v1/groups/" + sonias + "/members").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("studentIds", List.of(adam)))), sonia)
				.andExpect(status().isNotFound());
		assertThat(body(call(get("/api/v1/groups"), ines))).hasSize(1);

		// The owner sees each space from outside: counts only.
		JsonNode page = body(call(get("/api/v1/admin/teachers"), admin).andExpect(status().isOk()));
		assertThat(page.at("/totals/teachers").asLong()).isEqualTo(2);
		assertThat(page.at("/totals/students").asLong()).isEqualTo(1);
		assertThat(page.at("/teachers/0/username").asText()).isEqualTo("enseignante");
		assertThat(page.at("/teachers/0/students").asLong()).isEqualTo(1);
		assertThat(page.at("/teachers/0/parents").asLong()).isEqualTo(1);
		assertThat(page.at("/teachers/0/groups").asLong()).isEqualTo(1);
		assertThat(page.at("/teachers/1/username").asText()).isEqualTo("sonia.benali");
		assertThat(page.at("/teachers/1/groups").asLong()).isEqualTo(1);
		assertThat(page.at("/teachers/1/students").asLong()).isZero();
		assertThat(page.at("/teachers/1/awaitingFirstLogin").asBoolean()).isFalse();
	}

	@Test
	void eachRoleStaysInItsPlace() throws Exception {
		call(get("/api/v1/admin/teachers"), ines).andExpect(status().isForbidden());
		call(post("/api/v1/admin/teachers").contentType(MediaType.APPLICATION_JSON).content("{}"), ines).andExpect(status().isForbidden());
		call(get("/api/v1/students"), admin).andExpect(status().isForbidden());
		call(get("/api/v1/groups"), admin).andExpect(status().isForbidden());
		assertThat(body(call(get("/api/v1/reference"), admin).andExpect(status().isOk())).at("/subjects")).isEmpty();
	}

	@Test
	void theOwnerClosesReopensAndResetsATeachersAccess() throws Exception {
		String id = users.findByUsername("enseignante").orElseThrow().getId().toString();

		call(post("/api/v1/admin/teachers/" + id + "/disable"), admin).andExpect(status().isNoContent());
		login("enseignante", PASSWORD)
				.andExpect(status().isForbidden())
				.andExpect(jsonPath("$.code").value("teacher_disabled"));
		JsonNode page = body(call(get("/api/v1/admin/teachers"), admin));
		assertThat(page.at("/teachers/0/active").asBoolean()).isFalse();
		assertThat(page.at("/totals/activeTeachers").asLong()).isZero();

		call(post("/api/v1/admin/teachers/" + id + "/enable"), admin).andExpect(status().isNoContent());
		login("enseignante", PASSWORD).andExpect(status().isOk());

		String temporary = body(call(post("/api/v1/admin/teachers/" + id + "/reset-password"), admin).andExpect(status().isOk()))
				.at("/temporaryPassword").asText();
		login("enseignante", PASSWORD).andExpect(status().isUnauthorized());
		login("enseignante", temporary).andExpect(status().isOk()).andExpect(jsonPath("$.user.mustChangePassword").value(true));

		String adminId = users.findByUsername("admin").orElseThrow().getId().toString();
		call(post("/api/v1/admin/teachers/" + adminId + "/reset-password"), admin)
				.andExpect(status().isNotFound())
				.andExpect(jsonPath("$.code").value("teacher_not_found"));
	}

	private void account(Role role, String username) {
		users.save(User.builder()
				.role(role)
				.username(username)
				.firstName(role == Role.ADMIN ? "Administrateur" : "Ines")
				.lastName(role == Role.ADMIN ? "NG Class" : "Haddad")
				.passwordHash(passwordEncoder.encode(PASSWORD))
				.build());
	}

	private String createSubject(String token, String nameFr) throws Exception {
		return body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("nameFr", nameFr))), token)
				.andExpect(status().isCreated())).at("/id").asText();
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
