package com.ngclass.backend.school.service;

import com.ngclass.backend.auth.service.CurrentTeacher;
import com.ngclass.backend.common.ApiException;
import com.ngclass.backend.content.repository.ChapterRepository;
import com.ngclass.backend.content.repository.ContentItemRepository;
import com.ngclass.backend.groups.repository.ClassGroupRepository;
import com.ngclass.backend.groups.repository.ClassGroupRepository.SubjectUse;
import com.ngclass.backend.school.domain.Subject;
import com.ngclass.backend.school.dto.ReferenceResponse.SubjectItem;
import com.ngclass.backend.school.dto.SubjectRequest;
import com.ngclass.backend.school.dto.SubjectUsageItem;
import com.ngclass.backend.school.repository.SubjectRepository;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** The teacher's subjects: none are predefined, she creates them (user decision, 2026-10-06). */
@Service
@RequiredArgsConstructor
public class SubjectService {
	private static final List<String> PALETTE = List.of("#2B3990", "#12A39A", "#FFB020", "#7048E8", "#3B5BDB", "#E8590C");

	private final SubjectRepository subjects;
	private final ClassGroupRepository groups;
	private final ChapterRepository chapters;
	private final ContentItemRepository contents;
	private final CurrentTeacher teacher;

	/** Paramètres > Matières: every subject in the teacher's order, with the groups that use it. */
	@Transactional(readOnly = true)
	public List<SubjectUsageItem> listWithUsage() {
		Map<UUID, Long> counts = groups.countGroupsBySubject().stream()
				.collect(Collectors.toMap(SubjectUse::getSubjectId, SubjectUse::getGroupCount));
		return subjects.findByTeacherIdOrderByPositionAsc(teacher.id()).stream()
				.map(subject -> new SubjectUsageItem(
						subject.getId(),
						subject.name(),
						subject.getColor(),
						counts.getOrDefault(subject.getId(), 0L)))
				.toList();
	}

	@Transactional
	public SubjectItem create(SubjectRequest request) {
		UUID me = teacher.id();
		String nameFr = request.nameFr().trim();
		if (subjects.existsByTeacherIdAndNameFrIgnoreCase(me, nameFr)) {
			throw ApiException.badRequest("subject_exists", nameFr);
		}
		List<Subject> all = subjects.findByTeacherIdOrderByPositionAsc(me);
		Subject subject = subjects.save(Subject.builder()
				.teacherId(me)
				.nameFr(nameFr)
				.nameAr(arabic(request))
				.color(request.color() != null ? request.color() : PALETTE.get(all.size() % PALETTE.size()))
				.position(all.isEmpty() ? 1 : all.getLast().getPosition() + 1)
				.build());
		return item(subject);
	}

	@Transactional
	public SubjectItem update(UUID id, SubjectRequest request) {
		Subject subject = own(id);
		String nameFr = request.nameFr().trim();
		if (!subject.getNameFr().equalsIgnoreCase(nameFr) && subjects.existsByTeacherIdAndNameFrIgnoreCase(subject.getTeacherId(), nameFr)) {
			throw ApiException.badRequest("subject_exists", nameFr);
		}
		subject.setNameFr(nameFr);
		subject.setNameAr(arabic(request));
		if (request.color() != null) {
			subject.setColor(request.color());
		}
		return item(subject);
	}

	/** Only a subject no group, chapter or document uses can go; otherwise its history would lose its name. */
	@Transactional
	public void delete(UUID id) {
		Subject subject = own(id);
		if (groups.existsBySubject_Id(id)) {
			throw new ApiException(HttpStatus.CONFLICT, "subject_in_use");
		}
		if (chapters.existsBySubjectId(id) || contents.existsBySubjectId(id)) {
			throw new ApiException(HttpStatus.CONFLICT, "subject_has_contents");
		}
		subjects.delete(subject);
	}

	/** One of the signed-in teacher's subjects; another teacher's does not exist for her. */
	public Subject own(UUID id) {
		return subjects.findByIdAndTeacherId(id, teacher.id()).orElseThrow(() -> ApiException.notFound("subject_not_found"));
	}

	/** An empty Arabic name is stored empty: the app then shows the French one. */
	private static String arabic(SubjectRequest request) {
		return request.nameAr() == null ? "" : request.nameAr().trim();
	}

	private static SubjectItem item(Subject subject) {
		return new SubjectItem(subject.getId(), subject.name(), subject.getColor());
	}
}
