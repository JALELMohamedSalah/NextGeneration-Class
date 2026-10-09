package com.ngclass.backend.seed;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.auth.service.Credentials;
import com.ngclass.backend.config.AppProperties;
import com.ngclass.backend.config.AppProperties.Seed;
import com.ngclass.backend.config.AppProperties.SeedAccount;
import com.ngclass.backend.school.service.SchoolYearService;
import java.time.Clock;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/** On every start: a current school year, and the teacher account if it does not exist yet. */
@Component
@Order(1)
@RequiredArgsConstructor
@Slf4j
public class StartupSeeder implements ApplicationRunner {
	private final SchoolYearService schoolYearService;
	private final UserRepository users;
	private final PasswordEncoder passwordEncoder;
	private final AppProperties properties;
	private final Clock clock;

	@Override
	public void run(ApplicationArguments args) {
		schoolYearService.ensureCurrent(LocalDate.now(clock.withZone(properties.zoneId())));
		Seed seed = properties.seed();
		seed(Role.ADMIN, seed == null ? null : seed.admin(), "ADMIN_USERNAME / ADMIN_PASSWORD");
		seed(Role.TEACHER, seed == null ? null : seed.teacher(), "TEACHER_USERNAME / TEACHER_PASSWORD");
	}

	/** The owner's account and a first teacher, when none exists yet. More teachers come from the dashboard. */
	private void seed(Role role, SeedAccount account, String variables) {
		if (users.existsByRole(role)) {
			return;
		}
		if (account == null || isBlank(account.username()) || isBlank(account.password())) {
			log.warn("{} not set: no {} account yet", variables, role.name().toLowerCase());
			return;
		}
		String username = Credentials.normalizeUsername(account.username());
		if (users.existsByUsername(username)) {
			log.warn("{} is already taken: no {} account created", username, role.name().toLowerCase());
			return;
		}
		users.save(User.builder()
				.role(role)
				.username(username)
				.passwordHash(passwordEncoder.encode(account.password()))
				.firstName(isBlank(account.firstName()) ? username : account.firstName().trim())
				.lastName(isBlank(account.lastName()) ? "" : account.lastName().trim())
				.mustChangePassword(account.mustChangePassword())
				.build());
		log.info("Seeded the {} account: {}", role.name().toLowerCase(), username);
	}

	private static boolean isBlank(String value) {
		return value == null || value.isBlank();
	}
}
