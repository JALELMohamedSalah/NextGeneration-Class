package com.ngclass.backend.content.storage;

import java.util.Optional;

/**
 * Where uploaded files live. A folder today (a volume on the VPS); an S3-compatible bucket can replace
 * it later without touching the app (architecture, "Files").
 */
public interface FileStorage {
	/** Stores [data] under a new random key and returns the key. */
	String save(byte[] data);

	/** Stores a file derived from another one (a rendered page) under a key the caller chose. */
	void put(String key, byte[] data);

	Optional<byte[]> read(String key);
}
