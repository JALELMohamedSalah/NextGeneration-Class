package com.ngclass.backend.common;

/** A text stored in both app languages; the app shows the one matching its current language. */
public record LocalizedText(String fr, String ar) {
}
