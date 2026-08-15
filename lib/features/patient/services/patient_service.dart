import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/core/security/encryption_service.dart';

class PatientService {
  final HiveStorageServices<Patient> storage;
  final EncryptionService encryptionService;

  PatientService({required this.storage, required this.encryptionService});

  Future<void> _checkSecurity() async {
    if (!storage.isOpen) {
      throw Exception("Storage not initialized");
    }
    //final authenticated = await encryptionService.authenticate();

    //if (!authenticated) {
    //throw Exception("Authentication failed");
    //}
  }

  // Display patient informations //
  Future<Patient?> getPatient(Patient patient) async {
    await _checkSecurity();
    return storage.getData(patient.id);
  }

  // Modify patient informations //
  Future<void> updatePatient(Patient patient) async {
    await _checkSecurity();
    await storage.saveData(patient.id, patient);
  }

  // Delete patient informations //
  Future<void> deletePatient(Patient patient) async {
    await _checkSecurity();
    await storage.deleteData(patient.id);
  }

  // Add patient informations //
  Future<void> addPatient(Patient patient) async {
    await _checkSecurity();
    await storage.saveData(patient.id, patient);
  }

  // Retrieve all patients securely using encryption and storage //
  Future<List<Patient>> getAllPatients() async {
    await _checkSecurity();
    return storage.getAllData();
  }

  // Retrieve patient by ID securely using encryption and storage //
  Future<Patient?> getPatientById(String id) async {
    await _checkSecurity();
    return storage.getData(id);
  }
}
