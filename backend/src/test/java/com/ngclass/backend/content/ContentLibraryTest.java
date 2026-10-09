package com.ngclass.backend.content;

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
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.imageio.ImageIO;
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

/** Release 2, step 1 (spec 04 and 09): the teacher's library, sharing, and Cours for pupils and parents. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class ContentLibraryTest {
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
	private String otherGroup;
	private String pupil;
	private String parent;
	private String adamId;

	@BeforeEach
	void cleanAndSetUp() throws Exception {
		jdbc.execute("""
				truncate content_views, content_shares, content_items, file_assets, chapters, notifications, attendance, sessions,
				recurrence_rules, comments, private_notes, group_members, class_groups, parent_students, parents, students,
				subjects, refresh_tokens, users cascade""");
		account(Role.TEACHER, "enseignante");
		ines = token("enseignante", PASSWORD);
		levelId = levels.findAllByOrderByPositionAsc().get(3).getId().toString();
		maths = createSubject(ines, "Mathématiques");
		group4A = createGroup(ines, "4ème année · Maths", maths);
		otherGroup = createGroup(ines, "4ème année · Soutien", maths);

		// Adam has his own login; Mouna follows him. Both choose their password at first login.
		Map<String, Object> adam = new HashMap<>(Map.of("firstName", "Adam", "lastName", "Gharbi", "levelId", levelId,
				"groupIds", List.of(group4A), "createLogin", true));
		adam.put("parents", List.of(Map.of("firstName", "Mouna", "lastName", "Gharbi", "phone", "20000001", "relation", "mother")));
		JsonNode created = body(call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(adam)), ines)
				.andExpect(status().isCreated()));
		adamId = created.at("/student/id").asText();
		pupil = firstLogin(credential(created, "STUDENT"));
		parent = firstLogin(credential(created, "PARENT"));
	}

	@Test
	void aSeriesUploadedAndSharedOpensForThePupilAndTheParent() throws Exception {
		String chapter = createChapter(ines, maths, "Les fractions");
		JsonNode item = body(upload(ines, pdf(3), "serie2_fractions.pdf", meta("Série 2 : les fractions", chapter, "SERIE", false, List.of(group4A)))
				.andExpect(status().isCreated()));
		assertThat(item.at("/kind").asText()).isEqualTo("PDF");
		assertThat(item.at("/pageCount").asInt()).isEqualTo(3);
		assertThat(item.at("/status").asText()).isEqualTo("PUBLISHED");
		assertThat(item.at("/fileName").asText()).isEqualTo("serie2_fractions.pdf");
		assertThat(item.at("/sharedGroupIds/0").asText()).isEqualTo(group4A);
		String id = item.at("/id").asText();

		JsonNode library = body(call(get("/api/v1/contents"), ines).andExpect(status().isOk()));
		assertThat(library.at("/chapters/0/title").asText()).isEqualTo("Les fractions");
		assertThat(library.at("/items/0/id").asText()).isEqualTo(id);

		// Adam sees it as new, under its subject and chapter.
		JsonNode cours = body(call(get("/api/v1/me/contents"), pupil).andExpect(status().isOk()));
		assertThat(cours).hasSize(1);
		assertThat(cours.at("/0/subject/name/fr").asText()).isEqualTo("Mathématiques");
		assertThat(cours.at("/0/chapter/title").asText()).isEqualTo("Les fractions");
		assertThat(cours.at("/0/tag").asText()).isEqualTo("SERIE");
		assertThat(cours.at("/0/isNew").asBoolean()).isTrue();
		assertThat(cours.at("/0/sharedAt").isNull()).isFalse();

		// The viewer: three page images and the file, behind signed links that need no token.
		JsonNode view = body(call(get("/api/v1/contents/" + id + "/view"), pupil).andExpect(status().isOk()));
		assertThat(view.at("/pageUrls")).hasSize(3);
		assertThat(view.at("/subjectName/fr").asText()).isEqualTo("Mathématiques");
		assertThat(view.at("/chapterTitle").asText()).isEqualTo("Les fractions");
		mvc.perform(get("/api/v1/" + view.at("/pageUrls/1").asText()))
				.andExpect(status().isOk())
				.andExpect(header().string(HttpHeaders.CONTENT_TYPE, "image/jpeg"));
		mvc.perform(get("/api/v1/" + view.at("/downloadUrl").asText()))
				.andExpect(status().isOk())
				.andExpect(header().string(HttpHeaders.CONTENT_TYPE, "application/pdf"))
				.andExpect(header().string(HttpHeaders.CONTENT_DISPOSITION, org.hamcrest.Matchers.containsString("attachment")));
		// A forged link opens nothing.
		String link = view.at("/downloadUrl").asText();
		String forged = link.substring(0, link.length() - 2) + (link.endsWith("AA") ? "BB" : "AA");
		mvc.perform(get("/api/v1/" + forged)).andExpect(status().isNotFound());

		// Opened: no longer new for Adam, still new for his mother.
		assertThat(body(call(get("/api/v1/me/contents"), pupil)).at("/0/isNew").asBoolean()).isFalse();
		JsonNode parentCours = body(call(get("/api/v1/me/contents?studentId=" + adamId), parent).andExpect(status().isOk()));
		assertThat(parentCours.at("/0/title").asText()).isEqualTo("Série 2 : les fractions");
		assertThat(parentCours.at("/0/isNew").asBoolean()).isTrue();
		call(get("/api/v1/contents/" + id + "/view"), parent).andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/contents?studentId=" + adamId), parent)).at("/0/isNew").asBoolean()).isFalse();

		// Not shared with Adam's group any more: gone from his Cours, and the viewer refuses it.
		call(put("/api/v1/contents/" + id + "/shares").contentType(MediaType.APPLICATION_JSON).content("{\"groupIds\":[]}"), ines)
				.andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).isEmpty();
		call(get("/api/v1/contents/" + id + "/view"), pupil).andExpect(status().isNotFound());
	}

	@Test
	void aDraftIsNeverSeenAndCannotBeShared() throws Exception {
		call(multipartUpload(pdf(1), "corrige.pdf", meta("Corrigé de la série 2", null, "CORRIGE", true, List.of(group4A))), ines)
				.andExpect(status().isConflict())
				.andExpect(jsonPath("$.code").value("content_not_published"));
		String id = body(upload(ines, pdf(1), "corrige.pdf", meta("Corrigé de la série 2", null, "CORRIGE", true, List.of()))
				.andExpect(status().isCreated())).at("/id").asText();
		call(put("/api/v1/contents/" + id + "/shares").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("groupIds", List.of(group4A)))), ines)
				.andExpect(status().isConflict());

		// Published, shared, then back to draft: out of every Cours again.
		call(put("/api/v1/contents/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				update("Corrigé de la série 2", null, "CORRIGE", false))), ines)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.status").value("PUBLISHED"));
		call(put("/api/v1/contents/" + id + "/shares").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("groupIds", List.of(group4A)))), ines)
				.andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).hasSize(1);
		call(put("/api/v1/contents/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				update("Corrigé de la série 2", null, "CORRIGE", true))), ines)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.status").value("DRAFT"))
				.andExpect(jsonPath("$.sharedGroupIds").isEmpty());
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).isEmpty();
	}

	@Test
	void aSharedChapterAlsoShowsTheDocumentsAddedLater() throws Exception {
		String chapter = createChapter(ines, maths, "La multiplication");
		call(put("/api/v1/chapters/" + chapter + "/shares").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("groupIds", List.of(group4A)))), ines)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.sharedGroupIds[0]").value(group4A));
		upload(ines, jpeg(), "tableau.jpg", meta("Photo du tableau", chapter, "AUTRE", false, List.of())).andExpect(status().isCreated());
		upload(ines, pdf(1), "brouillon.pdf", meta("Pas encore prêt", chapter, "SERIE", true, List.of())).andExpect(status().isCreated());

		JsonNode cours = body(call(get("/api/v1/me/contents"), pupil));
		assertThat(cours).hasSize(1);
		assertThat(cours.at("/0/kind").asText()).isEqualTo("IMAGE");
		JsonNode view = body(call(get("/api/v1/contents/" + cours.at("/0/id").asText() + "/view"), pupil));
		assertThat(view.at("/pageUrls")).hasSize(1);
		mvc.perform(get("/api/v1/" + view.at("/pageUrls/0").asText()))
				.andExpect(status().isOk())
				.andExpect(header().string(HttpHeaders.CONTENT_TYPE, "image/jpeg"));

		// A deleted chapter leaves its documents in "Sans chapitre", no longer shared through it.
		call(delete("/api/v1/chapters/" + chapter), ines).andExpect(status().isNoContent());
		JsonNode library = body(call(get("/api/v1/contents"), ines));
		assertThat(library.at("/chapters")).isEmpty();
		assertThat(library.at("/items/0/chapterId").isNull()).isTrue();
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).isEmpty();
	}

	@Test
	void uploadsAreCheckedBeforeTheyAreKept() throws Exception {
		upload(ines, "bonjour".getBytes(), "notes.txt", meta("Notes", null, "AUTRE", false, List.of()))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("file_type_not_allowed"));
		upload(ines, new byte[0], "vide.pdf", meta("Vide", null, "AUTRE", false, List.of()))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("file_required"));
		upload(ines, "%PDF-1.4 abîmé".getBytes(), "abime.pdf", meta("Abîmé", null, "AUTRE", false, List.of()))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("file_unreadable"));
		byte[] big = new byte[20 * 1024 * 1024 + 1];
		big[0] = '%';
		upload(ines, big, "gros.pdf", meta("Gros", null, "AUTRE", false, List.of()))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("file_too_large"));
		upload(ines, pdf(1), "x.pdf", meta("Mauvaise étiquette", null, "LIVRE", false, List.of()))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("invalid_tag"));

		// A Word file is kept, and only downloads.
		byte[] docx = new byte[64];
		docx[0] = 'P';
		docx[1] = 'K';
		docx[2] = 3;
		docx[3] = 4;
		JsonNode word = body(upload(ines, docx, "fiche.docx", meta("Fiche de révision", null, "AUTRE", false, List.of(group4A)))
				.andExpect(status().isCreated()));
		assertThat(word.at("/kind").asText()).isEqualTo("WORD");
		JsonNode view = body(call(get("/api/v1/contents/" + word.at("/id").asText() + "/view"), pupil).andExpect(status().isOk()));
		assertThat(view.at("/pageUrls")).isEmpty();
		assertThat(view.at("/downloadUrl").asText()).startsWith("files/");

		// A chapter of another level does not fit.
		String other = levels.findAllByOrderByPositionAsc().get(4).getId().toString();
		String chapter5 = body(call(post("/api/v1/chapters").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("subjectId", maths, "levelId", other, "title", "Les fractions"))), ines).andExpect(status().isCreated())).at("/id").asText();
		upload(ines, pdf(1), "x.pdf", meta("Mal rangé", chapter5, "SERIE", false, List.of()))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("chapter_mismatch"));
		// Same chapter name, same subject and level: refused.
		call(post("/api/v1/chapters").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("subjectId", maths, "levelId", other, "title", "les FRACTIONS"))), ines)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("chapter_exists"));
		// A subject with documents stays.
		call(delete("/api/v1/subjects/" + maths), ines)
				.andExpect(status().isConflict());
	}

	@Test
	void anotherTeacherAndAnotherFamilySeeNothing() throws Exception {
		String chapter = createChapter(ines, maths, "Les fractions");
		String id = body(upload(ines, pdf(1), "serie.pdf", meta("Série 2", chapter, "SERIE", false, List.of(otherGroup)))
				.andExpect(status().isCreated())).at("/id").asText();

		// Shared with another group only: not Adam's.
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).isEmpty();
		call(get("/api/v1/contents/" + id + "/view"), pupil).andExpect(status().isNotFound());
		call(get("/api/v1/contents"), pupil).andExpect(status().isForbidden());

		// Sonia, another teacher, reaches nothing of Ines's.
		account(Role.TEACHER, "sonia");
		String sonia = token("sonia", PASSWORD);
		JsonNode library = body(call(get("/api/v1/contents"), sonia).andExpect(status().isOk()));
		assertThat(library.at("/items")).isEmpty();
		assertThat(library.at("/chapters")).isEmpty();
		call(get("/api/v1/contents/" + id + "/view"), sonia).andExpect(status().isNotFound());
		call(put("/api/v1/contents/" + id + "/shares").contentType(MediaType.APPLICATION_JSON).content("{\"groupIds\":[]}"), sonia)
				.andExpect(status().isNotFound());
		call(post("/api/v1/contents/" + id + "/archive"), sonia).andExpect(status().isNotFound());
		call(put("/api/v1/chapters/" + chapter).contentType(MediaType.APPLICATION_JSON).content("{\"title\":\"Pris\"}"), sonia)
				.andExpect(status().isNotFound());
		// Her own subject cannot take Ines's group or chapter.
		String hers = createSubject(sonia, "Lecture");
		upload(sonia, pdf(1), "x.pdf", meta(hers, "Avec le chapitre d'Ines", chapter, "SERIE", false, List.of()))
				.andExpect(status().isNotFound());
		upload(sonia, pdf(1), "x.pdf", meta(hers, "Avec le groupe d'Ines", null, "SERIE", false, List.of(group4A)))
				.andExpect(status().isNotFound());

		// Archived: out of the library and of every Cours, nothing deleted.
		call(put("/api/v1/contents/" + id + "/shares").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("groupIds", List.of(group4A)))), ines).andExpect(status().isOk());
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).hasSize(1);
		call(post("/api/v1/contents/" + id + "/archive"), ines).andExpect(status().isNoContent());
		assertThat(body(call(get("/api/v1/contents"), ines)).at("/items")).isEmpty();
		assertThat(body(call(get("/api/v1/me/contents"), pupil))).isEmpty();
	}

	// ── Helpers ──

	private Map<String, Object> meta(String title, String chapterId, String tag, boolean draft, List<String> groupIds) {
		return meta(maths, title, chapterId, tag, draft, groupIds);
	}

	private Map<String, Object> meta(String subjectId, String title, String chapterId, String tag, boolean draft, List<String> groupIds) {
		Map<String, Object> meta = new HashMap<>();
		meta.put("title", title);
		meta.put("subjectId", subjectId);
		meta.put("levelId", levelId);
		meta.put("chapterId", chapterId);
		meta.put("tag", tag);
		meta.put("draft", draft);
		meta.put("groupIds", groupIds);
		return meta;
	}

	private Map<String, Object> update(String title, String chapterId, String tag, boolean draft) {
		Map<String, Object> body = meta(title, chapterId, tag, draft, List.of());
		body.remove("groupIds");
		return body;
	}

	private MockHttpServletRequestBuilder multipartUpload(byte[] data, String name, Map<String, Object> meta) throws Exception {
		return multipart("/api/v1/contents")
				.file(new MockMultipartFile("file", name, "application/octet-stream", data))
				.file(new MockMultipartFile("meta", "", MediaType.APPLICATION_JSON_VALUE, json.writeValueAsBytes(meta)));
	}

	private ResultActions upload(String token, byte[] data, String name, Map<String, Object> meta) throws Exception {
		return call(multipartUpload(data, name, meta), token);
	}

	private String createChapter(String token, String subjectId, String title) throws Exception {
		return body(call(post("/api/v1/chapters").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("subjectId", subjectId, "levelId", levelId, "title", title))), token)
				.andExpect(status().isCreated())).at("/id").asText();
	}

	private String createSubject(String token, String nameFr) throws Exception {
		return body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("nameFr", nameFr))), token)
				.andExpect(status().isCreated())).at("/id").asText();
	}

	private String createGroup(String token, String name, String subjectId) throws Exception {
		return body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", name, "subjectId", subjectId, "levelId", levelId))), token)
				.andExpect(status().isCreated())).at("/id").asText();
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

	private static byte[] jpeg() throws Exception {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		ImageIO.write(new BufferedImage(40, 30, BufferedImage.TYPE_INT_RGB), "jpg", out);
		return out.toByteArray();
	}

	private void account(Role role, String username) {
		users.save(User.builder()
				.role(role)
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

	/** Signs in with the temporary password and chooses a real one, as the app does. */
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
