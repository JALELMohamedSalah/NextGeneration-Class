package com.ngclass.backend.people.service;

import com.ngclass.backend.auth.service.AuthenticatedUser;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.people.domain.Parent;
import com.ngclass.backend.people.domain.Student;
import com.ngclass.backend.people.repository.ParentRepository;
import com.ngclass.backend.people.repository.StudentRepository;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/** The children a pupil or a parent may read about: the pupil themself, or one of the parent's children. */
@Component
@RequiredArgsConstructor
public class FamilyAccess {
	private final StudentRepository students;
	private final ParentRepository parents;

	/** [studentId] is required for a parent (one of their children) and ignored for a pupil. */
	public Student child(AuthenticatedUser user, UUID studentId) {
		return switch (user.role()) {
			case STUDENT -> self(user);
			case PARENT -> parent(user).getChildren().stream()
					.filter(c -> c.getId().equals(studentId) && c.getArchivedAt() == null)
					.findFirst()
					.orElseThrow(() -> ApiException.notFound("student_not_found"));
			case TEACHER, ADMIN -> throw new ApiException(HttpStatus.FORBIDDEN, "forbidden");
		};
	}

	/** Every child the user follows, archived ones left out. */
	public List<Student> children(AuthenticatedUser user) {
		return switch (user.role()) {
			case STUDENT -> List.of(self(user));
			case PARENT -> parent(user).getChildren().stream()
					.filter(c -> c.getArchivedAt() == null)
					.sorted(Comparator.comparing(Student::getId))
					.toList();
			case TEACHER, ADMIN -> throw new ApiException(HttpStatus.FORBIDDEN, "forbidden");
		};
	}

	private Student self(AuthenticatedUser user) {
		return students.findByUser_Id(user.id())
				.filter(s -> s.getArchivedAt() == null)
				.orElseThrow(() -> ApiException.notFound("student_not_found"));
	}

	private Parent parent(AuthenticatedUser user) {
		return parents.findByUser_Id(user.id()).orElseThrow(() -> ApiException.notFound("parent_not_found"));
	}
}
