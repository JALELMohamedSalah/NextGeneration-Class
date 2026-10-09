package com.ngclass.backend.auth.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 16)
	private Role role;

	/** Always lower case. */
	@Column(nullable = false, unique = true, length = 64)
	private String username;

	/** Tunisian number, 8 digits, no prefix. Can be used to log in. */
	@Column(unique = true, length = 20)
	private String phone;

	private String email;

	@Column(nullable = false, length = 100)
	private String passwordHash;

	@Column(nullable = false, length = 80)
	private String firstName;

	@Column(nullable = false, length = 80)
	private String lastName;

	/** "fr" or "ar": the last language used in the app, for messages the server sends on its own. */
	@Default
	@Column(nullable = false, length = 2)
	private String language = "fr";

	@Default
	@Column(nullable = false)
	private boolean active = true;

	/** Set when the teacher created or reset the password: the user chooses a new one at next login. */
	@Default
	@Column(nullable = false)
	private boolean mustChangePassword = false;

	/** False: a child followed through their parents, who does not sign in (yet). */
	@Default
	@Column(nullable = false)
	private boolean loginEnabled = true;

	@Default
	@Column(nullable = false)
	private int failedLoginAttempts = 0;

	private Instant lockedUntil;

	private Instant lastLoginAt;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private Instant createdAt;

	@UpdateTimestamp
	@Column(nullable = false)
	private Instant updatedAt;
}
