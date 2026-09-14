import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/features/patient/services/patient_service.dart';
import 'package:healthsync/models/patient.dart';

void main() {
  late HiveStorageServices<Patient> storage;
  late PatientService patientService;
  late EncryptionService encryptionService;

  final encryptionKey = Uint8List.fromList(List.generate(32, (index) => index));

  Patient createPatient({
    String id = '1',
    String firstName = 'Jean',
    String lastName = 'Dupont',
  }) {
    return Patient(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: '0612345678',
      email: 'jean.dupont@example.com',
      address: '10 rue de Paris',
      gender: 'Homme',
      dateOfBirth: '01/01/1990',
      height: '180',
      weight: '75',
      bloodType: 'O+',
    );
  }

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('healthsync_test_');

    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PatientAdapter());
    }

    encryptionService = EncryptionService();
  });

  setUp(() async {
    storage = HiveStorageServices<Patient>(
      'test_patients_${DateTime.now().microsecondsSinceEpoch}',
    );

    await storage.init(encryptionKey);

    patientService = PatientService(
      storage: storage,
      encryptionService: encryptionService,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PatientService - addPatient', () {
    test('should add a patient', () async {
      final patient = createPatient();

      await patientService.addPatient(patient);

      final result = await patientService.getPatientById(patient.id);

      expect(result, isNotNull);
      expect(result!.id, patient.id);
      expect(result.firstName, patient.firstName);
      expect(result.lastName, patient.lastName);
    });

    test('should add multiple patients', () async {
      final patient1 = createPatient(id: '1');
      final patient2 = createPatient(id: '2');
      final patient3 = createPatient(id: '3');

      await patientService.addPatient(patient1);
      await patientService.addPatient(patient2);
      await patientService.addPatient(patient3);

      final result = await patientService.getAllPatients();

      expect(result.length, 3);
    });
  });

  group('PatientService - getPatient', () {
    test('should retrieve a patient', () async {
      final patient = createPatient();

      await patientService.addPatient(patient);

      final result = await patientService.getPatient(patient);

      expect(result, isNotNull);
      expect(result!.id, patient.id);
      expect(result.firstName, patient.firstName);
      expect(result.lastName, patient.lastName);
    });

    test('should return null for a patient that does not exist', () async {
      final patient = createPatient(id: 'unknown');

      final result = await patientService.getPatient(patient);

      expect(result, isNull);
    });
  });

  group('PatientService - getPatientById', () {
    test('should retrieve a patient by id', () async {
      final patient = createPatient();

      await patientService.addPatient(patient);

      final result = await patientService.getPatientById('1');

      expect(result, isNotNull);
      expect(result!.id, '1');
    });

    test('should return null for an unknown id', () async {
      final result = await patientService.getPatientById('unknown');

      expect(result, isNull);
    });
  });

  group('PatientService - updatePatient', () {
    test('should update an existing patient', () async {
      final patient = createPatient();

      await patientService.addPatient(patient);

      final updatedPatient = Patient(
        id: patient.id,
        firstName: 'Pierre',
        lastName: 'Martin',
        phone: '0699999999',
        email: 'pierre.martin@example.com',
        address: '20 rue de Toulouse',
        gender: 'Homme',
        dateOfBirth: '02/02/1992',
        height: '182',
        weight: '80',
        bloodType: 'A+',
      );

      await patientService.updatePatient(updatedPatient);

      final result = await patientService.getPatientById(patient.id);

      expect(result, isNotNull);
      expect(result!.firstName, 'Pierre');
      expect(result.lastName, 'Martin');
      expect(result.phone, '0699999999');
      expect(result.email, 'pierre.martin@example.com');
      expect(result.address, '20 rue de Toulouse');
      expect(result.bloodType, 'A+');
    });

    test('should be able to update all patient information', () async {
      final patient = createPatient();

      await patientService.addPatient(patient);

      final updatedPatient = Patient(
        id: patient.id,
        firstName: 'Alice',
        lastName: 'Durand',
        phone: '0611111111',
        email: 'alice@example.com',
        address: '1 avenue de Paris',
        gender: 'Femme',
        dateOfBirth: '10/10/2000',
        height: '170',
        weight: '65',
        bloodType: 'B+',
      );

      await patientService.updatePatient(updatedPatient);

      final result = await patientService.getPatientById(patient.id);

      expect(result!.firstName, 'Alice');
      expect(result.lastName, 'Durand');
      expect(result.phone, '0611111111');
      expect(result.email, 'alice@example.com');
      expect(result.address, '1 avenue de Paris');
      expect(result.gender, 'Femme');
      expect(result.dateOfBirth, '10/10/2000');
      expect(result.height, '170');
      expect(result.weight, '65');
      expect(result.bloodType, 'B+');
    });
  });

  group('PatientService - deletePatient', () {
    test('should delete a patient', () async {
      final patient = createPatient();

      await patientService.addPatient(patient);

      await patientService.deletePatient(patient);

      final result = await patientService.getPatientById(patient.id);

      expect(result, isNull);
    });
  });

  group('PatientService - getAllPatients', () {
    test('should return an empty list when there are no patients', () async {
      final result = await patientService.getAllPatients();

      expect(result, isEmpty);
    });

    test('should return all patients', () async {
      final patient1 = createPatient(id: 'patient-1');
      final patient2 = createPatient(id: 'patient-2');

      await patientService.addPatient(patient1);
      await patientService.addPatient(patient2);

      final result = await patientService.getAllPatients();

      expect(result.length, 2);
      expect(
        result.map((patient) => patient.id),
        containsAll(['patient-1', 'patient-2']),
      );
    });
  });

  group('PatientService - storage security', () {
    test('should reject operations when storage is not initialized', () async {
      final uninitializedStorage = HiveStorageServices<Patient>(
        'uninitialized_patients',
      );

      final service = PatientService(
        storage: uninitializedStorage,
        encryptionService: encryptionService,
      );

      expect(() => service.getAllPatients(), throwsException);
    });
  });
}
