package com.ngclass.backend.content.domain;

/** Only a published document can be shared; a draft is never visible to pupils or parents (spec 04). */
public enum ContentStatus {
	DRAFT,
	PUBLISHED,
	ARCHIVED
}
