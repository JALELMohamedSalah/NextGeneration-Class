package com.ngclass.backend.people.dto;

import com.ngclass.backend.common.LocalizedText;
import java.util.UUID;

/** A child followed by a parent account. */
public record ChildResponse(UUID studentId, String firstName, String lastName, LocalizedText level) {
	/** Used by the JPQL projection in ParentRepository. */
	public ChildResponse(UUID studentId, String firstName, String lastName, String levelFr, String levelAr) {
		this(studentId, firstName, lastName, new LocalizedText(levelFr, levelAr));
	}
}
