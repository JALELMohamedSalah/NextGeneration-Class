import 'package:url_launcher/url_launcher.dart';

/// Opens a web link (Meet) in the browser or the app that handles it.
abstract interface class LinkOpener {
  Future<bool> open(String url);
}

class UrlLauncherLinkOpener implements LinkOpener {
  @override
  Future<bool> open(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return Future.value(false);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
