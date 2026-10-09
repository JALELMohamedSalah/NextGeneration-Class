import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// The fonts of a printed page: the app's (Plus Jakarta Sans), with IBM Plex Sans Arabic for Arabic text.
class PdfFonts {
  const PdfFonts({required this.regular, required this.bold, this.fallback = const []});

  final pw.Font regular;
  final pw.Font bold;
  final List<pw.Font> fallback;
}

/// Prints a PDF made on the device: the browser's print window on a computer, the system one on a phone
/// (where it can also be saved or shared).
abstract interface class DocumentPrinter {
  /// [arabic]: the Arabic font first.
  Future<PdfFonts> fonts({required bool arabic});

  Future<void> printPdf(String name, Future<Uint8List> Function(PdfPageFormat format) build);
}

class PrintingDocumentPrinter implements DocumentPrinter {
  @override
  Future<PdfFonts> fonts({required bool arabic}) async {
    final arabicRegular = await PdfGoogleFonts.iBMPlexSansArabicRegular();
    final arabicBold = await PdfGoogleFonts.iBMPlexSansArabicBold();
    if (arabic) return PdfFonts(regular: arabicRegular, bold: arabicBold);
    return PdfFonts(
      regular: await PdfGoogleFonts.plusJakartaSansRegular(),
      bold: await PdfGoogleFonts.plusJakartaSansBold(),
      fallback: [arabicRegular],
    );
  }

  @override
  Future<void> printPdf(String name, Future<Uint8List> Function(PdfPageFormat format) build) =>
      Printing.layoutPdf(name: name, onLayout: build);
}
