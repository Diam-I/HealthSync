import 'package:flutter/material.dart';
import 'package:healthsync/features/notes/pages/notes_page.dart';
import 'package:healthsync/features/notes/services/note_service.dart';
import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/models/note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthsync/enums/note_category.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Hive database //
  await Hive.initFlutter();
  // Register the NoteAdapter for Hive //
  Hive.registerAdapter(NoteAdapter());
  // Register the NoteCategoryAdapter for Hive //
  Hive.registerAdapter(NoteCategoryAdapter());
  // Initialize Hive for Flutter //
  await Hive.initFlutter();
  // Initialize the encryption service and storage service //
  final encryptionService = EncryptionService();

  final encryptionKey = await encryptionService.generateAESKey();
  final storage = HiveStorageServices<Note>('notes');
  await storage.init(encryptionKey);

  // Initialize the note service with encryption and storage //
  final noteService = NoteService(
    encryptionService: encryptionService,
    storage: storage,
  );

  // Run the app with the note service //
  runApp(HealthSyncApp(noteService: noteService));
}

class HealthSyncApp extends StatelessWidget {
  final NoteService noteService;
  const HealthSyncApp({super.key, required this.noteService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      home: NotesPage(noteService: noteService),
    );
  }
}
