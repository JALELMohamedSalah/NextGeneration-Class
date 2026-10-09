/// Same rule as the server: at least 8 characters, with a letter (any script) and a digit.
final _policy = RegExp(r'^(?=.*\p{L})(?=.*\d).{8,}$', unicode: true);

bool isAcceptablePassword(String? password) => password != null && _policy.hasMatch(password);
