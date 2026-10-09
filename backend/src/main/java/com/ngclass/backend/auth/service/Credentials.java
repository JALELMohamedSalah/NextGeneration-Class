package com.ngclass.backend.auth.service;

import java.security.SecureRandom;
import java.util.Locale;
import java.util.Optional;
import java.util.regex.Pattern;

/** Login identifiers, password policy and temporary passwords, in one place. */
public final class Credentials {
	private static final Pattern PASSWORD_POLICY = Pattern.compile("^(?=.*\\p{L})(?=.*\\d).{8,}$");
	private static final Pattern TUNISIAN_PHONE = Pattern.compile("\\d{8}");
	// No look-alike characters (l, 1, o, 0, i): temporary passwords are copied by hand.
	private static final String LETTERS = "abcdefghjkmnpqrstuvwxyz";
	private static final String DIGITS = "23456789";
	private static final SecureRandom RANDOM = new SecureRandom();

	private Credentials() {
	}

	/** "+216 20 000 001", "20.000.001" and "20000001" all give "20000001"; anything else is not a phone. */
	public static Optional<String> phoneDigits(String login) {
		String compact = login.replaceAll("[\\s.\\-]", "");
		if (compact.startsWith("+216")) {
			compact = compact.substring(4);
		} else if (compact.startsWith("00216")) {
			compact = compact.substring(5);
		}
		return TUNISIAN_PHONE.matcher(compact).matches() ? Optional.of(compact) : Optional.empty();
	}

	public static String normalizeUsername(String username) {
		return username.trim().toLowerCase(Locale.ROOT);
	}

	/** At least 8 characters with a letter (any script) and a digit. */
	public static boolean isAcceptablePassword(String password) {
		return password != null && PASSWORD_POLICY.matcher(password).matches();
	}

	/** Six letters then four digits, e.g. "kprate4827": meets the policy and is easy to dictate. */
	public static String temporaryPassword() {
		StringBuilder out = new StringBuilder(10);
		for (int i = 0; i < 6; i++) {
			out.append(LETTERS.charAt(RANDOM.nextInt(LETTERS.length())));
		}
		for (int i = 0; i < 4; i++) {
			out.append(DIGITS.charAt(RANDOM.nextInt(DIGITS.length())));
		}
		return out.toString();
	}
}
