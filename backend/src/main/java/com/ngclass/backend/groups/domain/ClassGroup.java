package com.ngclass.backend.groups.domain;

import com.ngclass.backend.school.domain.Level;
import com.ngclass.backend.school.domain.SchoolYear;
import com.ngclass.backend.school.domain.Subject;
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
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/** A group of students for one subject and level; a private lesson is a group of one (spec 02). */
@Entity
@Table(name = "class_groups")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassGroup {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	/** The teacher whose space this belongs to (V6). */
	@Column(nullable = false)
	private UUID teacherId;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "school_year_id", nullable = false)
	private SchoolYear schoolYear;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "subject_id", nullable = false)
	private Subject subject;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "level_id", nullable = false)
	private Level level;

	@Column(nullable = false, length = 80)
	private String name;

	@Column(name = "is_private", nullable = false)
	private boolean privateLesson;

	/** Used by every online session of the group that has no link of its own. */
	@Column(length = 500)
	private String defaultMeetUrl;

	@Column(nullable = false, length = 7)
	private String color;

	private Instant archivedAt;

	@CreationTimestamp
	@Column(nullable = false, updatable = false)
	private Instant createdAt;

	@UpdateTimestamp
	@Column(nullable = false)
	private Instant updatedAt;
}
