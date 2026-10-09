package com.ngclass.backend.auth.service;

import com.ngclass.backend.auth.domain.Role;
import com.ngclass.backend.auth.domain.User;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Supplier;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * The teacher whose space a request works in (V6): the teacher herself, or the teacher of the signed-in
 * pupil or parent. Every teacher query goes through it, so a teacher never reaches another one's data.
 */
@Component
@RequiredArgsConstructor
public class CurrentTeacher {
	private final StudentRepository students;
	private final ParentRepository parents;

	public UUID id() {
		return find().orElseThrow(() -> new ApiException(HttpStatus.FORBIDDEN, "forbidden"));
	}

	/** Empty for the owner of the platform, who has no teacher space. */
	public Optional<UUID> find() {
		AuthenticatedUser me = principal();
		return switch (me.role()) {
			case TEACHER -> Optional.of(me.id());
			case STUDENT -> students.findByUser_Id(me.id()).map(Student::getTeacherId);
			case PARENT -> parents.findByUser_Id(me.id()).map(Parent::getTeacherId);
			case ADMIN -> Optional.empty();
		};
	}

	public static AuthenticatedUser principal() {
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		if (auth != null && auth.getPrincipal() instanceof AuthenticatedUser user) {
			return user;
		}
		throw new ApiException(HttpStatus.UNAUTHORIZED, "unauthorized");
	}

	/** Runs [work] as [teacher], outside any request (the dev seeder). */
	public static <T> T actingAs(User teacher, Supplier<T> work) {
		if (teacher.getRole() != Role.TEACHER) {
			throw new IllegalArgumentException("Not a teacher: " + teacher.getUsername());
		}
		SecurityContext previous = SecurityContextHolder.getContext();
		SecurityContext context = SecurityContextHolder.createEmptyContext();
		context.setAuthentication(new UsernamePasswordAuthenticationToken(
				new AuthenticatedUser(teacher.getId(), Role.TEACHER, teacher.getUsername()),
				null,
				List.of(new SimpleGrantedAuthority("ROLE_TEACHER"))));
		SecurityContextHolder.setContext(context);
		try {
			return work.get();
		} finally {
			SecurityContextHolder.setContext(previous);
		}
	}
}
