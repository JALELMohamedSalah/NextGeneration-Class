package com.ngclass.backend.common;

/**
 * The one error format of the API (docs/03-conception/06-API_OUTLINE.md): a stable code for the app,
 * a French message ready to show, and optional details (for example field errors).
 */
public record ApiError(String code, String message, Object details) {
}
