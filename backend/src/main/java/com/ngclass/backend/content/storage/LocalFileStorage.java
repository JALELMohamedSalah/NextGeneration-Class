package com.ngclass.backend.content.storage;

import com.ngclass.backend.config.AppProperties;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

/** Files in a folder, spread over sub-folders by the first two characters of their random key. */
@Component
public class LocalFileStorage implements FileStorage {
	private static final Pattern KEY = Pattern.compile("[a-z0-9][a-z0-9.-]{7,79}");

	private final Path root;

	public LocalFileStorage(AppProperties properties) {
		this.root = Path.of(properties.storage().dir()).toAbsolutePath().normalize();
	}

	@Override
	public String save(byte[] data) {
		String key = UUID.randomUUID().toString().replace("-", "");
		put(key, data);
		return key;
	}

	@Override
	public void put(String key, byte[] data) {
		Path path = path(key);
		try {
			Files.createDirectories(path.getParent());
			// Written beside, then moved: a reader never sees half a file.
			Path partial = path.resolveSibling(path.getFileName() + ".part");
			Files.write(partial, data);
			Files.move(partial, path, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	@Override
	public Optional<byte[]> read(String key) {
		try {
			return Optional.of(Files.readAllBytes(path(key)));
		} catch (NoSuchFileException e) {
			return Optional.empty();
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	private Path path(String key) {
		if (!KEY.matcher(key).matches()) {
			throw new IllegalArgumentException("Invalid storage key");
		}
		return root.resolve(key.substring(0, 2)).resolve(key);
	}
}
