import 'package:flutter/material.dart';

import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/brand_wordmark.dart';

/// Shown while the saved session is restored at start: the wordmark and a thin line, no spinner.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.chalk,
      body: Center(
        child: Semantics(
          label: AppLocalizations.of(context).loading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandWordmark(),
              const SizedBox(height: 28),
              SizedBox(
                width: 160,
                child: ClipRRect(borderRadius: BorderRadius.circular(2), child: const LinearProgressIndicator(minHeight: 4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
