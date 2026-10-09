package com.ngclass.backend.content.controller;

import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.domain.ContentItem;
import com.ngclass.backend.content.domain.FileAsset;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.content.service.FileLinks;
import com.ngclass.backend.content.service.FileLinks.Target;
import com.ngclass.backend.content.service.PageRenderer;
import com.ngclass.backend.content.service.PageRenderer.Page;
import com.ngclass.backend.work.domain.Submission;
import com.ngclass.backend.work.repository.AssignmentRecipientRepository;
import com.ngclass.backend.work.repository.SubmissionRepository;
import java.nio.charset.StandardCharsets;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Files behind signed links (FileLinks), open without the access token: the signature is the
 * permission, and it expires after half an hour. Page 0 downloads the original file.
 */
@RestController
@RequestMapping("/api/v1/files")
@RequiredArgsConstructor
public class FileController {
	private final FileLinks links;
	private final ContentItemRepository items;
	private final SubmissionRepository submissions;
	private final AssignmentRecipientRepository recipients;
	private final PageRenderer renderer;

	@GetMapping("/{token}")
	public ResponseEntity<byte[]> file(@PathVariable String token) {
		Target target = links.verify(token);
		FileAsset file = switch (target.kind()) {
			case CONTENT -> items.findById(target.id()).map(ContentItem::getFile).orElseThrow(() -> ApiException.notFound("content_not_found"));
			case SUBMISSION -> submissions.findById(target.id()).map(Submission::getFile).orElseThrow(() -> ApiException.notFound("submission_not_found"));
			case CORRECTION -> recipients.findCorrectionFile(target.id()).orElseThrow(() -> ApiException.notFound("correction_not_found"));
		};
		CacheControl cache = CacheControl.maxAge(FileLinks.TTL).cachePrivate();
		if (target.page() == 0) {
			ContentDisposition disposition = ContentDisposition.attachment().filename(file.getOriginalName(), StandardCharsets.UTF_8).build();
			return ResponseEntity.ok()
					.contentType(MediaType.parseMediaType(file.getMimeType()))
					.header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
					.cacheControl(cache)
					.body(renderer.original(file));
		}
		Page page = renderer.page(file, target.page());
		return ResponseEntity.ok().contentType(MediaType.parseMediaType(page.mimeType())).cacheControl(cache).body(page.bytes());
	}
}
