import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/formatting.dart';
import '../../core/l10n/tunis_time.dart';
import '../../core/theme/brand_colors.dart';
import '../../domain/model/content.dart';
import '../../l10n/app_localizations.dart';
import 'cards.dart';

String tagLabel(AppLocalizations l10n, ContentTag tag) => switch (tag) {
  ContentTag.serie => l10n.tagSerie,
  ContentTag.cours => l10n.tagCours,
  ContentTag.corrige => l10n.tagCorrige,
  ContentTag.autre => l10n.tagAutre,
};

Accent tagAccent(ContentTag tag) => switch (tag) {
  ContentTag.serie => Accent.indigo,
  ContentTag.cours => Accent.turquoise,
  ContentTag.corrige => Accent.violet,
  ContentTag.autre => Accent.grey,
};

String kindLabel(AppLocalizations l10n, FileKind kind) => switch (kind) {
  FileKind.pdf => l10n.kindPdf,
  FileKind.image => l10n.kindImage,
  FileKind.word => l10n.kindWord,
};

/// "640 Ko", "1,2 Mo": a comma for decimals, as written in Tunisia.
String fileSize(AppLocalizations l10n, int bytes) {
  if (bytes < 1024 * 1024) return l10n.sizeKb('${(bytes / 1024).ceil()}');
  final mb = bytes / (1024 * 1024);
  final text = mb >= 10 ? mb.round().toString() : mb.toStringAsFixed(1).replaceAll('.', ',');
  return l10n.sizeMb(text);
}

/// "PDF · 3 pages · 1,2 Mo", "Photo · 380 Ko", "Word · 96 Ko · à télécharger".
String documentDetail(AppLocalizations l10n, ContentDocument document) => [
  kindLabel(l10n, document.kind),
  if (document.kind == FileKind.pdf && document.pageCount != null) l10n.pagesCount(document.pageCount!),
  fileSize(l10n, document.sizeBytes),
  if (document.kind == FileKind.word) l10n.toDownload,
].join(l10n.dotSeparator);

/// For pupils and parents: "Série · 3 pages", "Photo", "Word · à télécharger".
String sharedDetail(AppLocalizations l10n, SharedDocument document) => [
  if (document.kind == FileKind.image) l10n.kindImage else tagLabel(l10n, document.tag),
  if (document.kind == FileKind.pdf && document.pageCount != null) l10n.pagesCount(document.pageCount!),
  if (document.kind == FileKind.word) l10n.toDownload,
].join(l10n.dotSeparator);

/// "10:24" today, "Hier", then "28 sept.".
String editedLabel(AppLocalizations l10n, AppLanguage language, DateTime instant, DateTime now) {
  final day = TunisTime.wall(instant);
  final today = TunisTime.wall(now);
  if (TunisTime.sameDay(day, today)) return hm(instant);
  if (TunisTime.sameDay(day, TunisTime.addDays(today, -1))) return l10n.yesterday;
  return shortDate(day, language);
}

/// The file type as an icon badge: red PDF, turquoise photo, blue Word.
class KindBadge extends StatelessWidget {
  const KindBadge({super.key, required this.kind, this.size = IconBadgeSize.large});

  final FileKind kind;
  final IconBadgeSize size;

  @override
  Widget build(BuildContext context) => IconBadge(
    icon: switch (kind) {
      FileKind.pdf => LucideIcons.fileText,
      FileKind.image => LucideIcons.image,
      FileKind.word => LucideIcons.fileType,
    },
    accent: switch (kind) {
      FileKind.pdf => Accent.red,
      FileKind.image => Accent.turquoise,
      FileKind.word => Accent.blue,
    },
    size: size,
  );
}

class TagChip extends StatelessWidget {
  const TagChip(this.tag, {super.key});

  final ContentTag tag;

  @override
  Widget build(BuildContext context) => StatusChip(label: tagLabel(AppLocalizations.of(context), tag), accent: tagAccent(tag));
}

class DocumentStatusChip extends StatelessWidget {
  const DocumentStatusChip(this.status, {super.key});

  final ContentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return status == ContentStatus.published
        ? StatusChip(label: l10n.statusPublished, accent: Accent.green)
        : StatusChip(label: l10n.statusDraft, accent: Accent.grey);
  }
}
