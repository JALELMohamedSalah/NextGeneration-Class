import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/password/change_password_cubit.dart';
import '../../widgets/password_form.dart';
import 'welcome_layout.dart';

/// First login with a temporary password: the user chooses their own before going further.
class ChoosePasswordScreen extends StatelessWidget {
  const ChoosePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return BlocProvider(
      create: (_) => sl.get<ChangePasswordCubit>(),
      child: WelcomeLayout(
        form: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state.done) context.read<AuthCubit>().passwordChanged();
          },
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeTitle(overline: l10n.firstLoginOverline, title: l10n.mustChangePasswordTitle, message: l10n.mustChangePasswordMessage),
              const SizedBox(height: 20),
              PasswordForm(
                currentLabel: l10n.temporaryPassword,
                currentHint: l10n.temporaryPasswordHint,
                submitting: state.submitting,
                failure: state.failure,
                onSubmit: (current, next) => context.read<ChangePasswordCubit>().submit(currentPassword: current, newPassword: next),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  icon: const Icon(LucideIcons.logOutDir, size: 18, color: BrandColors.body),
                  label: Text(l10n.logout, style: text.style(14, FontWeight.w700, color: BrandColors.body)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
