package com.ngclass.backend.content.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/** A document of the library (spec 04). Without a chapter it sits in "Sans chapitre" of its subject and level. */
@Entity
@Table(name = "content_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContentItem {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false)
	private UUID teacherId;

	@Column(nullable = false, length = 160)
	private String title;

	@Column(nullable = false)
	private UUID subjectId;

	@Column(nullable = false)
	private UUID levelId;

	private UUID chapterId;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 20)
	private ContentStatus status;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 20)
	private ContentTag tag;

	@ManyToOne(fetch = FetchType.EAGER, optional = false)
	@JoinColumn(name = "file_id", nullable = false)
	private FileAsset file;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private Instant createdAt;

	@UpdateTimestamp
	@Column(nullable = false)
	private Instant updatedAt;
}
