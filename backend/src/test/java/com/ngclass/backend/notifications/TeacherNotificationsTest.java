package com.ngclass.backend.notifications;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.school.repository.LevelRepository;
import com.ngclass.backend.work.service.HomeworkJobs;
import java.io.ByteArrayOutputStream;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
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

/**
 * Release 2 (spec 08): the teacher hears of the work her pupils and their parents send, gathered by homework while
 * unread, and of each homework's deadline: who did not send, or that everyone did.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class TeacherNotificationsTest {
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
	@Autowired
	private HomeworkJobs jobs;

	private String ines;
	private String levelId;
	private String maths;
	private String group4A;
	private String document;
	private String adamId;
	private String linaId;
	private String adam;
	private String mouna;

	@BeforeEach
	void cleanAndSetUp() throws Exception {
		jdbc.execute("""
				truncate submissions, assignment_recipients, assignments, content_views, content_shares, content_items, file_assets,
				chapters, notifications, attendance, sessions, recurrence_rules, comments, private_notes, group_members, class_groups,
				parent_students, parents, students, subjects, refresh_tokens, users cascade""");
		account("enseignante");
		ines = token("enseignante", PASSWORD);
		levelId = levels.findAllByOrderByPositionAsc().get(3).getId().toString();
		maths = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON).content("{\"nameFr\":\"Mathématiques\"}"), ines)
				.andExpect(status().isCreated())).at("/id").asText();
		group4A = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "4ème année · Maths", "subjectId", maths, "levelId", levelId))), ines)
				.andExpect(status().isCreated())).at("/id").asText();

		// Adam has his own login; Lina has none. Mouna is the mother of both.
		JsonNode created = createStudent("Adam", true, List.of(Map.of("firstName", "Mouna", "lastName", "Gharbi", "phone", "20000001", "relation", "mother")));
		adamId = created.at("/student/id").asText();
		adam = firstLogin(credential(created, "STUDENT"));
		mouna = firstLogin(credential(created, "PARENT"));
		String mounaParentId = body(call(get("/api/v1/parents"), ines)).at("/0/id").asText();
		linaId = createStudent("Lina", false, List.of(Map.of("existingParentId", mounaParentId))).at("/student/id").asText();

		// A published document, not shared with the group: homework alone lets the family open it.
		document = body(call(multipart("/api/v1/contents")
				.file(new MockMultipartFile("file", "serie2.pdf", "application/pdf", pdf(2)))
				.file(new MockMultipartFile("meta", "", MediaType.APPLICATION_JSON_VALUE, json.writeValueAsBytes(Map.of(
						"title", "Série 2 : les fractions", "subjectId", maths, "levelId", levelId, "tag", "SERIE", "draft", false, "groupIds", List.of())))),
				ines).andExpect(status().isCreated())).at("/id").asText();
	}

	@Test
	void workSentReachesTheTeacherGatheredByHomeworkUntilSheReadsIt() throws Exception {
		String id = idOf(assign(Map.of("allowLate", true)));
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		JsonNode page = body(call(get("/api/v1/me/notifications"), ines));
		assertThat(page.at("/unreadCount").asInt()).isEqualTo(1);
		JsonNode sent = page.at("/items/0");
		assertThat(sent.at("/type").asText()).isEqualTo("WORK_SUBMITTED");
		assertThat(sent.at("/assignmentId").asText()).isEqualTo(id);
		assertThat(sent.at("/title").asText()).isEqualTo("Série 2 : les fractions");
		assertThat(sent.at("/groupName").asText()).isEqualTo("4ème année · Maths");
		assertThat(sent.at("/pupils/0/firstName").asText()).isEqualTo("Adam");
		assertThat(sent.at("/pupils/0/lastName").asText()).isEqualTo("Gharbi");
		assertThat(sent.at("/late").asBoolean()).isFalse();

		// The mother sends Lina's work, then Adam replaces his: still one notification, two pupils, latest time.
		submit(mouna, id, linaId, pdf(1)).andExpect(status().isOk());
		submit(adam, id, null, pdf(2)).andExpect(status().isOk());
		page = body(call(get("/api/v1/me/notifications"), ines));
		assertThat(page.at("/items")).hasSize(1);
		assertThat(page.at("/unreadCount").asInt()).isEqualTo(1);
		assertThat(page.at("/items/0/pupils")).hasSize(2);
		assertThat(page.at("/items/0/pupils/0/id").asText()).isEqualTo(adamId);
		assertThat(page.at("/items/0/pupils/1/id").asText()).isEqualTo(linaId);
		assertThat(Instant.parse(page.at("/items/0/createdAt").asText())).isAfter(Instant.parse(sent.at("/createdAt").asText()));

		// Once read, the next work starts a new one; after the deadline it says "late".
		call(post("/api/v1/me/notifications/" + sent.at("/id").asText() + "/read"), ines).andExpect(status().isNoContent());
		jdbc.update("update assignments set deadline_at = now() - interval '1 hour'");
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		page = body(call(get("/api/v1/me/notifications"), ines));
		assertThat(page.at("/items")).hasSize(2);
		assertThat(page.at("/unreadCount").asInt()).isEqualTo(1);
		assertThat(page.at("/items/0/pupils")).hasSize(1);
		assertThat(page.at("/items/0/late").asBoolean()).isTrue();
		assertThat(page.at("/items/1/read").asBoolean()).isTrue();

		// The families never get these; another teacher sees nothing.
		for (JsonNode item : body(call(get("/api/v1/me/notifications"), mouna)).at("/items")) {
			assertThat(item.at("/type").asText()).isEqualTo("HOMEWORK_ASSIGNED");
			assertThat(item.at("/pupils")).isEmpty();
		}
		account("sonia");
		assertThat(body(call(get("/api/v1/me/notifications"), token("sonia", PASSWORD))).at("/items")).isEmpty();
	}

	@Test
	void atTheDeadlineTheTeacherHearsOnceWhoDidNotSend() throws Exception {
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		jobs.tellDeadlines();
		assertThat(deadlines()).isEmpty();

		jdbc.update("update assignments set deadline_at = now() - interval '1 minute' where id = ?::uuid", id);
		jobs.tellDeadlines();
		jobs.tellDeadlines();
		List<JsonNode> told = deadlines();
		assertThat(told).hasSize(1);
		assertThat(told.getFirst().at("/assignmentId").asText()).isEqualTo(id);
		assertThat(told.getFirst().at("/pupils")).hasSize(1);
		assertThat(told.getFirst().at("/pupils/0/firstName").asText()).isEqualTo("Lina");

		// A later deadline asks again; this time everyone sent.
		call(put("/api/v1/assignments/" + id + "/deadline").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("deadlineAt", Instant.now().plus(1, ChronoUnit.DAYS).toString()))), ines)
				.andExpect(status().isOk());
		submit(mouna, id, linaId, pdf(1)).andExpect(status().isOk());
		jdbc.update("update assignments set deadline_at = now() - interval '1 minute' where id = ?::uuid", id);
		jobs.tellDeadlines();
		told = deadlines();
		assertThat(told).hasSize(2);
		assertThat(told.getFirst().at("/pupils")).isEmpty();

		// Closed before its deadline, or nothing to send: nothing to tell.
		String closed = idOf(assign(Map.of("title", "Série 3")));
		call(post("/api/v1/assignments/" + closed + "/close"), ines).andExpect(status().isNoContent());
		idOf(assign(Map.of("title", "Lecture", "submissionMode", "NONE")));
		jdbc.update("update assignments set deadline_at = now() - interval '1 minute' where title in ('Série 3', 'Lecture')");
		jdbc.update("update assignments set closed_at = now() - interval '2 minutes' where title = 'Série 3'");
		jobs.tellDeadlines();
		assertThat(deadlines()).hasSize(2);
		assertThat(jdbc.queryForObject("select count(*) from assignments where deadline_notified_at is null", Integer.class)).isZero();
	}

	private List<JsonNode> deadlines() throws Exception {
		List<JsonNode> out = new ArrayList<>();
		for (JsonNode item : body(call(get("/api/v1/me/notifications"), ines)).at("/items")) {
			if (item.at("/type").asText().equals("DEADLINE_PASSED")) {
				out.add(item);
			}
		}
		return out;
	}

	// ── Helpers ──

	private ResultActions assign(Map<String, Object> overrides) throws Exception {
		Map<String, Object> body = new HashMap<>();
		body.put("contentItemId", document);
		body.put("title", "Série 2 : les fractions");
		body.put("groupId", group4A);
		body.put("deadlineAt", Instant.now().plus(2, ChronoUnit.DAYS).toString());
		body.put("submissionMode", "FILE");
		body.put("allowLate", false);
		body.put("instructions", "Exercices 1 à 3.");
		body.putAll(overrides);
		return call(post("/api/v1/assignments").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), ines);
	}

	private String idOf(ResultActions created) throws Exception {
		return body(created.andExpect(status().isCreated())).at("/id").asText();
	}

	private ResultActions submit(String token, String assignmentId, String studentId, byte[] data) throws Exception {
		return call(multipart("/api/v1/me/assignments/" + assignmentId + "/submission" + (studentId == null ? "" : "?studentId=" + studentId))
				.file(new MockMultipartFile("file", "travail.pdf", "application/pdf", data)), token);
	}

	private JsonNode createStudent(String firstName, boolean login, List<Map<String, Object>> parents) throws Exception {
		Map<String, Object> body = new HashMap<>(Map.of("firstName", firstName, "lastName", "Gharbi", "levelId", levelId,
				"groupIds", List.of(group4A), "createLogin", login));
		body.put("parents", parents);
		return body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), ines)
				.andExpect(status().isCreated()));
	}

	private static byte[] pdf(int pages) throws Exception {
		try (PDDocument pdf = new PDDocument(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
			for (int i = 0; i < pages; i++) {
				pdf.addPage(new PDPage(PDRectangle.A4));
			}
			pdf.save(out);
			return out.toByteArray();
		}
	}

	private void account(String username) {
		users.save(User.builder()
				.role(Role.TEACHER)
				.username(username)
				.firstName(username)
				.lastName("Test")
				.passwordHash(passwordEncoder.encode(PASSWORD))
				.build());
	}

	private static JsonNode credential(JsonNode created, String role) {
		for (JsonNode credential : created.at("/credentials")) {
			if (credential.at("/role").asText().equals(role)) {
				return credential;
			}
		}
		throw new AssertionError("no login details for " + role);
	}

	private String firstLogin(JsonNode credential) throws Exception {
		String token = token(credential.at("/username").asText(), credential.at("/temporaryPassword").asText());
		call(post("/api/v1/me/password").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("currentPassword", credential.at("/temporaryPassword").asText(), "newPassword", PASSWORD))), token)
				.andExpect(status().isNoContent());
		return token;
	}

	private String token(String login, String password) throws Exception {
		return body(mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("login", login, "password", password))))
				.andExpect(status().isOk())).at("/accessToken").asText();
	}

	private ResultActions call(MockHttpServletRequestBuilder request, String token) throws Exception {
		return mvc.perform(request.header(HttpHeaders.AUTHORIZATION, "Bearer " + token));
	}

	private JsonNode body(ResultActions result) throws Exception {
		return json.readTree(result.andReturn().getResponse().getContentAsString());
	}
}
