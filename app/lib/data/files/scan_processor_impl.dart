import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/model/content.dart';
import '../../domain/model/scan.dart';
import '../../domain/services/scan_processor.dart';

/// Image work runs in a background isolate on phones (on the web, `compute` runs it in place).
class ScanProcessorImpl implements ScanProcessor {
  @override
  Future<ScanPage?> load(String id, Uint8List photo) async {
    final loaded = await compute(_load, photo);
    if (loaded == null) return null;
    return ScanPage(id: id, bytes: loaded.$1, width: loaded.$2, height: loaded.$3, preview: loaded.$4);
  }

  @override
  Future<ScanPage> refresh(ScanPage page) async {
    final preview = await compute(_pagePreview, _Job.of(page, ScanColor.color, 500));
    return page.copyWith(preview: preview);
  }

  @override
  Future<PickedFile> buildPdf(List<ScanPage> pages, ScanColor color, String fileName) async {
    final bytes = await compute(_pdf, [for (final p in pages) _Job.of(p, color, 1600)]);
    return PickedFile(name: fileName, bytes: bytes);
  }
}

/// What an isolate needs to draw one page.
class _Job {
  const _Job(this.bytes, this.quarterTurns, this.corners, this.blackWhite, this.maxSide);

  factory _Job.of(ScanPage page, ScanColor color, int maxSide) =>
      _Job(page.bytes, page.quarterTurns, [for (final c in page.corners) (c.x, c.y)], color == ScanColor.blackWhite, maxSide);

  final Uint8List bytes;
  final int quarterTurns;
  final List<(double, double)> corners;
  final bool blackWhite;
  final int maxSide;
}

/// Upright (the camera's orientation applied), at most 2200 px, re-encoded; and a preview.
(Uint8List, int, int, Uint8List)? _load(Uint8List photo) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(photo);
  } on Object {
    // Not a picture (or a broken one): refused, not a crash.
    return null;
  }
  if (decoded == null) return null;
  final upright = _fit(img.bakeOrientation(decoded), 2200);
  return (img.encodeJpg(upright, quality: 90), upright.width, upright.height, img.encodeJpg(_fit(upright, 500), quality: 70));
}

Uint8List _pagePreview(_Job job) => img.encodeJpg(_page(job), quality: 70);

Future<Uint8List> _pdf(List<_Job> jobs) async {
  final doc = pw.Document(title: 'NG Class scan');
  for (final job in jobs) {
    final page = _page(job);
    final jpeg = img.encodeJpg(page, quality: 75);
    final format = page.width > page.height ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(18),
        build: (_) => pw.Center(child: pw.Image(pw.MemoryImage(jpeg), fit: pw.BoxFit.contain)),
      ),
    );
  }
  return doc.save();
}

/// Turned, straightened to its corners, reduced, and in black and white when asked.
img.Image _page(_Job job) {
  var image = img.decodeImage(job.bytes)!;
  if (job.quarterTurns != 0) image = img.copyRotate(image, angle: 90 * job.quarterTurns);
  final full = job.corners.every((c) => (c.$1 == 0 || c.$1 == 1) && (c.$2 == 0 || c.$2 == 1));
  if (!full) {
    final p = [for (final c in job.corners) img.Point(c.$1 * (image.width - 1), c.$2 * (image.height - 1))];
    double d(img.Point a, img.Point b) => math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
    final width = math.max(d(p[0], p[1]), d(p[3], p[2])).round().clamp(1, 4000);
    final height = math.max(d(p[0], p[3]), d(p[1], p[2])).round().clamp(1, 4000);
    image = img.copyRectify(
      image,
      topLeft: p[0],
      topRight: p[1],
      bottomRight: p[2],
      bottomLeft: p[3],
      interpolation: img.Interpolation.linear,
      toImage: img.Image(width: width, height: height),
    );
  }
  image = _fit(image, job.maxSide);
  if (job.blackWhite) image = img.contrast(img.grayscale(image), contrast: 140);
  return image;
}

img.Image _fit(img.Image image, int maxSide) {
  if (image.width <= maxSide && image.height <= maxSide) return image;
  return image.width >= image.height
      ? img.copyResize(image, width: maxSide, interpolation: img.Interpolation.average)
      : img.copyResize(image, height: maxSide, interpolation: img.Interpolation.average);
}
