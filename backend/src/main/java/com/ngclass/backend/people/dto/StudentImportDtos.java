package com.ngclass.backend.people.dto;

import com.ngclass.backend.people.dto.StudentDtos.Credential;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

/** Importing pupils from Excel or CSV (spec 02 "CSV import", design `r2/ImportEleves*.png`). */
public final class StudentImportDtos {
	private StudentImportDtos() {
	}

	/**
	 * One line of the file, as read and checked. [state]: READY, PARENT_KNOWN (the parent's phone is one of the
	 * teacher's parents: the child joins them, no new account), EXISTS (a pupil of the same name: left out unless the
	 * teacher keeps it) or ERROR (never imported; [problems] say why). [levelText] and [groupText] as written, for
	 * the messages. [sameParentAs]: an earlier line with the same new parent (one account for both).
	 */
	public record ImportRow(
			int line,
			String firstName,
			String lastName,
			UUID levelId,
			String levelText,
			List<UUID> groupIds,
			String groupText,
			String phone,
			String parentFirstName,
			String parentLastName,
			String parentPhone,
			String state,
			List<String> problems,
			String knownParent,
			Integer sameParentAs,
			Integer sameAs) {
	}

	/** [rows]: in file order; [lines]: the pupils read (the header aside). */
	public record ImportPreview(String fileName, int lines, List<ImportRow> rows) {
	}

	/** A line the teacher keeps, as the preview read it. */
	public record ImportLine(
			int line,
			@NotBlank @Size(max = 80) String firstName,
			@NotBlank @Size(max = 80) String lastName,
			@NotNull UUID levelId,
			List<UUID> groupIds,
			@Size(max = 30) String phone,
			@Size(max = 80) String parentFirstName,
			@Size(max = 80) String parentLastName,
			@Size(max = 30) String parentPhone) {
	}

	public record ImportRequest(boolean createLogins, @NotEmpty @Size(max = 300) @Valid List<ImportLine> rows) {
	}

	/** A new account to hand over, with the imported children it is for. */
	public record ImportedCredential(Credential credential, List<String> children) {
	}

	/** [linked]: children who joined a parent already known. */
	public record ImportResult(int created, int linked, List<ImportedCredential> credentials) {
	}
}
