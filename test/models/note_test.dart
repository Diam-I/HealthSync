import 'package:flutter_test/flutter_test.dart';
import 'package:healthsync/enums/noteCategory.dart';
import 'package:healthsync/models/note.dart';

void main() {
  group('Note Model', () {
    late Note note;

    setUp(() {
      note = Note(
        id: '1',
        title: 'Douleur',
        content: 'Douleur intense.',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        category: NoteCategory.Symptome,
        tags: const ['cardio'],
      );
    });

    group('Constructor', () {
      test('should create a valid Note object', () {
        expect(note.id, '1');
        expect(note.title, 'Douleur');
        expect(note.content, 'Douleur intense.');
        expect(note.createdAt, DateTime(2025, 1, 1));
        expect(note.updatedAt, DateTime(2025, 1, 1));
        expect(note.category, NoteCategory.Symptome);
        expect(note.tags, const ['cardio']);
      });
    });

    group('toJson()', () {
      test('should convert a Note object to JSON', () {
        final json = note.toJson();

        expect(json['id'], '1');
        expect(json['title'], 'Douleur');
        expect(json['content'], 'Douleur intense.');
        expect(json['createdAt'], note.createdAt.toIso8601String());
        expect(json['updatedAt'], note.updatedAt.toIso8601String());
        expect(json['category'], 'Symptome');
        expect(json['tags'], ['cardio']);
      });

      test('should convert a note with no tags to JSON', () {
        final noteWithoutTags = Note(
          id: '2',
          title: 'Sans tags',
          content: 'Note sans tags.',
          createdAt: DateTime(2025, 1, 3),
          updatedAt: DateTime(2025, 1, 3),
          category: NoteCategory.Personnel,
        );

        final json = noteWithoutTags.toJson();

        expect(json['tags'], []);
      });

      test('should serialize multiple tags correctly', () {
        final note = Note(
          id: '3',
          title: 'Test',
          content: '...',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: NoteCategory.Consultation,
          tags: const ['cardio', 'urgence', 'scanner'],
        );

        expect(note.toJson()['tags'], equals(['cardio', 'urgence', 'scanner']));
      });

      test('should serialize Consultation category', () {
        final consultation = note.copyWith(category: NoteCategory.Consultation);

        expect(consultation.toJson()['category'], 'Consultation');
      });

      test('should serialize many tags', () {
        final tags = List.generate(100, (i) => 'tag$i');

        final bigNote = note.copyWith(tags: tags);

        expect(bigNote.toJson()['tags'].length, 100);
      });
    });

    group('fromJson()', () {
      test('should create a Note object from JSON', () {
        final json = note.toJson();

        final rebuilt = Note.fromJson(json);

        expect(rebuilt.id, note.id);
        expect(rebuilt.title, note.title);
        expect(rebuilt.content, note.content);
        expect(rebuilt.createdAt, note.createdAt);
        expect(rebuilt.updatedAt, note.updatedAt);
        expect(rebuilt.category, note.category);
        expect(rebuilt.tags, note.tags);
      });

      test('should create a Note with empty tags list', () {
        final json = {
          'id': '2',
          'title': 'Sans tags',
          'content': '...',
          'createdAt': DateTime(2025, 1, 3).toIso8601String(),
          'updatedAt': DateTime(2025, 1, 3).toIso8601String(),
          'category': 'Personnel',
        };

        final rebuilt = Note.fromJson(json);

        expect(rebuilt.tags, isEmpty);
      });

      test('should throw StateError for invalid category', () {
        final json = {
          'id': '3',
          'title': 'Test',
          'content': '...',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'category': 'InvalidCategory',
        };

        expect(() => Note.fromJson(json), throwsA(isA<StateError>()));
      });

      test('should throw FormatException for invalid date', () {
        final json = {
          'id': '4',
          'title': 'Test',
          'content': '...',
          'createdAt': 'invalid-date',
          'updatedAt': DateTime.now().toIso8601String(),
          'category': 'Consultation',
        };

        expect(() => Note.fromJson(json), throwsA(isA<FormatException>()));
      });

      test('should create a new instance', () {
        final rebuilt = Note.fromJson(note.toJson());

        expect(identical(note, rebuilt), isFalse);
      });
    });

    group('copyWith()', () {
      test('should create a copy with updated fields', () {
        final updated = note.copyWith(
          title: 'Douleur modérée',
          content: 'Douleur moins grave.',
          updatedAt: DateTime(2025, 1, 2),
          category: NoteCategory.Consultation,
          tags: const ['updated', 'note'],
        );

        expect(updated.id, note.id);
        expect(updated.title, 'Douleur modérée');
        expect(updated.content, 'Douleur moins grave.');
        expect(updated.createdAt, note.createdAt);
        expect(updated.updatedAt, DateTime(2025, 1, 2));
        expect(updated.category, NoteCategory.Consultation);
        expect(updated.tags, const ['updated', 'note']);
      });

      test('should update only provided fields', () {
        final updated = note.copyWith(title: 'Nouvelle note');

        expect(updated.id, note.id);
        expect(updated.title, 'Nouvelle note');
        expect(updated.content, note.content);
        expect(updated.createdAt, note.createdAt);
        expect(updated.updatedAt, note.updatedAt);
        expect(updated.category, note.category);
        expect(updated.tags, note.tags);
      });

      test(
        'should return an identical copy when no parameters are provided',
        () {
          final copy = note.copyWith();

          expect(copy.id, note.id);
          expect(copy.title, note.title);
          expect(copy.content, note.content);
          expect(copy.createdAt, note.createdAt);
          expect(copy.updatedAt, note.updatedAt);
          expect(copy.category, note.category);
          expect(copy.tags, note.tags);

          expect(identical(copy, note), isFalse);
        },
      );
    });

    group('Serialization Integrity', () {
      test('should preserve data through JSON serialization cycle', () {
        final rebuilt = Note.fromJson(note.toJson());

        expect(rebuilt.toJson(), equals(note.toJson()));
      });

      test('should preserve tag order', () {
        final rebuilt = Note.fromJson(note.toJson());

        expect(rebuilt.tags, orderedEquals(note.tags));
      });

      test('should preserve dates after serialization', () {
        final rebuilt = Note.fromJson(note.toJson());

        expect(rebuilt.createdAt.isAtSameMomentAs(note.createdAt), isTrue);

        expect(rebuilt.updatedAt.isAtSameMomentAs(note.updatedAt), isTrue);
      });
    });
  });
}
