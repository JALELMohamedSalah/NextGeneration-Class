import 'package:url_launcher/url_launcher.dart';

/// Opens a document's signed download link: the browser (or the phone) downloads it.
abstract interface class FileOpener {
  Future<bool> download(String url);
}

class UrlLauncherFileOpener implements FileOpener {
  @override
  Future<bool> download(String url) {
    final uri = Uri.tryParse(url);
    // Signed links of our own API only: https in production, http on a local development server.
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) return Future.value(false);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
