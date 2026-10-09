package com.ngclass.backend.people;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.school.repository.LevelRepository;
import java.io.ByteArrayOutputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
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

/** Release 2 (spec 02 "CSV import"): a class from Excel or CSV, every line checked, then all created at once. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class StudentImportTest {
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
	private String fourth;
	private String group4A;

	@BeforeEach
	void cleanAndSetUp() throws Exception {
		jdbc.execute("""
				truncate notifications, attendance, sessions, recurrence_rules, comments, private_notes, group_members, class_groups,
				parent_students, parents, students, subjects, refresh_tokens, users cascade""");
		account("enseignante");
		ines = token("enseignante");
		fourth = levels.findAllByOrderByPositionAsc().get(3).getId().toString();
		String maths = body(call(post("/api/v1/subjects").contentType(MediaType.APPLICATION_JSON).content("{\"nameFr\":\"Mathématiques\"}"), ines)
				.andExpect(status().isCreated())).at("/id").asText();
		group4A = body(call(post("/api/v1/groups").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(
				Map.of("name", "4ème année · Maths", "subjectId", maths, "levelId", fourth))), ines)
				.andExpect(status().isCreated())).at("/id").asText();
		// Amine is already a pupil; his mother Sonia Kefi has an account.
		Map<String, Object> amine = new HashMap<>(Map.of("firstName", "Amine", "lastName", "Kefi", "levelId", fourth, "createLogin", false));
		amine.put("parents", List.of(Map.of("firstName", "Sonia", "lastName", "Kefi", "phone", "22111222")));
		call(post("/api/v1/students").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(amine)), ines)
				.andExpect(status().isCreated());
	}

	@Test
	void aCsvIsReadLineByLineThenTheLinesKeptAreCreatedTogether() throws Exception {
		String csv = """
				﻿Prénom;Nom;Niveau;Groupe;Prénom du parent;Nom du parent;Téléphone du parent
				Yassine;Ben Ali;4ème année;;Sonia;Ben Ali;22 345 678
				Eya;Trabelsi;;4ème année · Maths;Nabil;Trabelsi;98123456
				Rania;Kefi;4;;Sonia;Kefi;22111222
				Amine;Kefi;4ème année;;;;
				Mohamed Aziz;Gharsalli;4ème année;;Hela;Gharsalli;2234567
				Firas;Jebali;7ème;;Karim;Jebali;55678901
				Ines;Mabrouk;السنة الرابعة;;;;
				Yassine;Ben Ali;;;;;
				Malek;Ben Ali;4;;;;+216 22 345 678
				""";
		JsonNode preview = body(preview(csv.getBytes(StandardCharsets.UTF_8), "classe.csv", group4A, fourth).andExpect(status().isOk()));
		assertThat(preview.at("/lines").asInt()).isEqualTo(9);
		JsonNode rows = preview.at("/rows");
		assertThat(state(rows, 2)).isEqualTo("READY");
		assertThat(rows.at("/0/parentPhone").asText()).isEqualTo("22345678");
		assertThat(rows.at("/0/groupIds/0").asText()).isEqualTo(group4A);
		assertThat(rows.at("/0/levelId").asText()).isEqualTo(fourth);
		// No level on the line: the one chosen for everyone. The group column names the same group once.
		assertThat(state(rows, 3)).isEqualTo("READY");
		assertThat(rows.at("/1/levelId").asText()).isEqualTo(fourth);
		assertThat(rows.at("/1/groupIds")).hasSize(1);
		assertThat(state(rows, 4)).isEqualTo("PARENT_KNOWN");
		assertThat(rows.at("/2/knownParent").asText()).isEqualTo("Sonia Kefi");
		assertThat(state(rows, 5)).isEqualTo("EXISTS");
		assertThat(state(rows, 6)).isEqualTo("ERROR");
		assertThat(rows.at("/4/problems/0").asText()).isEqualTo("parent_phone_invalid");
		assertThat(rows.at("/5/problems/0").asText()).isEqualTo("level_unknown");
		assertThat(rows.at("/5/levelText").asText()).isEqualTo("7ème");
		assertThat(state(rows, 8)).isEqualTo("READY");
		assertThat(rows.at("/6/levelId").asText()).isEqualTo(fourth);
		assertThat(rows.at("/7/problems/0").asText()).isEqualTo("duplicate_in_file");
		assertThat(rows.at("/7/sameAs").asInt()).isEqualTo(2);
		// The same new parent on two lines: one account.
		assertThat(state(rows, 10)).isEqualTo("READY");
		assertThat(rows.at("/8/sameParentAs").asInt()).isEqualTo(2);
		assertThat(count("students")).isEqualTo(1);

		List<Map<String, Object>> kept = new ArrayList<>();
		for (JsonNode row : rows) {
			if (List.of("READY", "PARENT_KNOWN").contains(row.at("/state").asText())) {
				kept.add(line(row));
			}
		}
		JsonNode result = body(call(post("/api/v1/students/import").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("createLogins", false, "rows", kept))), ines)
				.andExpect(status().isCreated()));
		assertThat(result.at("/created").asInt()).isEqualTo(5);
		assertThat(result.at("/linked").asInt()).isEqualTo(1);
		JsonNode credentials = result.at("/credentials");
		assertThat(credentials).hasSize(2);
		assertThat(credentials.at("/0/credential/username").asText()).isEqualTo("22345678");
		assertThat(credentials.at("/0/credential/role").asText()).isEqualTo("PARENT");
		assertThat(credentials.at("/0/children").toString()).isEqualTo("[\"Yassine\",\"Malek\"]");
		assertThat(credentials.at("/1/credential/firstName").asText()).isEqualTo("Nabil");

		assertThat(count("students")).isEqualTo(6);
		assertThat(count("parents")).isEqualTo(3);
		assertThat(jdbc.queryForObject("select count(*) from group_members where group_id = ?::uuid and left_at is null", Integer.class, group4A)).isEqualTo(5);
		// Rania joined her mother, who keeps her password.
		JsonNode parents = body(call(get("/api/v1/parents"), ines));
		JsonNode sonia = null;
		for (JsonNode p : parents) {
			if (p.at("/phone").asText().equals("22111222")) {
				sonia = p;
			}
		}
		assertThat(sonia).isNotNull();
		assertThat(sonia.at("/children")).hasSize(2);
	}

	@Test
	void anExcelWorkbookWithArabicHeadersAndPhonesTypedAsNumbers() throws Exception {
		byte[] workbook = xlsx(List.of(
				List.of("الاسم", "اللقب", "المستوى", "اسم الولي", "لقب الولي", "هاتف الولي"),
				List.of("Eya", "Trabelsi", "4ème année", "Nabil", "Trabelsi", 98123456),
				List.of("Omar", "Saidi", 4, "", "", "")));
		JsonNode rows = body(preview(workbook, "classe.xlsx", null, null).andExpect(status().isOk())).at("/rows");
		assertThat(rows).hasSize(2);
		assertThat(rows.at("/0/firstName").asText()).isEqualTo("Eya");
		assertThat(rows.at("/0/parentPhone").asText()).isEqualTo("98123456");
		assertThat(state(rows, 2)).isEqualTo("READY");
		assertThat(rows.at("/1/levelId").asText()).isEqualTo(fourth);
		assertThat(rows.at("/1/groupIds")).isEmpty();

		// With the pupils' own access: a login for each child too.
		JsonNode result = body(call(post("/api/v1/students/import").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("createLogins", true, "rows", List.of(line(rows.at("/1")))))), ines)
				.andExpect(status().isCreated()));
		assertThat(result.at("/credentials/0/credential/role").asText()).isEqualTo("STUDENT");
		assertThat(result.at("/credentials/0/credential/username").asText()).isEqualTo("omar.saidi");

		// A French CSV from Excel: Windows-1252, semicolons.
		byte[] latin = "Prénom;Nom;Niveau\nÉlyes;Mejri;5ème\n".getBytes(Charset.forName("windows-1252"));
		JsonNode accents = body(preview(latin, "liste.csv", null, null).andExpect(status().isOk())).at("/rows/0");
		assertThat(accents.at("/firstName").asText()).isEqualTo("Élyes");
		assertThat(accents.at("/levelText").asText()).isEqualTo("5ème");
	}

	@Test
	void wrongFilesAreRefusedAndAnImportIsAllOrNothing() throws Exception {
		preview("x".getBytes(), "old.xls", null, null).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("import_old_excel"));
		preview("x".getBytes(), "photo.png", null, null).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("import_file_type"));
		preview("Elève;Classe\nYassine;4\n".getBytes(), "a.csv", null, null)
				.andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("import_missing_columns"));
		preview("Prénom;Nom\n".getBytes(), "a.csv", null, null).andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("import_file_empty"));
		StringBuilder many = new StringBuilder("Prénom;Nom\n");
		for (int i = 0; i < 301; i++) {
			many.append("A").append(i).append(";B\n");
		}
		preview(many.toString().getBytes(), "a.csv", null, null)
				.andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("import_too_many_lines"));
		preview("PK\u0003\u0004 broken".getBytes(), "a.xlsx", null, null)
				.andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("import_file_unreadable"));

		// The second line's parent phone belongs to someone else's account: nothing at all is created.
		account("autre.enseignante");
		jdbc.update("update users set phone = '55000111' where username = 'autre.enseignante'");
		Map<String, Object> first = Map.of("line", 2, "firstName", "Yassine", "lastName", "Ben Ali", "levelId", fourth,
				"parentFirstName", "Sonia", "parentLastName", "Ben Ali", "parentPhone", "22345678");
		Map<String, Object> second = Map.of("line", 3, "firstName", "Eya", "lastName", "Trabelsi", "levelId", fourth,
				"parentFirstName", "Nabil", "parentLastName", "Trabelsi", "parentPhone", "55000111");
		call(post("/api/v1/students/import").contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("createLogins", false, "rows", List.of(first, second)))), ines)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("import_line_failed"));
		assertThat(count("students")).isEqualTo(1);
		assertThat(count("parents")).isEqualTo(1);

		// Another teacher cannot import into Ines's group; families cannot import at all.
		String other = token("autre.enseignante");
		preview("Prénom;Nom\nA;B\n".getBytes(), "a.csv", group4A, null, other).andExpect(status().isNotFound());
		call(post("/api/v1/students/import").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(Map.of("createLogins", false,
				"rows", List.of(Map.of("line", 2, "firstName", "A", "lastName", "B", "levelId", fourth, "groupIds", List.of(group4A)))))), other)
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("import_line_failed"));
		assertThat(count("students")).isEqualTo(1);
		// The empty template opens without signing in, headers in the teacher's language.
		byte[] template = mvc.perform(get("/api/v1/students/import/template?lang=ar")).andExpect(status().isOk()).andReturn().getResponse().getContentAsByteArray();
		JsonNode fromTemplate = body(preview(template, "modele.csv", null, null).andExpect(status().isOk())).at("/rows/0");
		assertThat(fromTemplate.at("/state").asText()).isEqualTo("READY");
		assertThat(fromTemplate.at("/levelId").asText()).isEqualTo(fourth);
		assertThat(fromTemplate.at("/parentPhone").asText()).isEqualTo("22345678");
		String mother = token("22111222", resetParent());
		preview("Prénom;Nom\nA;B\n".getBytes(), "a.csv", null, null, mother).andExpect(status().isForbidden());
	}

	// ── Helpers ──

	private static String state(JsonNode rows, int line) {
		for (JsonNode row : rows) {
			if (row.at("/line").asInt() == line) {
				return row.at("/state").asText();
			}
		}
		throw new AssertionError("no line " + line);
	}

	private static Map<String, Object> line(JsonNode row) {
		Map<String, Object> line = new HashMap<>();
		line.put("line", row.at("/line").asInt());
		line.put("firstName", row.at("/firstName").asText());
		line.put("lastName", row.at("/lastName").asText());
		line.put("levelId", row.at("/levelId").asText());
		List<String> groups = new ArrayList<>();
		row.at("/groupIds").forEach(g -> groups.add(g.asText()));
		line.put("groupIds", groups);
		line.put("parentFirstName", row.at("/parentFirstName").asText());
		line.put("parentLastName", row.at("/parentLastName").asText());
		line.put("parentPhone", row.at("/parentPhone").asText());
		return line;
	}

	/** A minimal workbook: inline strings, numbers as numbers, one sheet reached through the workbook's relations. */
	private static byte[] xlsx(List<List<Object>> rows) throws Exception {
		StringBuilder sheet = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?><worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><sheetData>");
		for (int r = 0; r < rows.size(); r++) {
			sheet.append("<row r=\"").append(r + 1).append("\">");
			for (int c = 0; c < rows.get(r).size(); c++) {
				Object value = rows.get(r).get(c);
				String ref = (char) ('A' + c) + String.valueOf(r + 1);
				if (value instanceof Number) {
					sheet.append("<c r=\"").append(ref).append("\"><v>").append(value).append("</v></c>");
				} else if (!value.toString().isEmpty()) {
					sheet.append("<c r=\"").append(ref).append("\" t=\"inlineStr\"><is><t>").append(value).append("</t></is></c>");
				}
			}
			sheet.append("</row>");
		}
		sheet.append("</sheetData></worksheet>");
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try (ZipOutputStream zip = new ZipOutputStream(out)) {
			put(zip, "xl/workbook.xml", "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><sheets><sheet name=\"Élèves\" sheetId=\"1\" r:id=\"rId7\"/></sheets></workbook>");
			put(zip, "xl/_rels/workbook.xml.rels", "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId7\" Type=\"worksheet\" Target=\"worksheets/eleves.xml\"/></Relationships>");
			put(zip, "xl/worksheets/eleves.xml", sheet.toString());
		}
		return out.toByteArray();
	}

	private static void put(ZipOutputStream zip, String name, String content) throws Exception {
		zip.putNextEntry(new ZipEntry(name));
		zip.write(content.getBytes(StandardCharsets.UTF_8));
		zip.closeEntry();
	}

	private ResultActions preview(byte[] data, String name, String groupId, String levelId) throws Exception {
		return preview(data, name, groupId, levelId, ines);
	}

	private ResultActions preview(byte[] data, String name, String groupId, String levelId, String token) throws Exception {
		var request = multipart("/api/v1/students/import/preview").file(new MockMultipartFile("file", name, "application/octet-stream", data));
		if (groupId != null) {
			request.param("groupId", groupId);
		}
		if (levelId != null) {
			request.param("levelId", levelId);
		}
		return call(request, token);
	}

	private int count(String table) {
		return jdbc.queryForObject("select count(*) from " + table, Integer.class);
	}

	/** Sonia Kefi's account with a known password, signed in. */
	private String resetParent() {
		jdbc.update("update users set password_hash = ?, must_change_password = false where username = '22111222'", passwordEncoder.encode(PASSWORD));
		return PASSWORD;
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
