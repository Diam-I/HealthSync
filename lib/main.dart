import 'package:flutter/material.dart';
import 'package:healthsync/features/notes/services/note_service.dart';
import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/features/patient/pages/patient_page.dart';
import 'package:healthsync/models/note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthsync/enums/note_category.dart';
import 'package:healthsync/features/patient/services/patient_service.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/models/document.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Hive database //
  await Hive.initFlutter();
  // Register the DocumentAdapter for Hive //
  //Hive.registerAdapter(DocumentAdapter());
  // Register the NoteAdapter for Hive //
  Hive.registerAdapter(NoteAdapter());
  // Register the NoteCategoryAdapter for Hive //
  Hive.registerAdapter(NoteCategoryAdapter());
  // Register the PatientAdapter for Hive //
  Hive.registerAdapter(PatientAdapter());
  // Initialize the encryption service and storage service //
  final encryptionService = EncryptionService();
  final encryptionKey = await encryptionService.generateAESKey();
  final storageNotes = HiveStorageServices<Note>('notes');
  final storagePatient = HiveStorageServices<Patient>('patients');
  final storageDocuments = HiveStorageServices<Document>('documents');
  await storageNotes.init(encryptionKey);
  await storagePatient.init(encryptionKey);
  await storageDocuments.init(encryptionKey);

  // Initialize the note service with encryption and storage //
  final noteService = NoteService(
    encryptionService: encryptionService,
    storage: storageNotes,
  );
  // Initialize the patient service //
  final patientService = PatientService(
    storage: storagePatient,
    encryptionService: encryptionService,
  );
}

class HealthSyncApp extends StatelessWidget {
  final NoteService noteService;
  final PatientService patientService;
  const HealthSyncApp({
    super.key,
    required this.noteService,
    required this.patientService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PatientPage(
        patientService: patientService,
        noteService: noteService,
      ),
    );
  }
}
