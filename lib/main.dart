import 'package:flutter/material.dart';
import 'package:healthsync/features/notes/pages/notes_page.dart';
import 'package:healthsync/features/notes/services/note_service.dart';
import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/models/note.dart';

void main() {
  runApp(const HealthSyncApp());
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});
  NoteService get noteService => NoteService(
    encryptionService: EncryptionService(),
    storage: HiveStorageServices<Note>('notes'),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      home: NotesPage(noteService: noteService),
    );
  }
}
