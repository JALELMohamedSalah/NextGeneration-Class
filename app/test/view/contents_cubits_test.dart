import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/core/platform/file_chooser.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/view/stateManager/common/load_status.dart';
import 'package:ngclass/view/stateManager/document/document_cubit.dart';
import 'package:ngclass/view/stateManager/document_form/document_form_cubit.dart';
import 'package:ngclass/view/stateManager/library/library_cubit.dart';
import 'package:ngclass/view/stateManager/my_contents/my_contents_cubit.dart';
import 'package:ngclass/view/stateManager/share/share_cubit.dart';

import '../helpers/content_fixtures.dart';

void main() {
  group('LibraryCubit', () {
    test('opens where the teacher last worked, and lists that chapter only', () async {
      final cubit = LibraryCubit(FakeContentRepository());
      await cubit.load();

      expect(cubit.state.status, LoadStatus.ready);
      expect(cubit.state.place, const LibraryPlace(subjectId: 'math', levelId: 'l4', chapterId: 'ch-fr'));
      expect(cubit.state.visible.map((d) => d.id), ['serie2', 'lecon', 'corrige', 'photo', 'fiche']);
      expect(cubit.state.countSubject('math'), 6);
      expect(cubit.state.countChapter('ch-mul'), 1);
      expect(cubit.state.chaptersOf('math', 'l4').map((c) => c.title), ['Les fractions', 'La multiplication']);
    });

    test('search ignores accents, case and word order; tag and status filter', () async {
      final cubit = LibraryCubit(FakeContentRepository());
      await cubit.load();

      cubit.search('FRACTIONS serie');
      expect(cubit.state.visible.map((d) => d.id), ['serie2']);
      cubit.search('');
      cubit.filterTag(ContentTag.autre);
      expect(cubit.state.visible.map((d) => d.id), ['photo', 'fiche']);
      cubit.filterTag(null);
      cubit.filterStatus(ContentStatus.draft);
      expect(cubit.state.visible.map((d) => d.id), ['corrige']);
      expect(cubit.state.placeCount, 5);
    });

    test('a subject picks its first level and chapter; an empty one stays without a level', () async {
      final cubit = LibraryCubit(FakeContentRepository());
      await cubit.load();

      cubit.selectSubject('math', ['l1', 'l4']);
      expect(cubit.state.place, const LibraryPlace(subjectId: 'math', levelId: 'l4', chapterId: 'ch-fr'));
      cubit.selectSubject('lecture', ['l1', 'l4']);
      expect(cubit.state.place, const LibraryPlace(subjectId: 'lecture'));
      expect(cubit.state.visible, isEmpty);
    });

    test('a new chapter is selected; a saved document goes first and shows its place', () async {
      final cubit = LibraryCubit(FakeContentRepository());
      await cubit.load();

      final (chapter, failure) = await cubit.createChapter(subjectId: 'math', levelId: 'l4', title: ' Les mesures ');
      expect(failure, isNull);
      expect(chapter!.title, 'Les mesures');
      expect(cubit.state.place?.chapterId, 'ch-new');

      cubit.documentSaved(doc('new', 'Mesures 1', chapterId: 'ch-mul'));
      expect(cubit.state.library.documents.first.id, 'new');
      expect(cubit.state.place?.chapterId, 'ch-mul');
    });

    test('archiving removes the document; deleting a chapter leaves its documents in "Sans chapitre"', () async {
      final repository = FakeContentRepository();
      final cubit = LibraryCubit(repository);
      await cubit.load();

      expect(await cubit.archive(cubit.state.document('photo')!), isNull);
      expect(repository.archived, ['photo']);
      expect(cubit.state.document('photo'), isNull);

      expect(await cubit.deleteChapter(multiplication), isNull);
      expect(cubit.state.place, const LibraryPlace(subjectId: 'math', levelId: 'l4'));
      expect(cubit.state.visible.map((d) => d.id), ['table']);
    });

    test('a failed load says why', () async {
      final cubit = LibraryCubit(FakeContentRepository()..failure = const ApiFailure(code: ApiFailure.network));
      await cubit.load();

      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.failure?.isNetwork, isTrue);
    });
  });

  group('DocumentFormCubit', () {
    test('the title starts from the file name; nothing is sent while something is missing', () async {
      final repository = FakeContentRepository();
      final chooser = FakeFileChooser();
      final cubit = DocumentFormCubit.upload(repository, chooser, subjectId: 'math', levelId: 'l4', chapterId: 'ch-fr');

      expect(await cubit.submit(), isNull);
      expect(cubit.state.errors, {DocumentFormError.file, DocumentFormError.title});

      chooser.next = pdfFile('serie2_fractions.pdf');
      await cubit.pickFile();
      expect(cubit.state.title, 'Serie2 fractions');
      expect(cubit.state.errors, isEmpty);
      expect(repository.uploads, isEmpty);
    });

    test('a picker that fails says so instead of breaking the panel', () async {
      final cubit = DocumentFormCubit.upload(FakeContentRepository(), _ThrowingChooser(), subjectId: 'math', levelId: 'l4');
      await cubit.pickFile();

      expect(cubit.state.failure, isNotNull);
      expect(cubit.state.file, isNull);
    });

    test('a file too large or of another type is refused before upload', () async {
      final repository = FakeContentRepository();
      final chooser = FakeFileChooser()..next = pdfFile('gros.pdf', size: PickedFile.maxBytes + 1);
      final cubit = DocumentFormCubit.upload(repository, chooser, subjectId: 'math', levelId: 'l4');
      await cubit.pickFile();

      expect(cubit.state.fileProblem, FileProblem.tooLarge);
      expect(await cubit.submit(), isNull);
      expect(cubit.state.errors, {DocumentFormError.file});

      chooser.next = pdfFile('photo.heic');
      await cubit.pickFile();
      expect(cubit.state.fileProblem, FileProblem.unsupported);
      expect(repository.uploads, isEmpty);
    });

    test('an upload sends the place, the tag and the groups; a draft is never shared', () async {
      final repository = FakeContentRepository();
      final chooser = FakeFileChooser()..next = pdfFile('serie3.pdf');
      final cubit = DocumentFormCubit.upload(repository, chooser, subjectId: 'math', levelId: 'l4', chapterId: 'ch-fr');
      await cubit.pickFile();
      cubit
        ..setTitle('Série 3')
        ..setTag(ContentTag.cours)
        ..toggleGroup('g4a');
      expect(cubit.state.groupIds, ['g4a']);
      cubit.setDraft(true);
      expect(cubit.state.groupIds, isEmpty);
      cubit
        ..setDraft(false)
        ..toggleGroup('g4a');

      final saved = await cubit.submit();
      expect(saved?.title, 'Série 3');
      final (draft, file) = repository.uploads.single;
      expect(draft.chapterId, 'ch-fr');
      expect(draft.tag, ContentTag.cours);
      expect(draft.groupIds, ['g4a']);
      expect(file.name, 'serie3.pdf');
      expect(cubit.state.submitting, isFalse);
    });

    test('changing the level leaves "Sans chapitre"; editing sends an update', () async {
      final repository = FakeContentRepository();
      final document = repository.library_.documents.first;
      final cubit = DocumentFormCubit.edit(repository, FakeFileChooser(), document);

      expect(cubit.state.isEditing, isTrue);
      cubit.setLevel('l5');
      expect(cubit.state.chapterId, isNull);
      cubit
        ..setLevel('l4')
        ..setChapter('ch-mul')
        ..setDraft(true);
      final saved = await cubit.submit();

      expect(saved?.status, ContentStatus.draft);
      expect(repository.updates.single.$1, 'serie2');
      expect(repository.updates.single.$2.chapterId, 'ch-mul');
      expect(repository.uploads, isEmpty);
    });
  });

  test('ShareCubit ticks groups and saves a document or a chapter', () async {
    final repository = FakeContentRepository();
    final cubit = ShareCubit(repository, DocumentTarget(repository.library_.documents.first));

    expect(cubit.state.selected, {'g4a'});
    cubit
      ..toggle('g4a')
      ..toggle('g5');
    final saved = await cubit.save();
    expect((saved! as ContentDocument).sharedGroupIds, ['g5']);

    final chapter = ShareCubit(repository, const ChapterTarget(fractions))..toggle('g4a');
    final savedChapter = await chapter.save();
    expect((savedChapter! as Chapter).sharedGroupIds, ['g4a']);
    expect(repository.shares.map((s) => s.$1), ['serie2', 'ch-fr']);
  });

  test('DocumentCubit pages within the document and downloads through the opener', () async {
    final opener = RecordingFileOpener();
    final cubit = DocumentCubit(FakeContentRepository(), opener, 'serie2');
    await cubit.load();

    expect(cubit.state.pageCount, 3);
    cubit.previous();
    expect(cubit.state.page, 0);
    cubit
      ..next()
      ..next()
      ..next();
    expect(cubit.state.page, 2);
    expect(await cubit.download(), isTrue);
    expect(opener.opened, ['http://localhost/files/serie2-download']);
  });

  group('MyContentsCubit', () {
    test('groups by subject and chapter, filters by subject, and opening takes "Nouveau" off', () async {
      final cubit = MyContentsCubit(FakeContentRepository());
      await cubit.load();

      expect(cubit.state.subjects.map((s) => s.id), ['math', 'lec']);
      expect(cubit.state.sections.map((s) => s.chapter?.title), ['Les fractions', 'Contes et fables']);
      expect(cubit.state.sections.first.documents, hasLength(2));
      expect(cubit.state.newCount, 1);

      cubit.filterSubject('lec');
      expect(cubit.state.sections.single.subject.id, 'lec');

      cubit.opened('serie2');
      expect(cubit.state.newCount, 0);
    });

    test('a parent switching child asks for that child and clears the subject filter', () async {
      final repository = FakeContentRepository();
      final cubit = MyContentsCubit(repository);
      await cubit.load(studentId: 's1');
      cubit.filterSubject('lec');
      await cubit.load(studentId: 's2');

      expect(repository.mineAskedFor, ['s1', 's2']);
      expect(cubit.state.subjectId, isNull);
      expect(cubit.state.studentId, 's2');
    });
  });
}

class _ThrowingChooser implements FileChooser {
  @override
  Future<PickedFile?> pickDocument() => Future.error(UnimplementedError('pickFile() has not been implemented.'));

  @override
  Future<PickedFile?> pickSpreadsheet() => Future.error(UnimplementedError('pickFile() has not been implemented.'));
}
