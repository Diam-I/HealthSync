import 'package:flutter_test/flutter_test.dart';
import 'package:healthsync/models/patient.dart';

void main() {
  group('Patient', () {
    final patient = Patient(
      id: '1',
      firstName: 'Jean',
      lastName: 'Dupont',
      phone: '0612345678',
      email: 'jean.dupont@example.com',
      address: '10 rue de Paris',
      gender: 'Homme',
      dateOfBirth: '01/01/1990',
      height: '180',
      weight: '75',
      bloodType: 'O+',
    );

    test('should create a valid Patient', () {
      expect(patient.id, '1');
      expect(patient.firstName, 'Jean');
      expect(patient.lastName, 'Dupont');
      expect(patient.phone, '0612345678');
      expect(patient.email, 'jean.dupont@example.com');
      expect(patient.address, '10 rue de Paris');
      expect(patient.gender, 'Homme');
      expect(patient.dateOfBirth, '01/01/1990');
      expect(patient.height, '180');
      expect(patient.weight, '75');
      expect(patient.bloodType, 'O+');
    });

    test('toJson should correctly convert Patient to JSON', () {
      final json = patient.toJson();

      expect(json['id'], '1');
      expect(json['firstName'], 'Jean');
      expect(json['lastName'], 'Dupont');
      expect(json['phone'], '0612345678');
      expect(json['email'], 'jean.dupont@example.com');
      expect(json['address'], '10 rue de Paris');
      expect(json['gender'], 'Homme');
      expect(json['dateOfBirth'], '01/01/1990');
      expect(json['height'], '180');
      expect(json['weight'], '75');
      expect(json['bloodType'], 'O+');
    });

    test('fromJson should correctly create a Patient from JSON', () {
      final json = {
        'id': '1',
        'firstName': 'Jean',
        'lastName': 'Dupont',
        'phone': '0612345678',
        'email': 'jean.dupont@example.com',
        'address': '10 rue de Paris',
        'gender': 'Homme',
        'dateOfBirth': '01/01/1990',
        'height': '180',
        'weight': '75',
        'bloodType': 'O+',
      };

      final result = Patient.fromJson(json);

      expect(result.id, '1');
      expect(result.firstName, 'Jean');
      expect(result.lastName, 'Dupont');
      expect(result.phone, '0612345678');
      expect(result.email, 'jean.dupont@example.com');
      expect(result.address, '10 rue de Paris');
      expect(result.gender, 'Homme');
      expect(result.dateOfBirth, '01/01/1990');
      expect(result.height, '180');
      expect(result.weight, '75');
      expect(result.bloodType, 'O+');
    });

    test('JSON serialization cycle should preserve all data', () {
      final result = Patient.fromJson(patient.toJson());

      expect(result.toJson(), patient.toJson());
    });

    test('fromJson should create a different Patient instance', () {
      final result = Patient.fromJson(patient.toJson());

      expect(identical(result, patient), false);
    });

    test('toJson should contain exactly the expected fields', () {
      final json = patient.toJson();

      expect(
        json.keys,
        containsAll([
          'id',
          'firstName',
          'lastName',
          'phone',
          'email',
          'address',
          'gender',
          'dateOfBirth',
          'height',
          'weight',
          'bloodType',
        ]),
      );

      expect(json.length, 11);
    });

    test('should preserve special characters', () {
      final specialPatient = Patient(
        id: 'patient-éè',
        firstName: 'Élise',
        lastName: 'Dûpont',
        phone: '0600000000',
        email: 'elise@example.com',
        address: '10 rue de l\'Église',
        gender: 'Femme',
        dateOfBirth: '15/08/1995',
        height: '165',
        weight: '60',
        bloodType: 'A+',
      );

      final result = Patient.fromJson(specialPatient.toJson());

      expect(result.firstName, 'Élise');
      expect(result.lastName, 'Dûpont');
      expect(result.address, '10 rue de l\'Église');
    });
  });
}
