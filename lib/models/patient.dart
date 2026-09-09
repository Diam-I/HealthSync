import 'package:hive/hive.dart';
part 'patient.g.dart';

@HiveType(typeId: 2)
class Patient {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String email;
  @HiveField(5)
  final String address;
  @HiveField(6)
  final String gender;
  @HiveField(7)
  final String dateOfBirth;
  @HiveField(8)
  final String height;
  @HiveField(9)
  final String weight;
  @HiveField(10)
  final String bloodType;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    required this.bloodType,
  });

  // Convert JSON to Patient object //
  Patient.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      firstName = json['firstName'],
      lastName = json['lastName'],
      phone = json['phone'],
      email = json['email'],
      address = json['address'],
      gender = json['gender'],
      dateOfBirth = json['dateOfBirth'],
      height = json['height'],
      weight = json['weight'],
      bloodType = json['bloodType'];

  // Convert Patient object to JSON //
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'address': address,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'height': height,
    'weight': weight,
    'bloodType': bloodType,
  };
}
