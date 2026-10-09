package com.ngclass.backend.config;

import java.time.Duration;
import java.time.ZoneId;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app")
public record AppProperties(
		String timeZone,
		List<String> allowedOrigins,
		Jwt jwt,
		Security security,
		Seed seed,
		DevData devData,
		Storage storage) {

	public ZoneId zoneId() {
		return ZoneId.of(timeZone);
	}

	public record Jwt(String secret, Duration accessTokenTtl, Duration refreshTokenTtl) {
	}

	public record Security(int bcryptStrength, int maxLoginAttempts, Duration lockDuration) {
	}

	/** The first teacher and the owner of the platform (ADMIN), created on first start when missing. */
	public record Seed(SeedAccount teacher, SeedAccount admin) {
	}

	public record SeedAccount(
			String username,
			String password,
			String firstName,
			String lastName,
			boolean mustChangePassword) {
	}

	/** Uploaded files: a folder on the server (a volume in production), behind FileStorage. */
	public record Storage(String dir) {
	}

	/** Test accounts created by the dev profile only. */
	public record DevData(
			String studentUsername,
			String studentPassword,
			String parentPhone,
			String parentPassword) {
	}
}
