package com.ngclass.backend.content.service;

import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.domain.FileKind;
import com.ngclass.backend.content.storage.FileStorage;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.MemoryCacheImageOutputStream;
import lombok.RequiredArgsConstructor;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.stereotype.Component;

/**
 * The pages the in-app viewer shows: a PDF page drawn once as a JPEG about 1240 px wide (sharp on a
 * phone, light on 4G) and kept beside the file; an image is its own single page.
 */
@Component
@RequiredArgsConstructor
public class PageRenderer {
	private static final int TARGET_WIDTH = 1240;

	private final FileStorage storage;

	public record Page(byte[] bytes, String mimeType) {
	}

	public Page page(FileAsset file, int page) {
		FileKind kind = file.kind();
		if (kind == FileKind.IMAGE && page == 1) {
			return new Page(original(file), file.getMimeType());
		}
		if (kind != FileKind.PDF || file.getPageCount() == null || page < 1 || page > file.getPageCount()) {
			throw ApiException.notFound("not_found");
		}
		String key = file.getStorageKey() + ".p" + page + ".jpg";
		byte[] cached = storage.read(key).orElse(null);
		if (cached == null) {
			cached = render(original(file), page);
			storage.put(key, cached);
		}
		return new Page(cached, "image/jpeg");
	}

	public byte[] original(FileAsset file) {
		return storage.read(file.getStorageKey()).orElseThrow(() -> ApiException.notFound("not_found"));
	}

	private static byte[] render(byte[] pdfBytes, int page) {
		try (PDDocument pdf = Loader.loadPDF(pdfBytes)) {
			PDRectangle box = pdf.getPage(page - 1).getCropBox();
			float dpi = Math.max(72f, Math.min(200f, TARGET_WIDTH / (box.getWidth() / 72f)));
			BufferedImage image = new PDFRenderer(pdf).renderImageWithDPI(page - 1, dpi, ImageType.RGB);
			return jpeg(image);
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	private static byte[] jpeg(BufferedImage image) throws IOException {
		ImageWriter writer = ImageIO.getImageWritersByFormatName("jpg").next();
		ImageWriteParam param = writer.getDefaultWriteParam();
		param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
		param.setCompressionQuality(0.82f);
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try (MemoryCacheImageOutputStream stream = new MemoryCacheImageOutputStream(out)) {
			writer.setOutput(stream);
			writer.write(null, new IIOImage(image, null, null), param);
		} finally {
			writer.dispose();
		}
		return out.toByteArray();
	}
}
