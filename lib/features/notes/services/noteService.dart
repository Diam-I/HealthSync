import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/models/note.dart';

class NoteService {
  final EncryptionService encryptionService;
  final HiveStorageServices<Note> storage;

  NoteService({required this.encryptionService, required this.storage});

  Future<void> addNote(Note note) async {
    // Add note securely using encryption and storage //
    if (note.title.isEmpty) {
      throw Exception('Note title cannot be empty');
    }
    if (note.content.isEmpty) {
      throw Exception('Note content cannot be empty');
    }
  }

  Future<Note?> getNote(int id) async {
    // Implement logic to retrieve the note securely
    return null;
  }

  Future<void> deleteNote(int id) async {
    // Implement logic to delete the note securely
  }
  Future<void> updateNote(Note note) async {
    // Implement logic to update the note securely
  }
  Future<List<Note>> getAllNotes() async {
    // Implement logic to retrieve all notes securely
    return [];
  }
}
