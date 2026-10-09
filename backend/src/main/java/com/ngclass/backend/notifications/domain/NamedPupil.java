package com.ngclass.backend.notifications.domain;

import java.util.UUID;

/** A pupil named in a teacher's notification, as written then. */
public record NamedPupil(UUID id, String firstName, String lastName) {
}
