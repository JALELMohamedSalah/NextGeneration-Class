import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Photos for a scan: the camera, or pictures already taken.
abstract interface class PhotoSource {
  /// Phones and tablets have a camera; on a computer the teacher adds photos already taken.
  bool get hasCamera;

  /// Null when the user closed the camera.
  Future<Uint8List?> takePhoto();

  /// Empty when the user chose nothing.
  Future<List<Uint8List>> pickPhotos();
}

class ImagePickerPhotoSource implements PhotoSource {
  final _picker = ImagePicker();

  @override
  bool get hasCamera => defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  // The phone makes the photo lighter itself; the page is reduced again in the PDF.
  static const _side = 2200.0;

  @override
  Future<Uint8List?> takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: _side, maxHeight: _side, imageQuality: 90);
    return photo?.readAsBytes();
  }

  @override
  Future<List<Uint8List>> pickPhotos() async {
    final photos = await _picker.pickMultiImage(maxWidth: _side, maxHeight: _side, imageQuality: 90);
    return [for (final p in photos) await p.readAsBytes()];
  }
}
