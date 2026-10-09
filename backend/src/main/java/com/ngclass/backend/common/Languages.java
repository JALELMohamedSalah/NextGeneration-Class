package com.ngclass.backend.common;

import java.util.Locale;
import java.util.Set;

/** The two languages of the product. */
public final class Languages {
	public static final String FRENCH = "fr";
	public static final String ARABIC = "ar";
	public static final Set<String> SUPPORTED = Set.of(FRENCH, ARABIC);

	private Languages() {
	}

	public static boolean isSupported(String language) {
		return language != null && SUPPORTED.contains(language);
	}

	/** The request's language (resolved from Accept-Language), French when it is anything else. */
	public static String of(Locale locale) {
		return locale != null && ARABIC.equals(locale.getLanguage()) ? ARABIC : FRENCH;
	}
}
