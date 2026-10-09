package com.ngclass.backend.content.service;

import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.config.AppProperties;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Clock;
import java.time.Duration;
import java.util.Arrays;
import java.util.Base64;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/**
 * Short-lived signed links to a document's pages and file (architecture: "downloads through
 * short-lived signed URLs"). The app opens them without the access token: in an image widget, in the
 * browser for a download. Page 0 is the original file.
 */
@Component
public class FileLinks {
	public static final Duration TTL = Duration.ofMinutes(30);
	private static final Base64.Encoder ENCODER = Base64.getUrlEncoder().withoutPadding();
	private static final Base64.Decoder DECODER = Base64.getUrlDecoder();

	private final byte[] key;
	private final Clock clock;

	/** What a link opens: a library document, a pupil's submitted work, or the teacher's corrected copy (spec 06). */
	public enum Kind {
		CONTENT('c'),
		SUBMISSION('s'),
		CORRECTION('k');

		private final char code;

		Kind(char code) {
			this.code = code;
		}

		static Kind of(String code) {
			for (Kind kind : values()) {
				if (code.length() == 1 && kind.code == code.charAt(0)) {
					return kind;
				}
			}
			throw new IllegalArgumentException(code);
		}
	}

	public record Target(Kind kind, UUID id, int page) {
	}

	public FileLinks(AppProperties properties, Clock clock) {
		this.key = ("files:" + properties.jwt().secret()).getBytes(StandardCharsets.UTF_8);
		this.clock = clock;
	}

	/** A library document's page or file: a path relative to the API base, e.g. "files/abc.def". */
	public String link(UUID itemId, int page) {
		return link(Kind.CONTENT, itemId, page);
	}

	/** A pupil's submitted work: same rules, its own kind so one can never open the other. */
	public String submissionLink(UUID submissionId, int page) {
		return link(Kind.SUBMISSION, submissionId, page);
	}

	/** The teacher's corrected copy, by the pupil's recipient row. */
	public String correctionLink(UUID recipientId, int page) {
		return link(Kind.CORRECTION, recipientId, page);
	}

	private String link(Kind kind, UUID id, int page) {
		long expires = clock.instant().plus(TTL).getEpochSecond();
		String payload = kind.code + ":" + id + ":" + page + ":" + expires;
		String encoded = ENCODER.encodeToString(payload.getBytes(StandardCharsets.UTF_8));
		return "files/" + encoded + "." + ENCODER.encodeToString(sign(encoded));
	}

	public Target verify(String token) {
		int dot = token.indexOf('.');
		if (dot < 1) {
			throw ApiException.notFound("not_found");
		}
		String encoded = token.substring(0, dot);
		byte[] signature;
		String[] parts;
		try {
			signature = DECODER.decode(token.substring(dot + 1));
			parts = new String(DECODER.decode(encoded), StandardCharsets.UTF_8).split(":");
		} catch (IllegalArgumentException e) {
			throw ApiException.notFound("not_found");
		}
		if (parts.length != 4 || !MessageDigest.isEqual(sign(encoded), signature)) {
			throw ApiException.notFound("not_found");
		}
		try {
			if (clock.instant().getEpochSecond() > Long.parseLong(parts[3])) {
				throw new ApiException(HttpStatus.GONE, "link_expired");
			}
			return new Target(Kind.of(parts[0]), UUID.fromString(parts[1]), Integer.parseInt(parts[2]));
		} catch (IllegalArgumentException e) {
			throw ApiException.notFound("not_found");
		}
	}

	private byte[] sign(String encoded) {
		try {
			Mac mac = Mac.getInstance("HmacSHA256");
			mac.init(new SecretKeySpec(key, "HmacSHA256"));
			return Arrays.copyOf(mac.doFinal(encoded.getBytes(StandardCharsets.UTF_8)), 18);
		} catch (GeneralSecurityException e) {
			throw new IllegalStateException(e);
		}
	}
}
