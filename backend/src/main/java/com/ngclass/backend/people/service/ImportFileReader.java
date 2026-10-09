package com.ngclass.backend.people.service;

import com.ngclass.backend.common.ApiException;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

/**
 * Reads the teacher's list of pupils (spec 02 "CSV import"): an Excel workbook (.xlsx, its first sheet) or a CSV file
 * (comma, semicolon or tab; UTF-8, or Windows-1252 as French Excel saves it). Only the JDK: an .xlsx is a zip of XML
 * files. Returns the rows as text cells, empty rows left out; numbers lose a trailing ".0" (phones typed as numbers).
 */
final class ImportFileReader {
	/** A class list is small; this keeps a wrong file from filling the memory. */
	static final int MAX_BYTES = 2 * 1024 * 1024;
	private static final int MAX_ENTRY_BYTES = 20 * 1024 * 1024;

	private ImportFileReader() {
	}

	static List<List<String>> read(byte[] data, String fileName) {
		if (data == null || data.length == 0) {
			throw ApiException.badRequest("import_file_empty");
		}
		if (data.length > MAX_BYTES) {
			throw ApiException.badRequest("import_file_too_big");
		}
		String name = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT).trim();
		boolean zip = data.length > 4 && data[0] == 'P' && data[1] == 'K';
		List<List<String>> rows;
		if (zip || name.endsWith(".xlsx")) {
			rows = xlsx(data);
		} else if (name.endsWith(".xls")) {
			// The old binary format: Excel saves it again as .xlsx in one click.
			throw ApiException.badRequest("import_old_excel");
		} else if (name.endsWith(".csv") || name.endsWith(".txt") || name.isEmpty()) {
			rows = csv(text(data));
		} else {
			throw ApiException.badRequest("import_file_type");
		}
		return rows.stream().filter(r -> r.stream().anyMatch(c -> !c.isBlank())).toList();
	}

	// ── CSV ──

	private static String text(byte[] data) {
		int start = data.length >= 3 && (data[0] & 0xFF) == 0xEF && (data[1] & 0xFF) == 0xBB && (data[2] & 0xFF) == 0xBF ? 3 : 0;
		ByteBuffer bytes = ByteBuffer.wrap(data, start, data.length - start);
		try {
			return StandardCharsets.UTF_8.newDecoder()
					.onMalformedInput(CodingErrorAction.REPORT)
					.onUnmappableCharacter(CodingErrorAction.REPORT)
					.decode(bytes)
					.toString();
		} catch (CharacterCodingException notUtf8) {
			return new String(data, start, data.length - start, Charset.forName("windows-1252"));
		}
	}

	/** RFC 4180, with the separator the header line uses most. */
	static List<List<String>> csv(String text) {
		String firstLine = text.lines().findFirst().orElse("");
		char separator = ';';
		long best = -1;
		for (char candidate : new char[] {';', ',', '\t'}) {
			long count = firstLine.chars().filter(c -> c == candidate).count();
			if (count > best) {
				best = count;
				separator = candidate;
			}
		}
		List<List<String>> rows = new ArrayList<>();
		List<String> row = new ArrayList<>();
		StringBuilder cell = new StringBuilder();
		boolean quoted = false;
		for (int i = 0; i < text.length(); i++) {
			char c = text.charAt(i);
			if (quoted) {
				if (c == '"' && i + 1 < text.length() && text.charAt(i + 1) == '"') {
					cell.append('"');
					i++;
				} else if (c == '"') {
					quoted = false;
				} else {
					cell.append(c);
				}
			} else if (c == '"' && cell.toString().isBlank()) {
				cell.setLength(0);
				quoted = true;
			} else if (c == separator) {
				row.add(cell.toString().trim());
				cell.setLength(0);
			} else if (c == '\n' || c == '\r') {
				if (c == '\r' && i + 1 < text.length() && text.charAt(i + 1) == '\n') {
					i++;
				}
				row.add(cell.toString().trim());
				cell.setLength(0);
				rows.add(row);
				row = new ArrayList<>();
			} else {
				cell.append(c);
			}
		}
		if (!cell.isEmpty() || !row.isEmpty()) {
			row.add(cell.toString().trim());
			rows.add(row);
		}
		return rows;
	}

	// ── Excel ──

	private static List<List<String>> xlsx(byte[] data) {
		Map<String, byte[]> parts = new HashMap<>();
		try (ZipInputStream zip = new ZipInputStream(new ByteArrayInputStream(data))) {
			long total = 0;
			for (ZipEntry entry; (entry = zip.getNextEntry()) != null; ) {
				String name = entry.getName();
				if (!name.endsWith(".xml") && !name.endsWith(".rels")) {
					continue;
				}
				byte[] bytes = zip.readNBytes(MAX_ENTRY_BYTES + 1);
				total += bytes.length;
				if (bytes.length > MAX_ENTRY_BYTES || total > 4L * MAX_ENTRY_BYTES) {
					throw ApiException.badRequest("import_file_too_big");
				}
				parts.put(name, bytes);
			}
		} catch (IOException e) {
			throw ApiException.badRequest("import_file_unreadable");
		}
		try {
			List<String> shared = parts.containsKey("xl/sharedStrings.xml") ? sharedStrings(parts.get("xl/sharedStrings.xml")) : List.of();
			byte[] sheet = parts.get(firstSheet(parts));
			if (sheet == null) {
				throw ApiException.badRequest("import_file_unreadable");
			}
			return sheet(sheet, shared);
		} catch (XMLStreamException | RuntimeException e) {
			if (e instanceof ApiException api) {
				throw api;
			}
			throw ApiException.badRequest("import_file_unreadable");
		}
	}

	/** The first sheet of the workbook, through its relationship; usually xl/worksheets/sheet1.xml. */
	private static String firstSheet(Map<String, byte[]> parts) throws XMLStreamException {
		String relId = null;
		if (parts.containsKey("xl/workbook.xml")) {
			XMLStreamReader xml = reader(parts.get("xl/workbook.xml"));
			while (xml.hasNext() && relId == null) {
				if (xml.next() == XMLStreamConstants.START_ELEMENT && xml.getLocalName().equals("sheet")) {
					for (int i = 0; i < xml.getAttributeCount(); i++) {
						if (xml.getAttributeLocalName(i).equals("id")) {
							relId = xml.getAttributeValue(i);
						}
					}
				}
			}
		}
		if (relId != null && parts.containsKey("xl/_rels/workbook.xml.rels")) {
			XMLStreamReader xml = reader(parts.get("xl/_rels/workbook.xml.rels"));
			while (xml.hasNext()) {
				if (xml.next() == XMLStreamConstants.START_ELEMENT && xml.getLocalName().equals("Relationship")
						&& relId.equals(xml.getAttributeValue(null, "Id"))) {
					String target = xml.getAttributeValue(null, "Target");
					if (target.startsWith("/")) {
						return target.substring(1);
					}
					return target.startsWith("xl/") ? target : "xl/" + target;
				}
			}
		}
		return "xl/worksheets/sheet1.xml";
	}

	private static List<String> sharedStrings(byte[] part) throws XMLStreamException {
		List<String> strings = new ArrayList<>();
		XMLStreamReader xml = reader(part);
		StringBuilder current = null;
		boolean inPhonetic = false;
		while (xml.hasNext()) {
			int event = xml.next();
			if (event == XMLStreamConstants.START_ELEMENT) {
				switch (xml.getLocalName()) {
					case "si" -> current = new StringBuilder();
					case "rPh" -> inPhonetic = true;
					case "t" -> {
						String t = xml.getElementText();
						if (current != null && !inPhonetic) {
							current.append(t);
						}
					}
					default -> {
					}
				}
			} else if (event == XMLStreamConstants.END_ELEMENT) {
				if (xml.getLocalName().equals("si") && current != null) {
					strings.add(current.toString());
					current = null;
				} else if (xml.getLocalName().equals("rPh")) {
					inPhonetic = false;
				}
			}
		}
		return strings;
	}

	private static List<List<String>> sheet(byte[] part, List<String> shared) throws XMLStreamException {
		List<List<String>> rows = new ArrayList<>();
		XMLStreamReader xml = reader(part);
		List<String> row = null;
		String type = null;
		int column = 0;
		String value = null;
		while (xml.hasNext()) {
			int event = xml.next();
			if (event == XMLStreamConstants.START_ELEMENT) {
				switch (xml.getLocalName()) {
					case "row" -> row = new ArrayList<>();
					case "c" -> {
						type = xml.getAttributeValue(null, "t");
						String ref = xml.getAttributeValue(null, "r");
						column = ref == null ? (row == null ? 0 : row.size()) : columnOf(ref);
						value = null;
					}
					case "v" -> value = xml.getElementText();
					case "t" -> value = (value == null ? "" : value) + xml.getElementText();
					default -> {
					}
				}
			} else if (event == XMLStreamConstants.END_ELEMENT) {
				if (xml.getLocalName().equals("c") && row != null) {
					while (row.size() < column) {
						row.add("");
					}
					row.add(cell(type, value, shared));
				} else if (xml.getLocalName().equals("row") && row != null) {
					rows.add(row);
					row = null;
				}
			}
		}
		return rows;
	}

	private static String cell(String type, String value, List<String> shared) {
		if (value == null) {
			return "";
		}
		if ("s".equals(type)) {
			int index = Integer.parseInt(value.trim());
			return index >= 0 && index < shared.size() ? shared.get(index).trim() : "";
		}
		if (type == null || "n".equals(type)) {
			try {
				return new BigDecimal(value.trim()).stripTrailingZeros().toPlainString();
			} catch (NumberFormatException e) {
				return value.trim();
			}
		}
		return value.trim();
	}

	/** "C12" → 2. */
	private static int columnOf(String ref) {
		int column = 0;
		for (char c : ref.toCharArray()) {
			if (c < 'A' || c > 'Z') {
				break;
			}
			column = column * 26 + (c - 'A' + 1);
		}
		return Math.max(0, column - 1);
	}

	private static XMLStreamReader reader(byte[] part) throws XMLStreamException {
		XMLInputFactory factory = XMLInputFactory.newFactory();
		// No DTD, no external entity: the file comes from outside.
		factory.setProperty(XMLInputFactory.SUPPORT_DTD, false);
		factory.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, false);
		InputStream in = new ByteArrayInputStream(part);
		return factory.createXMLStreamReader(in, "UTF-8");
	}
}
