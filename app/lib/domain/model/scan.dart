import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A point on a page photo, from 0 to 1 across and down (left to right, as the photo is).
class ScanPoint extends Equatable {
  const ScanPoint(this.x, this.y);

  final double x;
  final double y;

  ScanPoint clamped() => ScanPoint(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));

  /// A quarter turn clockwise of the photo, kept to a millionth so four turns come back exactly.
  ScanPoint turned() => ScanPoint(_round(1 - y), _round(x));

  static double _round(double v) => (v * 1e6).roundToDouble() / 1e6;

  @override
  List<Object?> get props => [x, y];
}

/// Colour, or black and white: sharper sheets and a lighter file. One choice for the whole PDF.
enum ScanColor { color, blackWhite }

/// A photographed sheet (design `r2/Scanner.png`). [corners] are the sheet's corners on the photo turned by
/// [quarterTurns] (top left, top right, bottom right, bottom left): the page is straightened to them.
class ScanPage extends Equatable {
  const ScanPage({
    required this.id,
    required this.bytes,
    required this.width,
    required this.height,
    required this.preview,
    this.quarterTurns = 0,
    this.corners = full,
  });

  static const full = [ScanPoint(0, 0), ScanPoint(1, 0), ScanPoint(1, 1), ScanPoint(0, 1)];

  final String id;

  /// The photo, upright as taken (orientation already applied), at most 2200 px.
  final Uint8List bytes;
  final int width;
  final int height;

  /// The page as it will be in the PDF, small, in colour.
  final Uint8List preview;
  final int quarterTurns;
  final List<ScanPoint> corners;

  /// Width over height of the photo once turned.
  double get turnedAspect => quarterTurns.isOdd ? height / width : width / height;

  bool get edited => quarterTurns != 0 || corners != full;

  /// A quarter turn clockwise: the corners turn with the photo.
  ScanPage rotated() {
    final c = corners;
    return copyWith(quarterTurns: (quarterTurns + 1) % 4, corners: [c[3].turned(), c[0].turned(), c[1].turned(), c[2].turned()]);
  }

  ScanPage withCorner(int index, ScanPoint point) =>
      copyWith(corners: [for (var i = 0; i < 4; i++) i == index ? point.clamped() : corners[i]]);

  /// Back to the photo as taken.
  ScanPage reset() => copyWith(quarterTurns: 0, corners: full);

  ScanPage copyWith({int? quarterTurns, List<ScanPoint>? corners, Uint8List? preview}) => ScanPage(
    id: id,
    bytes: bytes,
    width: width,
    height: height,
    preview: preview ?? this.preview,
    quarterTurns: quarterTurns ?? this.quarterTurns,
    corners: corners ?? this.corners,
  );

  @override
  List<Object?> get props => [id, width, height, quarterTurns, corners, preview.length];
}
