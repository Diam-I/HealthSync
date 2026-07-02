import 'package:healthsync/models/Doctor.dart';

class Appointment {
  final String id;
  final DateTime date;
  final String time;
  final String location;
  final Doctor doctor;
  final String type;
  final String description;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.location,
    required this.doctor,
    required this.type,
    required this.description,
  });

  // Convert JSON to Appointment object //
  Appointment.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      date = DateTime.parse(json['date']),
      time = json['time'],
      location = json['location'],
      doctor = Doctor.fromJson(json['doctor']),
      type = json['type'],
      description = json['description'];

  // Convert Appointment object to JSON //
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'time': time,
    'location': location,
    'doctor': doctor.toJson(),
    'type': type,
    'description': description,
  };
}
