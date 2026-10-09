package com.ngclass.backend.work.domain;

import com.ngclass.backend.content.domain.FileAsset;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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

/** What was sent for one pupil; the latest one counts. [submittedBy] is the pupil, or a parent for the child. */
@Entity
@Table(name = "submissions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Submission {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	@Column(nullable = false)
	private UUID recipientId;

	@ManyToOne(fetch = FetchType.EAGER, optional = false)
	@JoinColumn(name = "file_id", nullable = false)
	private FileAsset file;

	@Column(nullable = false)
	private Instant submittedAt;

	@Column(name = "is_late", nullable = false)
	private boolean late;

	@Column(nullable = false)
	private UUID submittedBy;
}
