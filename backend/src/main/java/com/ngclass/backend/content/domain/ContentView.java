package com.ngclass.backend.content.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** A pupil or a parent opened a document: it is no longer "Nouveau" for them. */
@Entity
@Table(name = "content_views")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ContentView {
	@EmbeddedId
	private Key id;

	@Column(nullable = false)
	private Instant viewedAt;

	@Embeddable
	@Getter
	@NoArgsConstructor
	@AllArgsConstructor
	@EqualsAndHashCode
	public static class Key implements Serializable {
		@Column(name = "content_item_id")
		private UUID itemId;

		@Column(name = "user_id")
		private UUID userId;
	}
}
