import 'dart:typed_data';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/enums/note_category.dart';
import 'package:healthsync/features/notes/services/note_service.dart';
import 'package:healthsync/models/note.dart';

class NoteCategoryAdapter extends TypeAdapter<NoteCategory> {
  @override
  final int typeId = 1;

  @override
  NoteCategory read(BinaryReader reader) {
    return NoteCategory.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, NoteCategory obj) {
    writer.writeByte(obj.index);
  }
}

void main() {
  late HiveStorageServices<Note> storage;
  late NoteService noteService;
  late EncryptionService encryptionService;

  final encryptionKey = Uint8List.fromList(List.generate(32, (index) => index));

  Note createNote({
    String id = '1',
    String title = 'Titre de la note',
    String content = 'Contenu de la note',
    NoteCategory category = NoteCategory.consultation,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String> tags = const [],
  }) {
    final defaultDate = DateTime(2025, 1, 1);

    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt ?? defaultDate,
      updatedAt: updatedAt ?? defaultDate,
      category: category,
      tags: tags,
    );
  }

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('healthsync_notes_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteCategoryAdapter());
    }
    encryptionService = EncryptionService();
  });
  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });
  setUp(() async {
    storage = HiveStorageServices<Note>(
      'test_notes_${DateTime.now().microsecondsSinceEpoch}',
    );

    await storage.init(encryptionKey);

    noteService = NoteService(
      encryptionService: encryptionService,
      storage: storage,
    );
  });

  tearDown(() async {
    if (storage.isOpen) {
      await storage.clearBox();
      await storage.closeBox();
    }
  });

  group('NoteService - addNote', () {
    test('should add a note successfully', () async {
      final note = createNote();

      await noteService.addNote(note);

      final result = await noteService.getNote(note.id);

      expect(result, isNotNull);
      expect(result!.id, note.id);
      expect(result.title, note.title);
      expect(result.content, note.content);
      expect(result.category, note.category);
      expect(result.tags, note.tags);
    });

    test('should add a note with tags', () async {
      final note = createNote(tags: const ['important', 'medical', 'suivi']);

      await noteService.addNote(note);

      final result = await noteService.getNote(note.id);

      expect(result, isNotNull);
      expect(result!.tags, ['important', 'medical', 'suivi']);
    });

    test('should reject a note with an empty title', () async {
      final note = createNote(title: '   ');

      expect(() => noteService.addNote(note), throwsA(isA<ArgumentError>()));
    });

    test('should reject a note with an empty content', () async {
      final note = createNote(content: '   ');

      expect(() => noteService.addNote(note), throwsA(isA<ArgumentError>()));
    });

    test('should reject a note when title is empty', () async {
      final note = createNote(title: '');

      expect(() => noteService.addNote(note), throwsA(isA<ArgumentError>()));
    });

    test('should reject a note when content is empty', () async {
      final note = createNote(content: '');

      expect(() => noteService.addNote(note), throwsA(isA<ArgumentError>()));
    });

    test('should reject a note with an existing id', () async {
      final note = createNote();

      await noteService.addNote(note);

      expect(() => noteService.addNote(note), throwsException);
    });
  });

  group('NoteService - getNote', () {
    test('should retrieve an existing note', () async {
      final note = createNote();

      await noteService.addNote(note);

      final result = await noteService.getNote(note.id);

      expect(result, isNotNull);
      expect(result!.id, note.id);
    });

    test('should return null when the note does not exist', () async {
      final result = await noteService.getNote('unknown-id');

      expect(result, isNull);
    });

    test('should reject an empty id', () async {
      expect(() => noteService.getNote(''), throwsA(isA<ArgumentError>()));
    });

    test('should reject an id containing only spaces', () async {
      expect(() => noteService.getNote('   '), throwsA(isA<ArgumentError>()));
    });

    test('should retrieve the correct note among several notes', () async {
      final note1 = createNote(id: 'note-1', title: 'Première note');

      final note2 = createNote(id: 'note-2', title: 'Deuxième note');

      await noteService.addNote(note1);
      await noteService.addNote(note2);

      final result = await noteService.getNote('note-2');

      expect(result, isNotNull);
      expect(result!.id, 'note-2');
      expect(result.title, 'Deuxième note');
    });
  });

  group('NoteService - updateNote', () {
    test('should update an existing note', () async {
      final note = createNote();

      await noteService.addNote(note);

      final updatedNote = note.copyWith(
        title: 'Titre modifié',
        content: 'Contenu modifié',
      );

      await noteService.updateNote(updatedNote);

      final result = await noteService.getNote(note.id);

      expect(result, isNotNull);
      expect(result!.title, 'Titre modifié');
      expect(result.content, 'Contenu modifié');
    });

    test('should preserve the note id when updating', () async {
      final note = createNote(id: 'note-123');

      await noteService.addNote(note);

      final updatedNote = note.copyWith(title: 'Nouveau titre');

      await noteService.updateNote(updatedNote);

      final result = await noteService.getNote('note-123');

      expect(result, isNotNull);
      expect(result!.id, 'note-123');
    });

    test('should update the category', () async {
      final note = createNote();

      await noteService.addNote(note);

      final updatedNote = note.copyWith(category: NoteCategory.consultation);

      await noteService.updateNote(updatedNote);

      final result = await noteService.getNote(note.id);

      expect(result!.category, NoteCategory.consultation);
    });

    test('should update the tags', () async {
      final note = createNote();

      await noteService.addNote(note);

      final updatedNote = note.copyWith(tags: const ['urgent', 'important']);

      await noteService.updateNote(updatedNote);

      final result = await noteService.getNote(note.id);

      expect(result!.tags, ['urgent', 'important']);
    });

    test('should update updatedAt', () async {
      final oldDate = DateTime(2025, 1, 1);

      final note = createNote(updatedAt: oldDate);

      await noteService.addNote(note);

      await noteService.updateNote(note.copyWith(title: 'Titre modifié'));

      final result = await noteService.getNote(note.id);

      expect(result, isNotNull);
      expect(result!.updatedAt.isAfter(oldDate), true);
    });

    test('should reject update of a nonexistent note', () async {
      final note = createNote(id: 'unknown');

      expect(() => noteService.updateNote(note), throwsA(isA<ArgumentError>()));
    });

    test('should reject update with an empty title', () async {
      final note = createNote();

      await noteService.addNote(note);

      final updatedNote = note.copyWith(title: '   ');

      expect(
        () => noteService.updateNote(updatedNote),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject update with empty content', () async {
      final note = createNote();

      await noteService.addNote(note);

      final updatedNote = note.copyWith(content: '   ');

      expect(
        () => noteService.updateNote(updatedNote),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('NoteService - deleteNote', () {
    test('should delete an existing note', () async {
      final note = createNote();

      await noteService.addNote(note);

      await noteService.deleteNote(note.id);

      final result = await noteService.getNote(note.id);

      expect(result, isNull);
    });

    test('should reject deletion of a nonexistent note', () async {
      expect(
        () => noteService.deleteNote('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject deletion with an empty id', () async {
      expect(() => noteService.deleteNote(''), throwsA(isA<ArgumentError>()));
    });

    test('should delete only the selected note', () async {
      final note1 = createNote(id: 'note-1');

      final note2 = createNote(id: 'note-2');

      await noteService.addNote(note1);
      await noteService.addNote(note2);

      await noteService.deleteNote(note1.id);

      final result1 = await noteService.getNote(note1.id);
      final result2 = await noteService.getNote(note2.id);

      expect(result1, isNull);
      expect(result2, isNotNull);
    });
  });

  // ============================================================
  // GET ALL NOTES
  // ============================================================

  group('NoteService - getAllNotes', () {
    test('should return an empty list when there are no notes', () async {
      final result = await noteService.getAllNotes();

      expect(result, isEmpty);
    });

    test('should return all notes', () async {
      final note1 = createNote(id: 'note-1');

      final note2 = createNote(id: 'note-2');

      final note3 = createNote(id: 'note-3');

      await noteService.addNote(note1);
      await noteService.addNote(note2);
      await noteService.addNote(note3);

      final result = await noteService.getAllNotes();

      expect(result.length, 3);

      expect(
        result.map((note) => note.id),
        containsAll(['note-1', 'note-2', 'note-3']),
      );
    });
  });

  group('NoteService - searchNotes', () {
    setUp(() async {
      await noteService.addNote(
        createNote(
          id: 'note-1',
          title: 'Rendez-vous médecin',
          content: 'Consultation générale',
        ),
      );

      await noteService.addNote(
        createNote(
          id: 'note-2',
          title: 'Ordonnance',
          content: 'Médicament prescrit',
        ),
      );

      await noteService.addNote(
        createNote(
          id: 'note-3',
          title: 'Résultats',
          content: 'Analyse sanguine',
        ),
      );
    });

    test('should find a note by title', () async {
      final result = await noteService.searchNotes('médecin');

      expect(result.length, 1);
      expect(result.first.id, 'note-1');
    });

    test('should find a note by content', () async {
      final result = await noteService.searchNotes('prescrit');

      expect(result.length, 1);
      expect(result.first.id, 'note-2');
    });

    test('should be case insensitive', () async {
      final result = await noteService.searchNotes('MÉDECIN');

      expect(result.length, 1);
      expect(result.first.id, 'note-1');
    });

    test('should find multiple notes containing the keyword', () async {
      final result = await noteService.searchNotes('e');

      expect(result.length, greaterThan(1));
    });

    test('should return an empty list for an empty keyword', () async {
      final result = await noteService.searchNotes('');

      expect(result, isEmpty);
    });

    test(
      'should return an empty list for a keyword containing only spaces',
      () async {
        final result = await noteService.searchNotes('   ');

        expect(result, isEmpty);
      },
    );

    test('should return an empty list when keyword does not exist', () async {
      final result = await noteService.searchNotes('xyz-not-found');

      expect(result, isEmpty);
    });
  });

  group('NoteService - getNotesByCategory', () {
    test('should return notes matching the category', () async {
      final note1 = createNote(
        id: 'note-1',
        category: NoteCategory.consultation,
      );

      final note2 = createNote(
        id: 'note-2',
        category: NoteCategory.consultation,
      );

      await noteService.addNote(note1);
      await noteService.addNote(note2);

      final result = await noteService.getNotesByCategory(
        NoteCategory.consultation,
      );

      expect(result.length, 2);

      expect(
        result.every((note) => note.category == NoteCategory.consultation),
        true,
      );
    });

    test(
      'should return an empty list when no note matches the category',
      () async {
        final note = createNote(category: NoteCategory.consultation);

        await noteService.addNote(note);

        // On utilise une autre valeur de l'enum si elle existe.
        final categories = NoteCategory.values;

        if (categories.length > 1) {
          final otherCategory = categories.firstWhere(
            (category) => category != NoteCategory.consultation,
          );

          final result = await noteService.getNotesByCategory(otherCategory);

          expect(result, isEmpty);
        }
      },
    );

    test('should return only notes from the requested category', () async {
      final consultationNote = createNote(
        id: 'consultation',
        category: NoteCategory.consultation,
      );

      await noteService.addNote(consultationNote);

      final result = await noteService.getNotesByCategory(
        NoteCategory.consultation,
      );

      expect(result.length, 1);
      expect(result.first.id, 'consultation');
    });
  });

  group('NoteService - getNotesSortedByDate', () {
    test('should return an empty list when there are no notes', () async {
      final result = await noteService.getNotesSortedByDate();

      expect(result, isEmpty);
    });

    test('should sort notes by updatedAt descending', () async {
      final oldNote = createNote(id: 'old', updatedAt: DateTime(2025, 1, 1));

      final middleNote = createNote(
        id: 'middle',
        updatedAt: DateTime(2025, 1, 2),
      );

      final newNote = createNote(id: 'new', updatedAt: DateTime(2025, 1, 3));

      await noteService.addNote(oldNote);
      await noteService.addNote(middleNote);
      await noteService.addNote(newNote);

      final result = await noteService.getNotesSortedByDate();

      expect(result.map((note) => note.id).toList(), ['new', 'middle', 'old']);
    });

    test('should place the most recently updated note first', () async {
      final firstNote = createNote(
        id: 'first',
        updatedAt: DateTime(2025, 1, 1),
      );

      final secondNote = createNote(
        id: 'second',
        updatedAt: DateTime(2025, 2, 1),
      );

      await noteService.addNote(firstNote);
      await noteService.addNote(secondNote);

      final result = await noteService.getNotesSortedByDate();

      expect(result.first.id, 'second');
      expect(result.last.id, 'first');
    });
  });

  group('NoteService - storage', () {
    test('should reject operations when storage is not initialized', () async {
      final uninitializedStorage = HiveStorageServices<Note>(
        'uninitialized_notes',
      );

      final service = NoteService(
        encryptionService: encryptionService,
        storage: uninitializedStorage,
      );

      expect(() => service.getAllNotes(), throwsException);
    });

    test(
      'should reject adding a note when storage is not initialized',
      () async {
        final uninitializedStorage = HiveStorageServices<Note>(
          'uninitialized_add_notes',
        );

        final service = NoteService(
          encryptionService: encryptionService,
          storage: uninitializedStorage,
        );

        final note = createNote();

        expect(() => service.addNote(note), throwsException);
      },
    );
  });
}
