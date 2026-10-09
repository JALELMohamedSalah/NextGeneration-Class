package com.ngclass.backend.people.service;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.repository.UserRepository;
import com.ngclass.backend.auth.service.Credentials;
import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.groups.dto.GroupDtos.GroupResponse;
import com.ngclass.backend.groups.service.GroupService;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.dto.StudentDtos.CreatedStudent;
import com.ngclass.backend.people.dto.StudentDtos.Credential;
import com.ngclass.backend.people.dto.StudentDtos.ParentInput;
import com.ngclass.backend.people.dto.StudentDtos.ParentTag;
import com.ngclass.backend.people.dto.StudentDtos.StudentRequest;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportLine;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportPreview;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportRequest;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportResult;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportRow;
import com.ngclass.backend.people.dto.StudentImportDtos.ImportedCredential;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import com.ngclass.backend.school.domain.Level;
import com.ngclass.backend.school.repository.LevelRepository;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Importing a class from Excel or CSV (spec 02 "CSV import", design `r2/ImportEleves*.png`): first every line is read
 * and checked, nothing created; then the lines the teacher keeps are created together, or none of them. A parent's
 * phone already known links the child to that parent; the same new phone on several lines makes one account.
 */
@Service
@RequiredArgsConstructor
public class StudentImportService {
	public static final int MAX_LINES = 300;

	private final StudentService studentService;
	private final GroupService groupService;
	private final StudentRepository students;
	private final ParentRepository parents;
	private final UserRepository users;
	private final LevelRepository levels;
	private final CurrentTeacher teacher;

	private enum Column { FIRST_NAME, LAST_NAME, LEVEL, GROUP, PHONE, PARENT_FIRST_NAME, PARENT_LAST_NAME, PARENT_PHONE }

	/** Reads the file and checks every line; [groupId] for everyone, [levelId] when the line has no level. */
	@Transactional(readOnly = true)
	public ImportPreview preview(byte[] data, String fileName, UUID groupId, UUID levelId) {
		if (groupId != null) {
			groupService.require(groupId);
		}
		Level defaultLevel = levelId == null ? null : levels.findById(levelId).orElseThrow(() -> ApiException.notFound("level_not_found"));
		List<List<String>> rows = ImportFileReader.read(data, fileName);
		if (rows.isEmpty()) {
			throw ApiException.badRequest("import_file_empty");
		}
		Map<Column, Integer> columns = columns(rows.getFirst());
		if (!columns.containsKey(Column.FIRST_NAME) || !columns.containsKey(Column.LAST_NAME)) {
			throw ApiException.badRequest("import_missing_columns");
		}
		if (rows.size() - 1 > MAX_LINES) {
			throw ApiException.badRequest("import_too_many_lines", MAX_LINES);
		}
		if (rows.size() == 1) {
			throw ApiException.badRequest("import_file_empty");
		}

		List<Level> allLevels = levels.findAllByOrderByPositionAsc();
		List<GroupResponse> groups = groupService.list();
		Map<String, Parent> known = knownParents();
		Set<String> existing = new HashSet<>();
		students.findAllForList(teacher.id(), false).forEach(s -> existing.add(key(s.getUser().getFirstName(), s.getUser().getLastName())));
		Map<String, Integer> pupilsInFile = new HashMap<>();
		Map<String, Integer> newParentsInFile = new HashMap<>();

		List<ImportRow> out = new ArrayList<>();
		for (int i = 1; i < rows.size(); i++) {
			List<String> row = rows.get(i);
			int line = i + 1;
			List<String> problems = new ArrayList<>();
			String first = cell(row, columns, Column.FIRST_NAME);
			String last = cell(row, columns, Column.LAST_NAME);
			if (first.isEmpty()) {
				problems.add("first_name_missing");
			}
			if (last.isEmpty()) {
				problems.add("last_name_missing");
			}

			String levelText = cell(row, columns, Column.LEVEL);
			UUID level = null;
			if (levelText.isEmpty()) {
				if (defaultLevel == null) {
					problems.add("level_missing");
				} else {
					level = defaultLevel.getId();
				}
			} else {
				level = levelOf(levelText, allLevels).map(Level::getId).orElse(null);
				if (level == null) {
					problems.add("level_unknown");
				}
			}

			Set<UUID> groupIds = new LinkedHashSet<>();
			if (groupId != null) {
				groupIds.add(groupId);
			}
			String groupText = cell(row, columns, Column.GROUP);
			if (!groupText.isEmpty()) {
				Optional<GroupResponse> group = groups.stream().filter(g -> plain(g.name()).equals(plain(groupText)) || plain(g.code()).equals(plain(groupText))).findFirst();
				group.ifPresentOrElse(g -> groupIds.add(g.id()), () -> problems.add("group_unknown"));
			}

			String phone = cell(row, columns, Column.PHONE);
			String phoneDigits = null;
			if (!phone.isEmpty()) {
				phoneDigits = Credentials.phoneDigits(phone).orElse(null);
				if (phoneDigits == null) {
					problems.add("phone_invalid");
				} else if (taken(phoneDigits)) {
					problems.add("phone_taken");
				}
			}

			String parentFirst = cell(row, columns, Column.PARENT_FIRST_NAME);
			String parentLast = cell(row, columns, Column.PARENT_LAST_NAME);
			String parentPhone = cell(row, columns, Column.PARENT_PHONE);
			String parentDigits = null;
			String knownParent = null;
			Integer sameParentAs = null;
			if (!parentFirst.isEmpty() || !parentLast.isEmpty() || !parentPhone.isEmpty()) {
				if (parentPhone.isEmpty()) {
					problems.add("parent_phone_missing");
				} else {
					parentDigits = Credentials.phoneDigits(parentPhone).orElse(null);
					if (parentDigits == null) {
						problems.add("parent_phone_invalid");
					} else if (known.containsKey(parentDigits)) {
						Parent parent = known.get(parentDigits);
						knownParent = parent.getUser().getFirstName() + " " + parent.getUser().getLastName();
					} else if (taken(parentDigits)) {
						problems.add("parent_phone_taken");
					} else if (newParentsInFile.containsKey(parentDigits)) {
						sameParentAs = newParentsInFile.get(parentDigits);
					} else if (parentFirst.isEmpty() || parentLast.isEmpty()) {
						problems.add("parent_name_missing");
					}
				}
			}

			Integer sameAs = null;
			if (!first.isEmpty() && !last.isEmpty()) {
				sameAs = pupilsInFile.get(key(first, last));
				if (sameAs != null) {
					problems.add("duplicate_in_file");
				}
			}
			String state;
			if (!problems.isEmpty()) {
				state = "ERROR";
			} else if (existing.contains(key(first, last))) {
				state = "EXISTS";
			} else if (knownParent != null) {
				state = "PARENT_KNOWN";
			} else {
				state = "READY";
			}
			if (!"ERROR".equals(state)) {
				pupilsInFile.putIfAbsent(key(first, last), line);
				if (parentDigits != null && knownParent == null) {
					newParentsInFile.putIfAbsent(parentDigits, line);
				}
			}
			out.add(new ImportRow(line, first, last, level, levelText, List.copyOf(groupIds), groupText, phoneDigits == null ? phone : phoneDigits,
					parentFirst, parentLast, parentDigits == null ? parentPhone : parentDigits, state, List.copyOf(problems), knownParent,
					sameParentAs, sameAs));
		}
		return new ImportPreview(fileName, out.size(), out);
	}

	/** The lines kept, all created or none: a line refused now stops the whole import. */
	@Transactional
	public ImportResult importLines(ImportRequest request) {
		Map<String, Parent> before = knownParents();
		Map<String, UUID> parentByPhone = new HashMap<>();
		before.forEach((phone, parent) -> parentByPhone.put(phone, parent.getId()));
		Map<UUID, ImportedCredential> credentials = new LinkedHashMap<>();
		Map<UUID, UUID> parentUser = new HashMap<>();
		int linked = 0;
		for (ImportLine line : request.rows()) {
			List<ParentInput> parentInputs = List.of();
			String digits = null;
			if (line.parentPhone() != null && !line.parentPhone().isBlank()) {
				digits = Credentials.phoneDigits(line.parentPhone()).orElseThrow(() -> ApiException.badRequest("import_line_failed", line.line()));
				UUID existing = parentByPhone.get(digits);
				parentInputs = List.of(existing != null
						? new ParentInput(existing, null, null, null, null, null)
						: new ParentInput(null, line.parentFirstName(), line.parentLastName(), digits, null, null));
				if (before.containsKey(digits)) {
					linked++;
				}
			}
			CreatedStudent created;
			try {
				created = studentService.create(new StudentRequest(line.firstName().trim(), line.lastName().trim(), line.levelId(),
						blank(line.phone()) ? null : line.phone(), null, line.groupIds(), parentInputs, request.createLogins()));
			} catch (ApiException refused) {
				throw ApiException.badRequest("import_line_failed", line.line());
			}
			String child = line.firstName().trim();
			for (Credential credential : created.credentials()) {
				credentials.put(credential.userId(), new ImportedCredential(credential,
						credential.role() == Role.PARENT ? new ArrayList<>(List.of(child)) : new ArrayList<>()));
			}
			if (digits != null) {
				final String phone = digits;
				ParentTag tag = created.student().parents().stream().filter(p -> phone.equals(p.phone())).findFirst().orElseThrow();
				parentByPhone.putIfAbsent(digits, tag.id());
				parentUser.putIfAbsent(tag.id(), tag.userId());
				// Another child of a parent created by this import: on the same card.
				ImportedCredential card = credentials.get(tag.userId());
				if (card != null && !card.children().contains(child)) {
					card.children().add(child);
				}
			}
		}
		return new ImportResult(request.rows().size(), linked, List.copyOf(credentials.values()));
	}

	// ── Reading the columns ──

	/** By the header's words, in French or Arabic; the parent's columns say "parent" (or ولي). */
	static Map<Column, Integer> columns(List<String> header) {
		Map<Column, Integer> out = new LinkedHashMap<>();
		for (int i = 0; i < header.size(); i++) {
			String h = plain(header.get(i));
			if (h.isEmpty()) {
				continue;
			}
			boolean parent = h.contains("parent") || h.contains("ولي") || h.contains("الام") || h.contains("الاب") || h.contains("tuteur");
			Column column = null;
			if (h.contains("prenom") || h.contains("first") || h.contains("اسم")) {
				column = parent ? Column.PARENT_FIRST_NAME : Column.FIRST_NAME;
			} else if (h.contains("tel") || h.contains("phone") || h.contains("portable") || h.contains("هاتف") || h.contains("جوال")) {
				column = parent ? Column.PARENT_PHONE : Column.PHONE;
			} else if (h.contains("nom") || h.contains("last") || h.contains("لقب")) {
				column = parent ? Column.PARENT_LAST_NAME : Column.LAST_NAME;
			} else if (h.contains("niveau") || h.contains("classe") || h.contains("مستوى") || h.contains("سنة")) {
				column = Column.LEVEL;
			} else if (h.contains("groupe") || h.contains("مجموعة") || h.contains("فوج")) {
				column = Column.GROUP;
			}
			if (column != null) {
				out.putIfAbsent(column, i);
			}
		}
		return out;
	}

	/** "4ème année", "4e", "4", "quatrième", "السنة الرابعة", "٤". Only 1ère to 6ème année exist. */
	static Optional<Level> levelOf(String text, List<Level> all) {
		String t = plain(text);
		for (Level level : all) {
			if (t.equals(plain(level.getNameFr())) || (level.getNameAr() != null && t.equals(plain(level.getNameAr())))) {
				return Optional.of(level);
			}
		}
		Integer position = null;
		for (char c : t.toCharArray()) {
			if (Character.isDigit(c)) {
				position = Character.getNumericValue(c);
				break;
			}
		}
		if (position == null) {
			String[][] words = {
					{"premiere", "1"}, {"deuxieme", "2"}, {"troisieme", "3"}, {"quatrieme", "4"}, {"cinquieme", "5"}, {"sixieme", "6"},
					{"اولى", "1"}, {"ثانية", "2"}, {"ثالثة", "3"}, {"رابعة", "4"}, {"خامسة", "5"}, {"سادسة", "6"}};
			for (String[] word : words) {
				if (t.contains(word[0])) {
					position = Integer.parseInt(word[1]);
					break;
				}
			}
		}
		if (position == null || position < 1 || position > 6) {
			return Optional.empty();
		}
		final int wanted = position;
		return all.stream().filter(l -> l.getPosition() == wanted).findFirst();
	}

	/** Lower case, no accents (and no hamza marks: أ reads ا), words separated by one space. */
	static String plain(String text) {
		if (text == null) {
			return "";
		}
		String t = Normalizer.normalize(text, Normalizer.Form.NFD).replaceAll("\\p{M}", "").toLowerCase(Locale.ROOT);
		return t.replaceAll("[^\\p{L}\\p{N}]+", " ").trim();
	}

	private static String key(String first, String last) {
		return plain(first) + "|" + plain(last);
	}

	private static String cell(List<String> row, Map<Column, Integer> columns, Column column) {
		Integer i = columns.get(column);
		return i == null || i >= row.size() || row.get(i) == null ? "" : row.get(i).trim();
	}

	/** This teacher's parents, by phone. */
	private Map<String, Parent> knownParents() {
		Map<String, Parent> out = new HashMap<>();
		for (Parent parent : parents.findAllWithChildren(teacher.id())) {
			String phone = parent.getUser().getPhone();
			if (phone != null) {
				out.put(phone, parent);
			}
		}
		return out;
	}

	/** A phone is also a parent's username: free in neither column, it belongs to someone else. */
	private boolean taken(String digits) {
		return users.existsByPhone(digits) || users.existsByUsername(digits);
	}

	private static boolean blank(String value) {
		return value == null || value.isBlank();
	}
}
