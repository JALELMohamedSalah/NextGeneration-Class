package com.ngclass.backend.school.domain;

import com.ngclass.backend.common.LocalizedText;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "subjects")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Subject {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID id;

	/** The teacher whose space this belongs to (V6). */
	@Column(nullable = false)
	private UUID teacherId;

	/** Unique per teacher (case ignored). */
	@Column(nullable = false, length = 60)
	private String nameFr;

	@Column(nullable = false, length = 60)
	private String nameAr;

	@Column(nullable = false, length = 7)
	private String color;

	@Column(nullable = false)
	private int position;

	public LocalizedText name() {
		return new LocalizedText(nameFr, nameAr);
	}
}
