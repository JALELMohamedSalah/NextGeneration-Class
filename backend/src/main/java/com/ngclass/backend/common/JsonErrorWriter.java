package com.ngclass.backend.common;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.LocaleResolver;

/**
 * Writes an {@link ApiError} from the security filter chain, which runs before Spring MVC
 * has resolved the request's language: the locale is resolved here from Accept-Language.
 */
@Component
@RequiredArgsConstructor
public class JsonErrorWriter {
	private final ObjectMapper objectMapper;
	private final ApiMessages messages;
	private final LocaleResolver localeResolver;

	public void write(HttpServletRequest request, HttpServletResponse response, HttpStatus status, String code)
			throws IOException {
		ApiError error = messages.error(localeResolver.resolveLocale(request), code, null);
		response.setStatus(status.value());
		response.setCharacterEncoding(StandardCharsets.UTF_8.name());
		response.setContentType(MediaType.APPLICATION_JSON_VALUE);
		objectMapper.writeValue(response.getWriter(), error);
	}
}
