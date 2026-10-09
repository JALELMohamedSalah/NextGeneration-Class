package com.ngclass.backend.people.controller;

import java.nio.charset.StandardCharsets;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * "Télécharger le modèle" of the pupils' import: a CSV that Excel opens as it is (UTF-8 with its mark, semicolons),
 * headers in the teacher's language and one example line. Nothing personal in it: open to everyone, so a plain link
 * downloads it on a computer or a phone.
 */
@RestController
public class ImportTemplateController {
	private static final String FR = """
			Prénom;Nom;Niveau;Groupe;Prénom du parent;Nom du parent;Téléphone du parent\r
			Yassine;Ben Ali;4ème année;4ème année · Maths;Sonia;Ben Ali;22345678\r
			""";
	private static final String AR = """
			الاسم;اللقب;المستوى;المجموعة;اسم الولي;لقب الولي;هاتف الولي\r
			ياسين;بن علي;السنة الرابعة;;سنية;بن علي;22345678\r
			""";

	@GetMapping("/api/v1/students/import/template")
	public ResponseEntity<byte[]> template(@RequestParam(defaultValue = "fr") String lang) {
		boolean arabic = "ar".equals(lang);
		byte[] text = (arabic ? AR : FR).getBytes(StandardCharsets.UTF_8);
		byte[] body = new byte[text.length + 3];
		body[0] = (byte) 0xEF;
		body[1] = (byte) 0xBB;
		body[2] = (byte) 0xBF;
		System.arraycopy(text, 0, body, 3, text.length);
		return ResponseEntity.ok()
				.contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
				.header(HttpHeaders.CONTENT_DISPOSITION,
						ContentDisposition.attachment().filename(arabic ? "namudhaj-talamidh.csv" : "modele-eleves.csv").build().toString())
				.body(body);
	}
}
