package com.ngclass.backend.auth.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Builder.Default;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

/**
 * One signed-in device. The token is opaque and only its SHA-256 hash is stored. It is not rotated:
 * each refresh moves {@code expiresAt} one TTL further (client decision: stay signed in), which also
 * means two tabs refreshing at the same time can never log each other out.
 */
@Entity
@Table(name = "refresh_tokens")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefreshToken {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false, unique = true, length = 64)
	private String tokenHash;

	@Column(nullable = false)
	private UUID userId;

	@Column(nullable = false)
	private Instant expiresAt;

	@Default
	@Column(nullable = false)
	private boolean revoked = false;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private Instant createdAt;
}
