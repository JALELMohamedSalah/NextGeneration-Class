import 'dart:typed_data';

import '../model/content.dart';
import '../model/scan.dart';

/// Turns photos of sheets into pages, and pages into one PDF, on the device (spec 04): nothing is sent
/// before the teacher imports the PDF.
abstract interface class ScanProcessor {
  /// A photo as taken: upright, at most 2200 px, with its preview. Null when it cannot be read.
  Future<ScanPage?> load(String id, Uint8List photo);

  /// The page's preview after a crop or a turn.
  Future<ScanPage> refresh(ScanPage page);

  /// One A4 page per photo, straightened, at most 1600 px, JPEG quality 75.
  Future<PickedFile> buildPdf(List<ScanPage> pages, ScanColor color, String fileName);
}
