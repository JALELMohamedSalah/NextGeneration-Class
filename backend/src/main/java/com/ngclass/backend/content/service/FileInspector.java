package com.ngclass.backend.content.service;

import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.FileKind;
import java.io.IOException;
import java.util.Locale;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.springframework.stereotype.Component;

/**
 * What an upload really is, read from its first bytes rather than its name or the browser's word:
 * PDF, JPEG, PNG or Word (.docx). Anything else is refused (spec 04: HEIC photos are converted to
 * JPEG on the phone before upload).
 */
@Component
public class FileInspector {
	public static final long MAX_BYTES = 20L * 1024 * 1024;

	public record Inspected(String mimeType, Integer pageCount) {
	}

	public Inspected inspect(byte[] data, String originalName) {
		if (data == null || data.length == 0) {
			throw ApiException.badRequest("file_required");
		}
		if (data.length > MAX_BYTES) {
			throw ApiException.badRequest("file_too_large");
		}
		if (starts(data, '%', 'P', 'D', 'F')) {
			return new Inspected(FileKind.PDF.mimeType(), pageCount(data));
		}
		if (starts(data, 0xFF, 0xD8, 0xFF)) {
			return new Inspected("image/jpeg", null);
		}
		if (starts(data, 0x89, 'P', 'N', 'G')) {
			return new Inspected("image/png", null);
		}
		String name = originalName == null ? "" : originalName.toLowerCase(Locale.ROOT);
		if (starts(data, 'P', 'K', 3, 4) && name.endsWith(".docx")) {
			return new Inspected(FileKind.WORD.mimeType(), null);
		}
		throw ApiException.badRequest("file_type_not_allowed");
	}

	/** Homework and corrected copies (spec 06): a PDF or a photo only, never a Word file. */
	public Inspected inspectWork(byte[] data, String originalName) {
		Inspected inspected;
		try {
			inspected = inspect(data, originalName);
		} catch (ApiException e) {
			throw "file_type_not_allowed".equals(e.getCode()) ? ApiException.badRequest("work_file_not_allowed") : e;
		}
		if (FileKind.WORD.mimeType().equals(inspected.mimeType())) {
			throw ApiException.badRequest("work_file_not_allowed");
		}
		return inspected;
	}

	private static Integer pageCount(byte[] data) {
		try (PDDocument pdf = Loader.loadPDF(data)) {
			int pages = pdf.getNumberOfPages();
			if (pages == 0) {
				throw ApiException.badRequest("file_unreadable");
			}
			return pages;
		} catch (IOException e) {
			// Damaged, or protected by a password.
			throw ApiException.badRequest("file_unreadable");
		}
	}

	private static boolean starts(byte[] data, int... prefix) {
		if (data.length < prefix.length) {
			return false;
		}
		for (int i = 0; i < prefix.length; i++) {
			if ((data[i] & 0xFF) != prefix[i]) {
				return false;
			}
		}
		return true;
	}
}
