import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/models/note.dart';

class NoteService {
  final EncryptionService encryptionService;
  final HiveStorageServices<Note> storage;

  NoteService({required this.encryptionService, required this.storage});

  // Add note securely using encryption and storage //
  Future<void> addNote(Note note) async {
    if (note.title.isEmpty) {
      throw Exception('Note title cannot be empty');
    }
    if (note.content.isEmpty) {
      throw Exception('Note content cannot be empty');
    }
  }

  Future<Note?> getNote(int id) async {
    return null;
  }

  Future<void> deleteNote(int id) async {}
  Future<void> updateNote(Note note) async {}
  Future<List<Note>> getAllNotes() async {
    return [];
  }
}
