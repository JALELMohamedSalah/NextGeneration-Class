import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/platform/document_printer.dart';

/// One card to cut out and hand over, its words already in the teacher's language.
class PrintedCard {
  const PrintedCard({
    required this.title,
    required this.subtitle,
    required this.usernameLabel,
    required this.username,
    required this.passwordLabel,
    required this.password,
    required this.help,
  });

  final String title;
  final String subtitle;
  final String usernameLabel;
  final String username;
  final String passwordLabel;
  final String password;
  final String help;
}

/// The login details of an import (design `r2/ImportElevesIdentifiants.png`, "Imprimer"): two cards a row with dashed
/// edges to cut along, as many pages as needed. Identifiers and passwords stay left to right in Arabic too.
Future<Uint8List> credentialCardsPdf({
  required PdfPageFormat format,
  required List<PrintedCard> cards,
  required PdfFonts fonts,
  required bool rtl,
  required String brand,
}) async {
  const indigo = PdfColor.fromInt(0xFF2B3990);
  const slate = PdfColor.fromInt(0xFF6B7090);
  const chalk = PdfColor.fromInt(0xFFF6F7FB);
  final document = pw.Document(theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold, fontFallback: fonts.fallback));
  final direction = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  pw.Widget box(String label, String value) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(color: chalk, borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: slate)),
          pw.SizedBox(height: 2),
          pw.Text(value, textDirection: pw.TextDirection.ltr, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, letterSpacing: 0.6)),
        ],
      ),
    ),
  );

  pw.Widget card(PrintedCard c) => pw.Container(
    width: (format.availableWidth - 12) / 2,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: slate, width: 0.6, style: pw.BorderStyle.dashed),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(brand, style: pw.TextStyle(fontSize: 8, color: indigo, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(c.title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text(c.subtitle, style: const pw.TextStyle(fontSize: 8, color: slate)),
        pw.SizedBox(height: 8),
        pw.Row(children: [box(c.usernameLabel, c.username), pw.SizedBox(width: 6), box(c.passwordLabel, c.password)]),
        pw.SizedBox(height: 8),
        pw.Text(c.help, style: const pw.TextStyle(fontSize: 8, color: slate)),
      ],
    ),
  );

  document.addPage(
    pw.MultiPage(
      pageFormat: format,
      textDirection: direction,
      build: (_) => [
        pw.Wrap(spacing: 12, runSpacing: 12, children: [for (final c in cards) card(c)]),
      ],
    ),
  );
  return document.save();
}
