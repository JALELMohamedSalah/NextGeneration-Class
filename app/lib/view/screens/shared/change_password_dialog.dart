import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/password/change_password_cubit.dart';
import '../../widgets/password_form.dart';

Future<void> showChangePasswordDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider(create: (_) => sl.get<ChangePasswordCubit>(), child: const _ChangePasswordDialog()),
  );
}

class _ChangePasswordDialog extends StatelessWidget {
  const _ChangePasswordDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (!state.done) return;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
      },
      builder: (context, state) => AlertDialog(
        title: Text(l10n.changePassword),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: PasswordForm(
              currentLabel: l10n.currentPassword,
              currentHint: l10n.currentPasswordHint,
              submitting: state.submitting,
              failure: state.failure,
              onCancel: () => Navigator.of(context).pop(),
              onSubmit: (current, next) => context.read<ChangePasswordCubit>().submit(currentPassword: current, newPassword: next),
            ),
          ),
        ),
      ),
    );
  }
}
