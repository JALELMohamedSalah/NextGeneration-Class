package com.ngclass.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ngclass.backend.auth.domain.RefreshToken;
import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.RefreshTokenRepository;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.school.repository.LevelRepository;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class AuthFlowTest {
	private static final String PASSWORD = "Secret2026x";

	@Container
	@ServiceConnection
	static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

	@Autowired
	private MockMvc mvc;
	@Autowired
	private ObjectMapper json;
	@Autowired
	private UserRepository users;
	@Autowired
	private RefreshTokenRepository refreshTokens;
	@Autowired
	private StudentRepository students;
	@Autowired
	private ParentRepository parents;
	@Autowired
	private LevelRepository levels;
	@Autowired
	private PasswordEncoder passwordEncoder;

	private User student;

	@BeforeEach
	void accounts() {
		parents.deleteAll();
		students.deleteAll();
		refreshTokens.deleteAll();
		users.deleteAll();
		User teacher = users.save(user(Role.TEACHER, "enseignante", null));
		student = users.save(user(Role.STUDENT, "adam.gharbi", "20000002"));
		Student studentProfile = students.save(Student.builder()
				.teacherId(teacher.getId())
				.user(student)
				.level(levels.findAllByOrderByPositionAsc().getFirst())
				.build());
		User parent = users.save(user(Role.PARENT, "mouna.gharbi", "20000001"));
		parents.save(Parent.builder().teacherId(teacher.getId()).user(parent).children(Set.of(studentProfile)).build());
	}

	@Test
	void teacherLogsInWithUsernameInAnyCase() throws Exception {
		login(" Enseignante ", PASSWORD)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.user.role").value("TEACHER"))
				.andExpect(jsonPath("$.accessToken").isNotEmpty())
				.andExpect(jsonPath("$.refreshToken").isNotEmpty());
	}

	@Test
	void parentLogsInWithFormattedPhoneAndSeesTheChild() throws Exception {
		String token = accessToken(login("+216 20 000 001", PASSWORD).andExpect(status().isOk()));
		mvc.perform(get("/api/v1/me").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.role").value("PARENT"))
				.andExpect(jsonPath("$.children[0].firstName").value("Adam"))
				.andExpect(jsonPath("$.children[0].level.fr").value("1ère année"))
				.andExpect(jsonPath("$.children[0].level.ar").isNotEmpty());
	}

	@Test
	void errorsAreWrittenInTheRequestLanguage() throws Exception {
		login("enseignante", "wrong-1234")
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("invalid_credentials"))
				.andExpect(jsonPath("$.message").value("Identifiant ou mot de passe incorrect."));
		mvc.perform(post("/api/v1/auth/login")
						.header(HttpHeaders.ACCEPT_LANGUAGE, "ar")
						.contentType(MediaType.APPLICATION_JSON)
						.content(json.writeValueAsString(Map.of("login", "enseignante", "password", "wrong-1234"))))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.message").value("المعرّف أو كلمة المرور غير صحيحة."));
		mvc.perform(get("/api/v1/me").header(HttpHeaders.ACCEPT_LANGUAGE, "ar"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("unauthorized"))
				.andExpect(jsonPath("$.message").value("يرجى تسجيل الدخول."));
	}

	@Test
	void loginRemembersTheAppLanguage() throws Exception {
		mvc.perform(post("/api/v1/auth/login")
						.header(HttpHeaders.ACCEPT_LANGUAGE, "ar")
						.contentType(MediaType.APPLICATION_JSON)
						.content(json.writeValueAsString(Map.of("login", "adam.gharbi", "password", PASSWORD))))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.user.language").value("ar"));
	}

	@Test
	void fiveWrongPasswordsLockTheAccount() throws Exception {
		for (int i = 0; i < 4; i++) {
			login("adam.gharbi", "wrong-1234").andExpect(status().isUnauthorized());
		}
		login("adam.gharbi", "wrong-1234")
				.andExpect(status().isLocked())
				.andExpect(jsonPath("$.code").value("account_locked"))
				.andExpect(jsonPath("$.message").value("Trop de tentatives. Réessayez dans 15 minutes."));
		login("adam.gharbi", PASSWORD).andExpect(status().isLocked());
	}

	@Test
	void refreshKeepsTheSameTokenAndPushesItsExpiryAYearAway() throws Exception {
		JsonNode session = body(login("adam.gharbi", PASSWORD));
		String refreshToken = session.get("refreshToken").asText();
		RefreshToken stored = refreshTokens.findAll().getFirst();
		stored.setExpiresAt(Instant.now().plus(Duration.ofDays(1)));
		refreshTokens.save(stored);

		JsonNode refreshed = body(mvc.perform(post("/api/v1/auth/refresh")
						.contentType(MediaType.APPLICATION_JSON)
						.content(json.writeValueAsString(Map.of("refreshToken", refreshToken))))
				.andExpect(status().isOk()));

		assertThat(refreshed.get("refreshToken").asText()).isEqualTo(refreshToken);
		assertThat(refreshTokens.findAll().getFirst().getExpiresAt())
				.isAfter(Instant.now().plus(Duration.ofDays(364)));
	}

	@Test
	void loggedOutRefreshTokenIsRefused() throws Exception {
		String refreshToken = body(login("adam.gharbi", PASSWORD)).get("refreshToken").asText();
		mvc.perform(post("/api/v1/auth/logout")
						.contentType(MediaType.APPLICATION_JSON)
						.content(json.writeValueAsString(Map.of("refreshToken", refreshToken))))
				.andExpect(status().isNoContent());
		mvc.perform(post("/api/v1/auth/refresh")
						.contentType(MediaType.APPLICATION_JSON)
						.content(json.writeValueAsString(Map.of("refreshToken", refreshToken))))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.code").value("invalid_refresh_token"));
	}

	@Test
	void onlyTheTeacherResetsPasswordsAndTheUserMustChooseANewOne() throws Exception {
		String studentToken = accessToken(login("adam.gharbi", PASSWORD));
		mvc.perform(post("/api/v1/users/{id}/reset-password", student.getId())
						.header(HttpHeaders.AUTHORIZATION, "Bearer " + studentToken))
				.andExpect(status().isForbidden())
				.andExpect(jsonPath("$.code").value("forbidden"));

		String teacherToken = accessToken(login("enseignante", PASSWORD));
		String temporary = body(mvc.perform(post("/api/v1/users/{id}/reset-password", student.getId())
						.header(HttpHeaders.AUTHORIZATION, "Bearer " + teacherToken))
				.andExpect(status().isOk()))
				.get("temporaryPassword").asText();

		login("adam.gharbi", temporary)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.user.mustChangePassword").value(true));
	}

	@Test
	void passwordChangeFollowsThePolicy() throws Exception {
		String token = accessToken(login("adam.gharbi", PASSWORD));
		changePassword(token, PASSWORD, "short1")
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("weak_password"));
		changePassword(token, "not-mine-123", "Nouveau2026")
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("wrong_password"));
		changePassword(token, PASSWORD, "Nouveau2026").andExpect(status().isNoContent());
		login("adam.gharbi", "Nouveau2026").andExpect(status().isOk());
	}

	@Test
	void languageCanBeChangedToArabicOnly() throws Exception {
		String token = accessToken(login("adam.gharbi", PASSWORD));
		mvc.perform(put("/api/v1/me/language")
						.header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"language\":\"ar\"}"))
				.andExpect(status().isNoContent());
		mvc.perform(put("/api/v1/me/language")
						.header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"language\":\"en\"}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.code").value("unsupported_language"));
	}

	@Test
	void referenceDataIsBilingualPrimarySchoolWithoutPredefinedSubjects() throws Exception {
		String token = accessToken(login("adam.gharbi", PASSWORD));
		mvc.perform(get("/api/v1/reference").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.levels.length()").value(6))
				.andExpect(jsonPath("$.levels[0].name.fr").value("1ère année"))
				.andExpect(jsonPath("$.levels[0].name.ar").value("السنة الأولى ابتدائي"))
				.andExpect(jsonPath("$.subjects.length()").value(0))
				.andExpect(jsonPath("$.currentSchoolYear.label").isNotEmpty());
	}

	@Test
	void theOwnerOfThePlatformSignsInWithoutATeacherSpace() throws Exception {
		users.save(user(Role.ADMIN, "admin", null));
		String token = accessToken(login("admin", PASSWORD)
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.user.role").value("ADMIN")));
		mvc.perform(get("/api/v1/reference").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.subjects.length()").value(0))
				.andExpect(jsonPath("$.levels.length()").value(6));
	}

	private User user(Role role, String username, String phone) {
		return User.builder()
				.role(role)
				.username(username)
				.phone(phone)
				.passwordHash(passwordEncoder.encode(PASSWORD))
				.firstName(username.equals("adam.gharbi") ? "Adam" : "Test")
				.lastName("Gharbi")
				.build();
	}

	private ResultActions login(String login, String password) throws Exception {
		return mvc.perform(post("/api/v1/auth/login")
				.contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("login", login, "password", password))));
	}

	private ResultActions changePassword(String token, String current, String next) throws Exception {
		return mvc.perform(post("/api/v1/me/password")
				.header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
				.contentType(MediaType.APPLICATION_JSON)
				.content(json.writeValueAsString(Map.of("currentPassword", current, "newPassword", next))));
	}

	private JsonNode body(ResultActions result) throws Exception {
		return json.readTree(result.andReturn().getResponse().getContentAsString());
	}

	private String accessToken(ResultActions result) throws Exception {
		return body(result).get("accessToken").asText();
	}
}
