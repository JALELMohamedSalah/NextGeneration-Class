package com.ngclass.backend.auth.service;

import com.ngclass.backend.auth.domain.Role;
import java.util.UUID;

/** The principal of an authenticated request, read from the access token. */
public record AuthenticatedUser(UUID id, Role role, String username) {
}
