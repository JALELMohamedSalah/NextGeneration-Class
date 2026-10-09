package com.ngclass.backend.common;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * A refusal with a stable code. The message shown to the user is never written here: it is
 * {@code error.<code>} in i18n/messages*.properties, in the language of the request.
 */
@Getter
public class ApiException extends RuntimeException {
	private final HttpStatus status;
	private final String code;
	private final transient Object[] args;

	public ApiException(HttpStatus status, String code, Object... args) {
		super(code);
		this.status = status;
		this.code = code;
		this.args = args;
	}

	public static ApiException notFound(String code) {
		return new ApiException(HttpStatus.NOT_FOUND, code);
	}

	public static ApiException badRequest(String code, Object... args) {
		return new ApiException(HttpStatus.BAD_REQUEST, code, args);
	}
}
