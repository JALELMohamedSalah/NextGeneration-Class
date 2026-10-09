package com.ngclass.backend.work;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
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
import org.springframework.http.HttpMethod;
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

/** Release 2, step 4 (spec 06 and 07): the "À corriger" queue, scores and comments, corrected copies, Résultats. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class CorrectionTest {
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
	void copiesWaitInTheQueueAreCorrectedAndTheFamilySeesTheGrade() throws Exception {
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, pdf(2)).andExpect(status().isOk());
		submit(mouna, id, linaId, pdf(1)).andExpect(status().isOk());

		// "À corriger": the homework once, its copies oldest first.
		JsonNode queue = body(call(get("/api/v1/assignments/to-correct"), ines).andExpect(status().isOk()));
		assertThat(queue).hasSize(1);
		assertThat(queue.at("/0/assignment/id").asText()).isEqualTo(id);
		assertThat(queue.at("/0/assignment/subjectId").asText()).isEqualTo(maths);
		assertThat(queue.at("/0/items")).hasSize(2);
		assertThat(queue.at("/0/items/0/studentId").asText()).isEqualTo(adamId);
		assertThat(queue.at("/0/items/0/submissionId").asText()).isNotBlank();

		JsonNode copy = body(call(get(correction(id, adamId)), ines).andExpect(status().isOk()));
		assertThat(copy.at("/status").asText()).isEqualTo("SUBMITTED");
		assertThat(copy.at("/maxScore").asInt()).isEqualTo(20);
		assertThat(copy.at("/score").isNull()).isTrue();
		assertThat(copy.at("/submission/pageCount").asInt()).isEqualTo(2);

		// Corrected: a score in half points, a comment, a corrected copy.
		JsonNode saved = body(grade(id, adamId, "14.5", "Bon travail !").andExpect(status().isOk()));
		assertThat(saved.at("/status").asText()).isEqualTo("CORRECTED");
		assertThat(saved.at("/score").decimalValue()).isEqualByComparingTo("14.5");
		assertThat(saved.at("/comment").asText()).isEqualTo("Bon travail !");
		JsonNode attached = body(call(multipart(HttpMethod.PUT, correction(id, adamId) + "/file")
				.file(new MockMultipartFile("file", "correction.pdf", "application/pdf", pdf(1))), ines).andExpect(status().isOk()));
		assertThat(attached.at("/file/pageCount").asInt()).isEqualTo(1);
		assertThat(attached.at("/file/kind").asText()).isEqualTo("PDF");

		JsonNode left = body(call(get("/api/v1/assignments/to-correct"), ines));
		assertThat(left.at("/0/items")).hasSize(1);
		assertThat(left.at("/0/items/0/studentId").asText()).isEqualTo(linaId);
		JsonNode detail = body(call(get("/api/v1/assignments/" + id), ines));
		assertThat(detail.at("/assignment/counts/corrected").asInt()).isEqualTo(1);
		assertThat(detail.at("/assignment/average").decimalValue()).isEqualByComparingTo("14.5");

		// Adam and his mother see the grade, the comment and the corrected copy, and hear of it once.
		JsonNode mine = body(call(get("/api/v1/me/assignments/" + id), adam).andExpect(status().isOk()));
		assertThat(mine.at("/homework/status").asText()).isEqualTo("CORRECTED");
		assertThat(mine.at("/homework/score").decimalValue()).isEqualByComparingTo("14.5");
		assertThat(mine.at("/correction/score").decimalValue()).isEqualByComparingTo("14.5");
		assertThat(mine.at("/correction/comment").asText()).isEqualTo("Bon travail !");
		assertThat(mine.at("/correction/file/pageCount").asInt()).isEqualTo(1);
		assertThat(mine.at("/canSubmit").asBoolean()).isFalse();
		JsonNode view = body(call(get("/api/v1/me/assignments/" + id + "/correction/view"), adam).andExpect(status().isOk()));
		assertThat(view.at("/pageUrls")).hasSize(1);
		mvc.perform(get("/api/v1/" + view.at("/pageUrls/0").asText())).andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/notifications"), adam)).at("/items/0/type").asText()).isEqualTo("HOMEWORK_CORRECTED");
		assertThat(body(call(get("/api/v1/me/assignments/" + id + "?studentId=" + adamId), mouna)).at("/correction/score").decimalValue())
				.isEqualByComparingTo("14.5");

		// A second save changes the grade, without a second notice; a corrected work can no longer be replaced.
		long notices = body(call(get("/api/v1/me/notifications"), adam)).at("/items").size();
		grade(id, adamId, "16", null).andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/notifications"), adam)).at("/items")).hasSize((int) notices);
		assertThat(body(call(get("/api/v1/me/assignments/" + id), adam)).at("/correction/comment").isNull()).isTrue();
		submit(adam, id, null, pdf(1)).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("already_corrected"));

		// Lina's copy is not corrected yet: nothing to open; the copy can be taken back.
		call(get("/api/v1/me/assignments/" + id + "/correction/view?studentId=" + linaId), mouna).andExpect(status().isNotFound());
		JsonNode detached = body(call(delete(correction(id, adamId) + "/file"), ines).andExpect(status().isOk()));
		assertThat(detached.at("/file").isNull()).isTrue();
	}

	@Test
	void scoresAreCheckedAndMissingWorkCanBeGradedAnyway() throws Exception {
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		for (String wrong : List.of("21", "14.3", "-1")) {
			grade(id, adamId, wrong, null).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("invalid_score"));
		}
		// Lina has sent nothing and the deadline is still ahead: nothing to grade yet.
		grade(id, linaId, "10", null).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("not_submitted_yet"));
		call(multipart(HttpMethod.PUT, correction(id, adamId) + "/file")
				.file(new MockMultipartFile("file", "note.docx", "application/octet-stream", new byte[] {'P', 'K', 3, 4, 0})), ines)
				.andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("work_file_not_allowed"));

		// Past the deadline: Lina is missing ("Travail manquant"), and can be graded anyway (a paper copy).
		jdbc.update("update assignments set deadline_at = now() - interval '1 hour'");
		JsonNode missing = body(call(get("/api/v1/assignments/missing"), ines).andExpect(status().isOk()));
		assertThat(missing).hasSize(1);
		assertThat(missing.at("/0/missing")).hasSize(1);
		assertThat(missing.at("/0/missing/0/firstName").asText()).isEqualTo("Lina");
		grade(id, linaId, "0", "Rien n'a été rendu.").andExpect(status().isOk()).andExpect(jsonPath("$.status").value("CORRECTED"));
		assertThat(body(call(get("/api/v1/assignments/missing"), ines))).isEmpty();

		// Something to read only has nothing to correct; a homework out of 10 keeps its own scale.
		String reading = idOf(assign(Map.of("submissionMode", "NONE", "title", "À lire")));
		grade(reading, adamId, "10", null).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("nothing_to_submit"));
		String outOfTen = idOf(assign(Map.of("maxScore", 10, "title", "Sur 10")));
		submit(adam, outOfTen, null, pdf(1)).andExpect(status().isOk());
		grade(outOfTen, adamId, "11", null).andExpect(status().isBadRequest());
		grade(outOfTen, adamId, "7", null).andExpect(status().isOk());
	}

	@Test
	void resultsGiveTheAverageTheTrendWhatWasSentAndEachGrade() throws Exception {
		// Four grades: 5/10 (10/20), 10, 14, 16 on /20; then a homework past its deadline and never sent.
		String[][] work = {{"Série A", "10", "5"}, {"Série B", "20", "10"}, {"Série C", "20", "14"}, {"Série D", "20", "16"}};
		for (String[] w : work) {
			String id = idOf(assign(Map.of("title", w[0], "maxScore", Integer.parseInt(w[1]))));
			submit(adam, id, null, pdf(1)).andExpect(status().isOk());
			grade(id, adamId, w[2], w[0].equals("Série D") ? "Très bien !" : null).andExpect(status().isOk());
		}
		idOf(assign(Map.of("title", "Série E")));
		jdbc.update("update assignments set deadline_at = now() - interval '1 hour' where title = 'Série E'");

		JsonNode results = body(call(get("/api/v1/me/results"), adam).andExpect(status().isOk()));
		JsonNode maths = results.at("/subjects/0");
		assertThat(maths.at("/subject/name/fr").asText()).isEqualTo("Mathématiques");
		assertThat(maths.at("/average").decimalValue()).isEqualByComparingTo("12.5");
		assertThat(maths.at("/gradeCount").asInt()).isEqualTo(4);
		assertThat(maths.at("/trend").asText()).isEqualTo("UP");
		assertThat(maths.at("/submitted").asInt()).isEqualTo(4);
		assertThat(maths.at("/due").asInt()).isEqualTo(5);
		assertThat(maths.at("/attendanceRate").isNull()).isTrue();
		assertThat(maths.at("/grades/0/title").asText()).isEqualTo("Série D");
		assertThat(maths.at("/grades/0/comment").asText()).isEqualTo("Très bien !");
		assertThat(maths.at("/grades/3/score").decimalValue()).isEqualByComparingTo("5");
		assertThat(maths.at("/grades/3/maxScore").asInt()).isEqualTo(10);
		assertThat(maths.at("/grades/3/score20").decimalValue()).isEqualByComparingTo("10");

		// The mother sees the same numbers for Adam; Lina, without grades, is not given 0.
		JsonNode forAdam = body(call(get("/api/v1/me/results?studentId=" + adamId), mouna).andExpect(status().isOk()));
		assertThat(forAdam.at("/subjects/0/average").decimalValue()).isEqualByComparingTo("12.5");
		JsonNode forLina = body(call(get("/api/v1/me/results?studentId=" + linaId), mouna).andExpect(status().isOk()));
		assertThat(forLina.at("/subjects/0/average").isNull()).isTrue();
		assertThat(forLina.at("/subjects/0/gradeCount").asInt()).isZero();
		assertThat(forLina.at("/subjects/0/trend").isNull()).isTrue();
	}

	@Test
	void anotherTeacherSeesNothingAndFamiliesCannotCorrect() throws Exception {
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		account("autre");
		String other = token("autre", PASSWORD);
		call(get(correction(id, adamId)), other).andExpect(status().isNotFound());
		grade(id, adamId, "10", null, other).andExpect(status().isNotFound());
		assertThat(body(call(get("/api/v1/assignments/to-correct"), other))).isEmpty();
		assertThat(body(call(get("/api/v1/assignments/missing"), other))).isEmpty();
		call(get("/api/v1/assignments/to-correct"), adam).andExpect(status().isForbidden());
		grade(id, adamId, "20", null, mouna).andExpect(status().isForbidden());
		call(get("/api/v1/me/results"), ines).andExpect(status().isForbidden());
	}

	@Test
	void theTeacherSeesAPupilsResultsAndTheFamilyReadsHerComments() throws Exception {
		String id = idOf(assign(Map.of()));
		submit(adam, id, null, pdf(1)).andExpect(status().isOk());
		grade(id, adamId, "14", null).andExpect(status().isOk());

		// The Fiche élève: the same numbers the pupil sees; another teacher sees nothing, a pupil cannot ask.
		JsonNode results = body(call(get("/api/v1/students/" + adamId + "/results"), ines).andExpect(status().isOk()));
		assertThat(results.at("/subjects/0/average").decimalValue()).isEqualByComparingTo("14");
		assertThat(results.at("/subjects/0/grades/0/title").asText()).isEqualTo("Série 2 : les fractions");
		account("autre");
		call(get("/api/v1/students/" + adamId + "/results"), token("autre", PASSWORD)).andExpect(status().isNotFound());
		call(get("/api/v1/students/" + adamId + "/results"), adam).andExpect(status().isForbidden());

		// "Visible par l'élève et ses parents": Adam and his mother read it, latest first; Lina has none.
		for (String text : List.of("Adam participe bien.", "Il doit revoir la simplification des fractions.")) {
			call(post("/api/v1/students/" + adamId + "/comments").contentType(MediaType.APPLICATION_JSON)
					.content(json.writeValueAsString(Map.of("body", text))), ines).andExpect(status().isCreated());
		}
		JsonNode mine = body(call(get("/api/v1/me/comments"), adam).andExpect(status().isOk()));
		assertThat(mine).hasSize(2);
		assertThat(mine.at("/0/body").asText()).isEqualTo("Il doit revoir la simplification des fractions.");
		assertThat(body(call(get("/api/v1/me/comments?studentId=" + adamId), mouna)).at("/1/body").asText()).isEqualTo("Adam participe bien.");
		assertThat(body(call(get("/api/v1/me/comments?studentId=" + linaId), mouna))).isEmpty();
		call(get("/api/v1/me/comments"), ines).andExpect(status().isForbidden());
	}

	private static String correction(String assignmentId, String studentId) {
		return "/api/v1/assignments/" + assignmentId + "/corrections/" + studentId;
	}

	private ResultActions grade(String assignmentId, String studentId, String score, String comment) throws Exception {
		return grade(assignmentId, studentId, score, comment, ines);
	}

	private ResultActions grade(String assignmentId, String studentId, String score, String comment, String token) throws Exception {
		Map<String, Object> body = new HashMap<>();
		body.put("score", new java.math.BigDecimal(score));
		body.put("comment", comment);
		return call(put(correction(assignmentId, studentId)).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), token);
	}

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
