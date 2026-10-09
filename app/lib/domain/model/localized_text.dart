import 'package:equatable/equatable.dart';

import '../../core/l10n/app_language.dart';

/// Data stored in both languages (subject and level names...). Falls back to French when
/// the Arabic text is missing.
class LocalizedText extends Equatable {
  const LocalizedText({required this.fr, required this.ar});

  final String fr;
  final String ar;

  String of(AppLanguage language) => language == AppLanguage.ar && ar.isNotEmpty ? ar : fr;

  @override
  List<Object?> get props => [fr, ar];
}
