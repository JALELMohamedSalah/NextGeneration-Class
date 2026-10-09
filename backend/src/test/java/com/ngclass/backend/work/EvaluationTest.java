package com.ngclass.backend.work;

import static org.assertj.core.api.Assertions.assertThat;
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
import java.util.ArrayList;
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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/** Release 2, step 5 (spec 06 "Évaluations", spec 07): paper tests typed for a group, counted in Résultats. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class EvaluationTest {
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
	private String adamId;
	private String linaId;
	private String rayenId;
	private String adam;
	private String mouna;

	@BeforeEach
	void cleanAndSetUp() throws Exception {
		jdbc.execute("""
				truncate evaluation_grades, evaluations, submissions, assignment_recipients, assignments, content_views, content_shares,
				content_items, file_assets, chapters, notifications, attendance, sessions, recurrence_rules, comments, private_notes,
				group_members, class_groups, parent_students, parents, students, subjects, refresh_tokens, users cascade""");
		account("enseignante");
		ines = token("enseignante", PASSWORD);
		levelId = levels.findAllByOrderByPositionAsc().get(3).getId().toString();
		maths = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON).content("{\"nameFr\":\"Mathématiques\"}"), ines)
				.andExpect(status().isCreated())).at("/id").asText();
		group4A = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "4ème année · Maths", "subjectId", maths, "levelId", levelId))), ines)
				.andExpect(status().isCreated())).at("/id").asText();

		// Adam has his own login; Lina and Rayen have none. Mouna is the mother of Adam and Lina.
		JsonNode created = createStudent("Adam", true, List.of(Map.of("firstName", "Mouna", "lastName", "Gharbi", "phone", "20000001")));
		adamId = created.at("/student/id").asText();
		adam = firstLogin(credential(created, "STUDENT"));
		mouna = firstLogin(credential(created, "PARENT"));
		String mounaParentId = body(call(get("/api/v1/parents"), ines)).at("/0/id").asText();
		linaId = createStudent("Lina", false, List.of(Map.of("existingParentId", mounaParentId))).at("/student/id").asText();
		rayenId = createStudent("Rayen", false, List.of()).at("/student/id").asText();
	}

	@Test
	void theTeacherTypesTheGroupsScoresAndTheFamilySeesThemInResults() throws Exception {
		JsonNode created = body(create("Évaluation : la multiplication", 20).andExpect(status().isCreated()));
		String id = created.at("/evaluation/id").asText();
		assertThat(created.at("/evaluation/maxScore").asInt()).isEqualTo(20);
		assertThat(created.at("/evaluation/pupils").asInt()).isEqualTo(3);
		assertThat(created.at("/evaluation/graded").asInt()).isZero();
		assertThat(created.at("/evaluation/average").isNull()).isTrue();
		// The table: every pupil of the group, nothing typed, by first name.
		assertThat(created.at("/grades").findValuesAsText("firstName")).containsExactly("Adam", "Lina", "Rayen");

		// Adam 15, Lina 11.5 with a comment, Rayen absent.
		JsonNode saved = body(save(id, List.of(
				grade(adamId, "15", false, null),
				grade(linaId, "11.5", false, "Revois la table de 7."),
				grade(rayenId, null, true, "Malade."))).andExpect(status().isOk()));
		assertThat(saved.at("/evaluation/graded").asInt()).isEqualTo(2);
		assertThat(saved.at("/evaluation/absent").asInt()).isEqualTo(1);
		assertThat(saved.at("/evaluation/average").decimalValue()).isEqualByComparingTo("13.25");
		assertThat(saved.at("/grades/1/comment").asText()).isEqualTo("Revois la table de 7.");
		assertThat(saved.at("/grades/2/absent").asBoolean()).isTrue();
		assertThat(saved.at("/grades/2/score").isNull()).isTrue();

		// The list of the tab.
		JsonNode list = body(call(get("/api/v1/evaluations"), ines).andExpect(status().isOk()));
		assertThat(list).hasSize(1);
		assertThat(list.at("/0/group/name").asText()).isEqualTo("4ème année · Maths");
		assertThat(list.at("/0/graded").asInt()).isEqualTo(2);

		// Adam and his mother are told; the mother once per child graded (Adam and Lina).
		JsonNode adamNews = body(call(get("/api/v1/me/notifications"), adam));
		assertThat(adamNews.at("/items/0/type").asText()).isEqualTo("EVALUATION_GRADED");
		assertThat(adamNews.at("/items/0/title").asText()).isEqualTo("Évaluation : la multiplication");
		assertThat(adamNews.at("/items/0/evaluationId").asText()).isEqualTo(id);
		assertThat(body(call(get("/api/v1/me/notifications"), mouna)).at("/items").findValuesAsText("type"))
				.containsOnly("EVALUATION_GRADED").hasSize(2);

		// Résultats: the grade says it is an evaluation and counts on /20.
		JsonNode results = body(call(get("/api/v1/me/results"), adam).andExpect(status().isOk()));
		assertThat(results.at("/subjects/0/average").decimalValue()).isEqualByComparingTo("15");
		assertThat(results.at("/subjects/0/grades/0/kind").asText()).isEqualTo("EVALUATION");
		assertThat(results.at("/subjects/0/grades/0/evaluationId").asText()).isEqualTo(id);

		// Saving again does not tell the family twice.
		save(id, List.of(grade(adamId, "16", false, null))).andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/notifications"), adam)).at("/items")).hasSize(1);
		assertThat(body(call(get("/api/v1/me/results"), adam)).at("/subjects/0/average").decimalValue()).isEqualByComparingTo("16");
	}

	@Test
	void anAbsentPupilIsNeverCountedAsZeroAndAScoreOnTenCountsOnTwenty() throws Exception {
		String onTen = body(create("Dictée", 10)).at("/evaluation/id").asText();
		String onTwenty = body(create("Calcul mental", 20)).at("/evaluation/id").asText();
		save(onTen, List.of(grade(adamId, "7", false, null))).andExpect(status().isOk());
		save(onTwenty, List.of(grade(adamId, null, true, null))).andExpect(status().isOk());

		JsonNode maths = body(call(get("/api/v1/me/results"), adam)).at("/subjects/0");
		// 7/10 is 14/20; the absence is listed, not counted.
		assertThat(maths.at("/average").decimalValue()).isEqualByComparingTo("14");
		assertThat(maths.at("/gradeCount").asInt()).isEqualTo(1);
		List<Boolean> absent = new ArrayList<>();
		maths.at("/grades").forEach(g -> absent.add(g.at("/absent").asBoolean()));
		assertThat(absent).containsExactlyInAnyOrder(true, false);
		assertThat(maths.at("/grades").findValuesAsText("kind")).containsOnly("EVALUATION");
	}

	@Test
	void wrongScoresAreRefusedAndATypedScoreCanBeErased() throws Exception {
		String id = body(create("Évaluation", 20)).at("/evaluation/id").asText();
		save(id, List.of(grade(adamId, "21", false, null)))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("invalid_score"));
		save(id, List.of(grade(adamId, "12.3", false, null)))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("invalid_score"));

		save(id, List.of(grade(adamId, "18", false, null))).andExpect(status().isOk());
		// A smaller scale than a typed score is refused.
		call(put("/api/v1/evaluations/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("title", "Évaluation", "heldOn", "2026-10-07", "maxScore", 10))), ines)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("scale_below_scores"));
		// "Modifier" changes the title and the date.
		JsonNode edited = body(call(put("/api/v1/evaluations/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("title", "Évaluation n° 2", "heldOn", "2026-10-06", "maxScore", 20))), ines).andExpect(status().isOk()));
		assertThat(edited.at("/evaluation/title").asText()).isEqualTo("Évaluation n° 2");
		assertThat(edited.at("/evaluation/heldOn").asText()).isEqualTo("2026-10-06");

		// Erased: nothing left for Adam, nothing in his results.
		JsonNode erased = body(save(id, List.of(grade(adamId, null, false, null))).andExpect(status().isOk()));
		assertThat(erased.at("/evaluation/graded").asInt()).isZero();
		assertThat(body(call(get("/api/v1/me/results"), adam)).at("/subjects/0/grades")).isEmpty();

		// Only the group's pupils.
		String other = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "5ème année · Maths", "subjectId", maths, "levelId", levelId))), ines)).at("/id").asText();
		String outsider = createStudentIn(other, "Omar");
		save(id, List.of(grade(outsider, "10", false, null))).andExpect(status().isNotFound());
	}

	@Test
	void anotherTeacherNeverReachesTheEvaluation() throws Exception {
		String id = body(create("Évaluation", 20)).at("/evaluation/id").asText();
		account("sonia");
		String sonia = token("sonia", PASSWORD);
		call(get("/api/v1/evaluations/" + id), sonia).andExpect(status().isNotFound());
		save(id, List.of(grade(adamId, "10", false, null)), sonia).andExpect(status().isNotFound());
		assertThat(body(call(get("/api/v1/evaluations"), sonia))).isEmpty();
		// Her evaluation needs one of her groups.
		call(post("/api/v1/evaluations").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("groupId", group4A, "title", "X", "heldOn", "2026-10-07", "maxScore", 20))), sonia)
				.andExpect(status().isNotFound());
		// Pupils and parents have no access to the teacher's table.
		call(get("/api/v1/evaluations"), adam).andExpect(status().isForbidden());
	}

	// ── Helpers ──

	private ResultActions create(String title, int maxScore) throws Exception {
		return call(post("/api/v1/evaluations").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("groupId", group4A, "title", title, "heldOn", "2026-10-07", "maxScore", maxScore))), ines);
	}

	private static Map<String, Object> grade(String studentId, String score, boolean absent, String comment) {
		Map<String, Object> g = new HashMap<>();
		g.put("studentId", studentId);
		g.put("score", score == null ? null : new java.math.BigDecimal(score));
		g.put("absent", absent);
		g.put("comment", comment);
		return g;
	}

	private ResultActions save(String id, List<Map<String, Object>> grades) throws Exception {
		return save(id, grades, ines);
	}

	private ResultActions save(String id, List<Map<String, Object>> grades, String token) throws Exception {
		return call(put("/api/v1/evaluations/" + id + "/grades").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("grades", grades))), token);
	}

	private JsonNode createStudent(String firstName, boolean login, List<Map<String, Object>> parents) throws Exception {
		Map<String, Object> body = new HashMap<>(Map.of("firstName", firstName, "lastName", "Gharbi", "levelId", levelId,
				"groupIds", List.of(group4A), "createLogin", login));
		body.put("parents", parents);
		return body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), ines)
				.andExpect(status().isCreated()));
	}

	private String createStudentIn(String groupId, String firstName) throws Exception {
		Map<String, Object> body = new HashMap<>(Map.of("firstName", firstName, "lastName", "Saidi", "levelId", levelId,
				"groupIds", List.of(groupId), "createLogin", false));
		body.put("parents", List.of());
		return body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), ines)
				.andExpect(status().isCreated())).at("/student/id").asText();
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
