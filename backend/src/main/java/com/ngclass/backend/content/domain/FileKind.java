package com.ngclass.backend.content.domain;

/** What the viewer can do with a file: PDF pages and images open in the app, Word only downloads. */
public enum FileKind {
	PDF("application/pdf"),
	IMAGE(null),
	WORD("application/vnd.openxmlformats-officedocument.wordprocessingml.document");

	private final String mimeType;

	FileKind(String mimeType) {
		this.mimeType = mimeType;
	}

	public static FileKind of(String mimeType) {
		if (PDF.mimeType.equals(mimeType)) {
			return PDF;
		}
		if (WORD.mimeType.equals(mimeType)) {
			return WORD;
		}
		return IMAGE;
	}

	public String mimeType() {
		return mimeType;
	}
}
