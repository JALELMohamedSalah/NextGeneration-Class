import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../domain/model/content.dart';

/// Spec 04: a photo is made lighter on the device before upload (longest side 1600 px, JPEG quality
/// 75). PDFs, Word files and small images are sent as they are.
Future<PickedFile> shrinkPhoto(PickedFile file) async {
  const light = 600 * 1024;
  if (!{'jpg', 'jpeg', 'png'}.contains(file.extension) || file.size <= light) return file;
  final bytes = await compute(_shrink, Uint8List.fromList(file.bytes));
  if (bytes == null || bytes.length >= file.size) return file;
  final dot = file.name.lastIndexOf('.');
  return PickedFile(name: '${dot > 0 ? file.name.substring(0, dot) : file.name}.jpg', bytes: bytes);
}

Uint8List? _shrink(Uint8List input) {
  final image = img.decodeImage(input);
  if (image == null) return null;
  const longest = 1600;
  final resized = image.width >= image.height
      ? (image.width > longest ? img.copyResize(image, width: longest) : image)
      : (image.height > longest ? img.copyResize(image, height: longest) : image);
  return img.encodeJpg(resized, quality: 75);
}
