package com.ngclass.backend.groups.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** A student in a group. Leaving sets {@code leftAt}, so past attendance keeps its group. */
@Entity
@Table(name = "group_members")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroupMember {
	@EmbeddedId
	private Key id;

	@Column(nullable = false)
	private Instant joinedAt;

	private Instant leftAt;

	@Embeddable
	@Getter
	@NoArgsConstructor
	@AllArgsConstructor
	@EqualsAndHashCode
	public static class Key implements Serializable {
		@Column(name = "group_id")
		private UUID groupId;

		@Column(name = "student_id")
		private UUID studentId;
	}
}
