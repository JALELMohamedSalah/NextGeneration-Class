import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/language_store.dart';

/// The interface language of this device. Starts from the device language, then the saved choice.
class LanguageCubit extends Cubit<AppLanguage> {
  LanguageCubit(this._store, {AppLanguage? initial}) : super(initial ?? AppLanguage.fromDevice());

  final LanguageStore _store;

  Future<void> load() async {
    final saved = await _store.read();
    if (saved != null) emit(saved);
  }

  Future<void> change(AppLanguage language) async {
    if (language == state) return;
    emit(language);
    await _store.save(language);
  }
}
