package com.ngclass.backend.config;

import java.util.List;
import java.util.Locale;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver;

@Configuration
public class I18nConfig {
	public static final Locale FRENCH = Locale.FRENCH;
	public static final Locale ARABIC = Locale.forLanguageTag("ar");

	/** The app sends Accept-Language (fr or ar) with every request; anything else falls back to French. */
	@Bean
	public LocaleResolver localeResolver() {
		AcceptHeaderLocaleResolver resolver = new AcceptHeaderLocaleResolver();
		resolver.setSupportedLocales(List.of(FRENCH, ARABIC));
		resolver.setDefaultLocale(FRENCH);
		return resolver;
	}
}
