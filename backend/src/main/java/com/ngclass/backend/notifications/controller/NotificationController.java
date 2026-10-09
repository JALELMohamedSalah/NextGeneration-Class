package com.ngclass.backend.notifications.controller;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.notifications.dto.NotificationDtos.NotificationsPage;
import com.ngclass.backend.notifications.dto.NotificationDtos.UnreadCount;
import com.ngclass.backend.notifications.service.NotificationService;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Each signed-in person reads and clears their own notifications. */
@RestController
@RequestMapping("/api/v1/me/notifications")
@RequiredArgsConstructor
public class NotificationController {
	private final NotificationService notificationService;

	@GetMapping
	public NotificationsPage list(@AuthenticationPrincipal AuthenticatedUser me) {
		return notificationService.page(me.id());
	}

	/** Cheap enough to ask every minute for the bell and the tab badge. */
	@GetMapping("/unread-count")
	public UnreadCount unreadCount(@AuthenticationPrincipal AuthenticatedUser me) {
		return notificationService.unreadCount(me.id());
	}

	@PostMapping("/{id}/read")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void read(@AuthenticationPrincipal AuthenticatedUser me, @PathVariable UUID id) {
		notificationService.markRead(me.id(), id);
	}

	@PostMapping("/read-all")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void readAll(@AuthenticationPrincipal AuthenticatedUser me) {
		notificationService.markAllRead(me.id());
	}
}
