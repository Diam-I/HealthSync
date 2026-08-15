import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/models/note.dart';
import 'package:healthsync/enums/note_category.dart';

class NoteService {
  final EncryptionService encryptionService;
  final HiveStorageServices<Note> storage;

  NoteService({required this.encryptionService, required this.storage});

  Future<void> _checkSecurity() async {
    if (!storage.isOpen) {
      throw Exception("Storage not initialized");
    }
    final authenticated = await encryptionService.authenticate();

    if (!authenticated) {
      throw Exception("Authentication failed");
    }
  }

  // Add note securely using encryption and storage //
  Future<void> addNote(Note note) async {
    await _checkSecurity();

    if (note.title.trim().isEmpty) {
      throw ArgumentError('Note title cannot be empty');
    }
    if (note.content.trim().isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }

    final existing = storage.getData(note.id);

    if (existing != null) {
      throw Exception("A note with this id already exists");
    }
    await storage.saveData(note.id, note);
  }

  // Retrieve note securely using encryption and storage //
  Future<Note?> getNote(String id) async {
    await _checkSecurity();
    if (id.trim().isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    } else {
      return storage.getData(id);
    }
  }

  // Delete note securely using encryption and storage //
  Future<void> deleteNote(String id) async {
    await _checkSecurity();
    if (id.trim().isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    final existing = storage.getData(id);
    if (existing == null) {
      throw ArgumentError("Note not found");
    }
    await storage.deleteData(id);
  }

  // Update note securely using encryption and storage //
  Future<void> updateNote(Note note) async {
    await _checkSecurity();

    if (note.title.trim().isEmpty) {
      throw ArgumentError('Note title cannot be empty');
    }
    if (note.content.trim().isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    final existing = storage.getData(note.id);

    if (existing == null) {
      throw ArgumentError("Note not found");
    }
    await storage.saveData(note.id, note.copyWith(updatedAt: DateTime.now()));
  }

  // Retrieve all notes securely using encryption and storage //
  Future<List<Note>> getAllNotes() async {
    await _checkSecurity();
    return await storage.getAllData();
  }

  // Search notes securely using encryption and storage //
  Future<List<Note>> searchNotes(String keyword) async {
    await _checkSecurity();
    final notes = await getAllNotes();
    if (keyword.trim().isEmpty) {
      return [];
    }
    return notes.where((note) {
      return note.title.toLowerCase().contains(keyword.toLowerCase()) ||
          note.content.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  // Retrieve notes by category securely using encryption and storage //
  Future<List<Note>> getNotesByCategory(NoteCategory category) async {
    await _checkSecurity();
    final notes = await getAllNotes();
    return notes.where((n) => n.category == category).toList();
  }

  // Retrieve notes sorted by date securely using encryption and storage //
  Future<List<Note>> getNotesSortedByDate() async {
    await _checkSecurity();

    final notes = await getAllNotes();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return notes;
  }
}
