package com.ngclass.backend.work;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
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

/** Release 2, step 3 (spec 06): homework given, sent by the pupil or a parent, "Manquant" after the deadline. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class HomeworkTest {
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
	void homeworkIsGivenSentByThePupilOrAParentAndFollowedByTheTeacher() throws Exception {
		JsonNode created = body(assign(Map.of()).andExpect(status().isCreated()));
		assertThat(created.at("/recipients").asInt()).isEqualTo(2);
		assertThat(created.at("/counts/todo").asInt()).isEqualTo(2);
		assertThat(created.at("/done").asBoolean()).isFalse();
		String id = created.at("/id").asText();
		JsonNode list = body(call(get("/api/v1/assignments"), ines));
		assertThat(list.at("/0/id").asText()).isEqualTo(id);
		assertThat(list.at("/0/group/name").asText()).isEqualTo("4ème année · Maths");

		// Adam and his mother hear of it; the mother once per child.
		JsonNode notices = body(call(get("/api/v1/me/notifications"), adam));
		assertThat(notices.at("/items/0/type").asText()).isEqualTo("HOMEWORK_ASSIGNED");
		assertThat(notices.at("/items/0/title").asText()).isEqualTo("Série 2 : les fractions");
		assertThat(body(call(get("/api/v1/me/notifications"), mouna)).at("/items")).hasSize(2);

		// Adam sees it, opens the document (not in Cours: given as homework) and sends his work.
		JsonNode mine = body(call(get("/api/v1/me/assignments"), adam).andExpect(status().isOk()));
		assertThat(mine.at("/0/status").asText()).isEqualTo("TODO");
		assertThat(mine.at("/0/subject/name/fr").asText()).isEqualTo("Mathématiques");
		JsonNode detail = body(call(get("/api/v1/me/assignments/" + id), adam).andExpect(status().isOk()));
		assertThat(detail.at("/canSubmit").asBoolean()).isTrue();
		assertThat(detail.at("/instructions").asText()).isEqualTo("Exercices 1 à 3.");
		call(get("/api/v1/contents/" + document + "/view"), adam).andExpect(status().isOk());
		submit(adam, id, null, pdf(3)).andExpect(status().isOk())
				.andExpect(jsonPath("$.homework.status").value("SUBMITTED"))
				.andExpect(jsonPath("$.submission.pageCount").value(3));
		// Replaced before the deadline: the last one counts.
		submit(adam, id, null, pdf(1)).andExpect(status().isOk()).andExpect(jsonPath("$.submission.pageCount").value(1));

		// Mouna sends Lina's work for her.
		submit(mouna, id, linaId, pdf(2)).andExpect(status().isOk()).andExpect(jsonPath("$.homework.status").value("SUBMITTED"));
		assertThat(body(call(get("/api/v1/me/assignments?studentId=" + adamId), mouna)).at("/0/status").asText()).isEqualTo("SUBMITTED");

		// The teacher sees both, and opens Lina's work through signed links that need no token.
		JsonNode teacherDetail = body(call(get("/api/v1/assignments/" + id), ines).andExpect(status().isOk()));
		assertThat(teacherDetail.at("/assignment/counts/submitted").asInt()).isEqualTo(2);
		assertThat(teacherDetail.at("/recipients/1/firstName").asText()).isEqualTo("Lina");
		String submission = teacherDetail.at("/recipients/1/submissionId").asText();
		JsonNode view = body(call(get("/api/v1/assignments/submissions/" + submission + "/view"), ines).andExpect(status().isOk()));
		assertThat(view.at("/pageUrls")).hasSize(2);
		assertThat(view.at("/title").asText()).isEqualTo("Lina Gharbi · Série 2 : les fractions");
		mvc.perform(get("/api/v1/" + view.at("/pageUrls/0").asText()))
				.andExpect(status().isOk())
				.andExpect(header().string(HttpHeaders.CONTENT_TYPE, "image/jpeg"));
		call(get("/api/v1/me/assignments/" + id + "/submission/view"), adam).andExpect(status().isOk());
	}

	@Test
	void afterTheDeadlineWhatWasNotSentIsMissingAndALaterDeadlineGivesItBack() throws Exception {
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		jdbc.update("update assignments set deadline_at = now() - interval '1 hour'");

		// Read at once as "Manquant", then written by the job.
		assertThat(body(call(get("/api/v1/me/assignments?studentId=" + linaId), mouna)).at("/0/status").asText()).isEqualTo("MISSING");
		jobs.markMissing();
		assertThat(jdbc.queryForObject("select count(*) from assignment_recipients where status = 'MISSING'", Integer.class)).isEqualTo(1);
		JsonNode item = body(call(get("/api/v1/assignments"), ines)).at("/0");
		assertThat(item.at("/done").asBoolean()).isTrue();
		assertThat(item.at("/counts/missing").asInt()).isEqualTo(1);
		assertThat(item.at("/counts/submitted").asInt()).isEqualTo(1);

		// Late is not accepted here.
		submit(mouna, id, linaId, pdf(1)).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("deadline_passed"));
		assertThat(body(call(get("/api/v1/me/assignments/" + id + "?studentId=" + linaId), mouna)).at("/canSubmit").asBoolean()).isFalse();

		// A new deadline: Lina may send again.
		call(put("/api/v1/assignments/" + id + "/deadline").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("deadlineAt", Instant.now().plus(2, ChronoUnit.DAYS).toString()))), ines)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.counts.todo").value(1));
		submit(mouna, id, linaId, pdf(1)).andExpect(status().isOk());

		// With late accepted, a work sent after the deadline is "Rendu en retard".
		String late = idOf(assign(Map.of("allowLate", true, "title", "Série 3")));
		jdbc.update("update assignments set deadline_at = now() - interval '1 hour' where title = 'Série 3'");
		submit(adam, late, null, pdf(1)).andExpect(status().isOk()).andExpect(jsonPath("$.homework.status").value("LATE"));

		// Closed: nothing more can be sent.
		call(post("/api/v1/assignments/" + late + "/close"), ines).andExpect(status().isNoContent());
		submit(adam, late, null, pdf(1)).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("assignment_closed"));
	}

	@Test
	void somePupilsOnlyAndNewMembersOfTheWholeGroup() throws Exception {
		String forAdam = idOf(assign(Map.of("studentIds", List.of(adamId), "title", "Pour Adam")));
		assertThat(body(call(get("/api/v1/me/assignments?studentId=" + linaId), mouna))).isEmpty();
		call(get("/api/v1/me/assignments/" + forAdam + "?studentId=" + linaId), mouna).andExpect(status().isNotFound());

		// A whole-group homework reaches a pupil who joins before the deadline.
		idOf(assign(Map.of("title", "Pour tout le groupe")));
		String omarId = createStudent("Omar", false, List.of()).at("/student/id").asText();
		call(put("/api/v1/groups/" + group4A + "/members").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("studentIds", List.of(adamId, linaId, omarId)))), ines)
				.andExpect(status().isOk());
		JsonNode list = body(call(get("/api/v1/assignments"), ines));
		JsonNode whole = list.get(0).at("/title").asText().equals("Pour tout le groupe") ? list.get(0) : list.get(1);
		assertThat(whole.at("/recipients").asInt()).isEqualTo(3);

		// "Rien à rendre": no status, nothing to send.
		String read = idOf(assign(Map.of("submissionMode", "NONE", "title", "À lire")));
		JsonNode readItem = body(call(get("/api/v1/me/assignments/" + read), adam));
		assertThat(readItem.at("/homework/status").isNull()).isTrue();
		assertThat(readItem.at("/canSubmit").asBoolean()).isFalse();
		submit(adam, read, null, pdf(1)).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("nothing_to_submit"));
	}

	@Test
	void refusalsAndEachTeacherInHerOwnSpace() throws Exception {
		assign(Map.of("deadlineAt", Instant.now().minus(1, ChronoUnit.HOURS).toString()))
				.andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("deadline_past"));
		assign(Map.of("submissionMode", "QUIZ")).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("invalid_submission_mode"));
		String stranger = createStudent("Sami", false, List.of()).at("/student/id").asText();
		jdbc.update("delete from group_members where student_id = ?::uuid", stranger);
		assign(Map.of("studentIds", List.of(stranger))).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("not_group_member"));
		jdbc.update("update content_items set status = 'DRAFT'");
		assign(Map.of()).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("content_not_published"));
		jdbc.update("update content_items set status = 'PUBLISHED'");
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, "bonjour".getBytes()).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("work_file_not_allowed"));

		// Pupils and parents cannot use the teacher's side; another teacher reaches nothing.
		call(get("/api/v1/assignments"), adam).andExpect(status().isForbidden());
		account("sonia");
		String sonia = token("sonia", PASSWORD);
		assertThat(body(call(get("/api/v1/assignments"), sonia))).isEmpty();
		call(get("/api/v1/assignments/" + id), sonia).andExpect(status().isNotFound());
		call(post("/api/v1/assignments/" + id + "/close"), sonia).andExpect(status().isNotFound());
		String submission = body(submit(adam, id, null, pdf(1))).at("/submission/id").asText();
		call(get("/api/v1/assignments/submissions/" + submission + "/view"), sonia).andExpect(status().isNotFound());
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
