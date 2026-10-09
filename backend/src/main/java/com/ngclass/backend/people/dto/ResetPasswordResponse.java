package com.ngclass.backend.people.dto;

import java.util.UUID;

/** Shown once to the teacher, who sends it to the student or parent through her usual channel. */
public record ResetPasswordResponse(UUID userId, String username, String temporaryPassword) {
}
