import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/student.dart';
import '../../../domain/model/teacher_account.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/admin/teachers_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/feedback.dart';
import '../../widgets/panels.dart';
import '../../widgets/text_field.dart';

/// "Nouvel enseignant": name, username (made from the name until the owner types one), optional phone
/// and email. Returns the login details to show once, or null when cancelled.
class NewTeacherPanel extends StatefulWidget {
  const NewTeacherPanel({super.key});

  static Future<NewAccount?> open(BuildContext context) {
    final cubit = context.read<TeachersCubit>();
    return showSidePanel<NewAccount>(
      context,
      builder: (_) => BlocProvider.value(value: cubit, child: const NewTeacherPanel()),
    );
  }

  @override
  State<NewTeacherPanel> createState() => _NewTeacherPanelState();
}

enum _Field { firstName, lastName, username, phone }

class _NewTeacherPanelState extends State<NewTeacherPanel> {
  static final _usernamePattern = RegExp(r'^[a-z0-9][a-z0-9._-]{2,63}$');

  String _firstName = '';
  String _lastName = '';
  String _username = '';
  bool _usernameTyped = false;
  String _phone = '';
  String _email = '';
  Set<_Field> _errors = {};
  bool _submitting = false;
  ApiFailure? _failure;

  void _nameChanged({String? first, String? last}) {
    setState(() {
      _firstName = first ?? _firstName;
      _lastName = last ?? _lastName;
      if (!_usernameTyped) _username = usernameFrom(_firstName, _lastName);
      _errors = {};
    });
  }

  Set<_Field> _validate() => {
    if (_firstName.trim().isEmpty) _Field.firstName,
    if (_lastName.trim().isEmpty) _Field.lastName,
    if (!_usernamePattern.hasMatch(_username.trim().toLowerCase())) _Field.username,
    if (_phone.trim().isNotEmpty && _phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^216'), '').length != 8) _Field.phone,
  };

  Future<void> _submit() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final (credential, failure) = await context.read<TeachersCubit>().create(
      TeacherDraft(firstName: _firstName, lastName: _lastName, username: _username, phone: _phone, email: _email),
    );
    if (!mounted) return;
    if (credential != null) {
      Navigator.of(context).pop(credential);
    } else {
      setState(() {
        _submitting = false;
        _failure = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SidePanel(
      icon: LucideIcons.userPlus,
      title: l10n.newTeacher,
      subtitle: l10n.newTeacherSubtitle,
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(label: l10n.createTeacherAccount, height: 44, loading: _submitting, onPressed: _submit),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_failure != null) ...[FailureBanner(_failure!), const SizedBox(height: 20)],
          FormInput(
            label: l10n.firstName,
            hint: l10n.teacherFirstNameHint,
            autofocus: true,
            textInputAction: TextInputAction.next,
            errorText: _errors.contains(_Field.firstName) ? l10n.fieldRequired : null,
            onChanged: (v) => _nameChanged(first: v),
          ),
          const SizedBox(height: 16),
          FormInput(
            label: l10n.lastName,
            hint: l10n.teacherLastNameHint,
            textInputAction: TextInputAction.next,
            errorText: _errors.contains(_Field.lastName) ? l10n.fieldRequired : null,
            onChanged: (v) => _nameChanged(last: v),
          ),
          const SizedBox(height: 16),
          FormInput(
            label: l10n.username,
            hint: l10n.teacherUsernameExample,
            icon: LucideIcons.atSign,
            initialValue: _username,
            textDirection: TextDirection.ltr,
            helper: l10n.teacherUsernameHint,
            errorText: _errors.contains(_Field.username) ? l10n.usernameRule : null,
            onChanged: (v) => setState(() {
              _username = v;
              _usernameTyped = v.isNotEmpty;
              _errors = {};
            }),
          ),
          const SizedBox(height: 16),
          FormInput(
            label: l10n.phone,
            labelSuffix: l10n.optional,
            hint: l10n.phoneHint,
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            errorText: _errors.contains(_Field.phone) ? l10n.phoneInvalid : null,
            onChanged: (v) => setState(() {
              _phone = v;
              _errors = {};
            }),
          ),
          const SizedBox(height: 16),
          FormInput(
            label: l10n.email,
            labelSuffix: l10n.optional,
            hint: l10n.emailHint,
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            onChanged: (v) => _email = v,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          InfoNote(text: l10n.teacherCredentialsNote, icon: LucideIcons.lock),
        ],
      ),
    );
  }
}

/// "Sonia Ben Ali" gives "sonia.benali": no accents, no spaces, as the server expects.
String usernameFrom(String firstName, String lastName) {
  String slug(String text) {
    const from = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿ';
    const to = 'aaaaaceeeeiiiinooooouuuuyy';
    final out = StringBuffer();
    for (final char in text.toLowerCase().split('')) {
      final i = from.indexOf(char);
      final plain = i < 0 ? char : to[i];
      if (RegExp(r'[a-z0-9]').hasMatch(plain)) out.write(plain);
    }
    return out.toString();
  }

  final first = slug(firstName);
  final last = slug(lastName);
  if (first.isEmpty && last.isEmpty) return '';
  return [first, last].where((part) => part.isNotEmpty).join('.');
}
