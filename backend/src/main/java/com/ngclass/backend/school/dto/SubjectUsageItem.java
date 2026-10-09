package com.ngclass.backend.school.dto;

import com.ngclass.backend.common.LocalizedText;
import java.util.UUID;

/** A subject in the teacher's settings, with how many groups use it (archived groups included). */
public record SubjectUsageItem(UUID id, LocalizedText name, String color, long groupCount) {
}
