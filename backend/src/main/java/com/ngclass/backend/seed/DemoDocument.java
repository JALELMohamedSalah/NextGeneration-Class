package com.ngclass.backend.seed;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts.FontName;

/** A two-page worksheet drawn on the fly, so the dev library and Cours have a real PDF to open. */
final class DemoDocument {
	private DemoDocument() {
	}

	static byte[] fractionsSeries() {
		try (PDDocument pdf = new PDDocument(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
			PDType1Font bold = new PDType1Font(FontName.HELVETICA_BOLD);
			PDType1Font regular = new PDType1Font(FontName.HELVETICA);
			String[][] pages = {
					{"Série 1 : les fractions", "Exercice 1", "Écris la fraction coloriée : un disque coupé en 4, 1 part coloriée.",
							"Exercice 2", "Range du plus petit au plus grand : 3/4 ; 1/4 ; 2/4."},
					{"Série 1 : les fractions (suite)", "Exercice 3", "Sami mange 2/8 d'une pizza. Quelle part reste-t-il ?",
							"Exercice 4", "Colorie 3/5 d'une bande de 5 cases."}};
			for (String[] lines : pages) {
				PDPage page = new PDPage(PDRectangle.A4);
				pdf.addPage(page);
				try (PDPageContentStream text = new PDPageContentStream(pdf, page)) {
					float y = 760;
					text.beginText();
					text.setFont(regular, 10);
					text.newLineAtOffset(60, 800);
					text.showText("4ème année · Mathématiques");
					text.endText();
					for (int i = 0; i < lines.length; i++) {
						boolean title = i == 0;
						boolean heading = !title && i % 2 == 1;
						text.beginText();
						text.setFont(title || heading ? bold : regular, title ? 22 : heading ? 14 : 12);
						text.newLineAtOffset(60, y);
						text.showText(lines[i]);
						text.endText();
						y -= title ? 50 : heading ? 24 : 70;
					}
				}
			}
			pdf.save(out);
			return out.toByteArray();
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}
}
