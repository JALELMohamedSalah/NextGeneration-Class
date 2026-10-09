package com.ngclass.backend.auth.service;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.config.AppProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Component;

/** Short-lived access tokens (HS256). Refresh tokens are opaque and handled by {@link AuthService}. */
@Component
public class JwtService {
	private static final String ISSUER = "ngclass";

	private final SecretKey key;
	private final Duration accessTokenTtl;
	private final Clock clock;

	public JwtService(AppProperties properties, Clock clock) {
		String secret = properties.jwt().secret();
		if (secret == null || secret.length() < 32) {
			throw new IllegalStateException("JWT_SECRET must be set and at least 32 characters long");
		}
		this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
		this.accessTokenTtl = properties.jwt().accessTokenTtl();
		this.clock = clock;
	}

	public String createAccessToken(User user) {
		Instant now = clock.instant();
		return Jwts.builder()
				.id(UUID.randomUUID().toString())
				.issuer(ISSUER)
				.subject(user.getId().toString())
				.issuedAt(Date.from(now))
				.expiration(Date.from(now.plus(accessTokenTtl)))
				.claim("role", user.getRole().name())
				.claim("username", user.getUsername())
				.signWith(key, Jwts.SIG.HS256)
				.compact();
	}

	public long accessTokenTtlSeconds() {
		return accessTokenTtl.toSeconds();
	}

	public Optional<AuthenticatedUser> readAccessToken(String token) {
		try {
			Claims claims = Jwts.parser()
					.verifyWith(key)
					.requireIssuer(ISSUER)
					.build()
					.parseSignedClaims(token)
					.getPayload();
			return Optional.of(new AuthenticatedUser(
					UUID.fromString(claims.getSubject()),
					Role.valueOf(claims.get("role", String.class)),
					claims.get("username", String.class)));
		} catch (JwtException | IllegalArgumentException | NullPointerException ex) {
			return Optional.empty();
		}
	}
}
