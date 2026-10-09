package com.ngclass.backend.common;

import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Component;

/** Builds {@link ApiError}s with their message in the request's language (fr or ar). */
@Component
@RequiredArgsConstructor
public class ApiMessages {
	private final MessageSource messageSource;

	public ApiError error(String code, Object details, Object... args) {
		return error(LocaleContextHolder.getLocale(), code, details, args);
	}

	public ApiError error(Locale locale, String code, Object details, Object... args) {
		String message = messageSource.getMessage("error." + code, args, null, locale);
		if (message == null) {
			message = messageSource.getMessage("error.internal", null, locale);
		}
		return new ApiError(code, message, details);
	}
}
