package com.ngclass.backend.search;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.school.repository.LevelRepository;
import java.io.ByteArrayOutputStream;
import java.time.Instant;
import java.time.LocalDate;
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

/** Release 2: the search of the teacher's top bar finds what is hers, accents and capitals ignored. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class SearchTest {
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
	private String group;

	@BeforeEach
	void cleanAndSetUp() throws Exception {
		jdbc.execute("""
				truncate submissions, assignment_recipients, assignments, content_views, content_shares, content_items, file_assets,
				chapters, notifications, attendance, sessions, recurrence_rules, comments, private_notes, group_members, class_groups,
				parent_students, parents, students, subjects, refresh_tokens, users cascade""");
		account("enseignante");
		ines = token("enseignante");
		levelId = levels.findAllByOrderByPositionAsc().get(3).getId().toString();
		maths = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON).content("{\"nameFr\":\"Mathématiques\"}"), ines)).at("/id").asText();
		group = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "4ème année · Maths", "subjectId", maths, "levelId", levelId))), ines)).at("/id").asText();
	}

	@Test
	void namesPhonesAndTitlesAreFoundWithoutAccentsOrCapitals() throws Exception {
		String elyes = pupil("Élyes", "Ben Ali", List.of(Map.of("firstName", "Sonia", "lastName", "Ben Ali", "phone", "22345671")));
		String sonia = body(call(get("/api/v1/parents"), ines)).at("/0/id").asText();
		pupil("Malek", "Ben Ali", List.of(Map.of("existingParentId", sonia)));
		pupil("Sara", "Ben Amor", List.of());
		String gone = pupil("Benoît", "Archivé", List.of());
		call(post("/api/v1/students/" + gone + "/archive"), ines).andExpect(status().isNoContent());

		JsonNode ben = search("BEN");
		assertThat(names(ben.at("/students"))).containsExactly("Élyes Ben Ali", "Malek Ben Ali", "Sara Ben Amor");
		assertThat(ben.at("/students/0/id").asText()).isEqualTo(elyes);
		assertThat(ben.at("/students/0/groups/0").asText()).isEqualTo("4ème année · Maths");
		assertThat(ben.at("/students/0/level/fr").asText()).isEqualTo("4ème année");
		assertThat(ben.at("/parents/0/firstName").asText()).isEqualTo("Sonia");
		assertThat(ben.at("/parents/0/children")).hasSize(2);
		assertThat(names(search("elyes").at("/students"))).containsExactly("Élyes Ben Ali");
		assertThat(search("2234567").at("/parents/0/phone").asText()).isEqualTo("22345671");
		assertThat(search("4eme").at("/groups/0/name").asText()).isEqualTo("4ème année · Maths");

		// Contents, homework and evaluations by title; a chapter with its documents.
		String chapter = body(call(post("/api/v1/chapters").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("subjectId", maths, "levelId", levelId, "title", "Les fractions"))), ines).andExpect(status().isCreated())).at("/id").asText();
		String document = body(call(multipart("/api/v1/contents")
				.file(new MockMultipartFile("file", "serie1.pdf", "application/pdf", pdf()))
				.file(new MockMultipartFile("meta", "", MediaType.APPLICATION_JSON_VALUE, json.writeValueAsBytes(Map.of(
						"title", "Série 1 : les fractions", "subjectId", maths, "levelId", levelId, "chapterId", chapter, "tag", "SERIE",
						"draft", false, "groupIds", List.of())))), ines).andExpect(status().isCreated())).at("/id").asText();
		call(post("/api/v1/assignments").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(Map.of(
				"contentItemId", document, "title", "Série 1 : les fractions", "groupId", group,
				"deadlineAt", Instant.now().plus(2, ChronoUnit.DAYS).toString(), "submissionMode", "FILE", "allowLate", false))), ines)
				.andExpect(status().isCreated());
		call(post("/api/v1/evaluations").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(Map.of(
				"groupId", group, "title", "Évaluation : les fractions", "heldOn", LocalDate.now().toString(), "maxScore", 20))), ines)
				.andExpect(status().isCreated());
		JsonNode frac = search("frac");
		assertThat(frac.at("/documents/0/title").asText()).isEqualTo("Série 1 : les fractions");
		assertThat(frac.at("/documents/0/chapter").asText()).isEqualTo("Les fractions");
		assertThat(frac.at("/documents/0/subject/fr").asText()).isEqualTo("Mathématiques");
		assertThat(frac.at("/chapters/0/documents").asInt()).isEqualTo(1);
		assertThat(frac.at("/homework/0/group/name").asText()).isEqualTo("4ème année · Maths");
		assertThat(frac.at("/evaluations/0/title").asText()).isEqualTo("Évaluation : les fractions");
		assertThat(frac.at("/students")).isEmpty();
	}

	@Test
	void fiveAtMostWordsStartingFirstAndOnlyTheTeachersOwn() throws Exception {
		for (String first : List.of("Amine", "Amira", "Amel", "Amina", "Amir", "Samia")) {
			pupil(first, "Kefi", List.of());
		}
		JsonNode am = search("am");
		assertThat(am.at("/students")).hasSize(5);
		// "Samia" only contains the letters: never before a name that starts with them.
		assertThat(names(am.at("/students"))).doesNotContain("Samia Kefi");
		assertThat(search("a").at("/students")).isEmpty();

		account("autre.enseignante");
		assertThat(body(call(get("/api/v1/search?q=kefi"), token("autre.enseignante")).andExpect(status().isOk())).at("/students")).isEmpty();
		String child = body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(Map.of(
				"firstName", "Lina", "lastName", "Bouzid", "levelId", levelId, "createLogin", true))), ines)).at("/credentials/0").toString();
		JsonNode credential = json.readTree(child);
		String lina = token(credential.at("/username").asText(), credential.at("/temporaryPassword").asText());
		call(get("/api/v1/search?q=kefi"), lina).andExpect(status().isForbidden());
	}

	// ── Helpers ──

	private JsonNode search(String q) throws Exception {
		return body(call(get("/api/v1/search").param("q", q), ines).andExpect(status().isOk()));
	}

	private static List<String> names(JsonNode hits) {
		List<String> out = new ArrayList<>();
		hits.forEach(h -> out.add(h.at("/firstName").asText() + " " + h.at("/lastName").asText()));
		return out;
	}

	private String pupil(String first, String last, List<Map<String, Object>> parents) throws Exception {
		Map<String, Object> body = new HashMap<>(Map.of("firstName", first, "lastName", last, "levelId", levelId,
				"groupIds", List.of(group), "createLogin", false));
		body.put("parents", parents);
		return body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body)), ines)
				.andExpect(status().isCreated())).at("/student/id").asText();
	}

	private static byte[] pdf() throws Exception {
		try (PDDocument pdf = new PDDocument(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
			pdf.addPage(new PDPage(PDRectangle.A4));
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

	private String token(String login) throws Exception {
		return token(login, PASSWORD);
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
