import 'package:healthsync/models/Doctor.dart';

class Document {
  final String id;
  final String title;
  final DateTime date;
  final Doctor doctor;
  final String category;
  final String path;
  final String description;
  final String report;

  Document({
    required this.id,
    required this.title,
    required this.date,
    required this.doctor,
    required this.category,
    required this.path,
    required this.description,
    required this.report,
  });

  // Convert JSON to Note object //
  Document.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      date = DateTime.parse(json['date']),
      doctor = Doctor.fromJson(json['doctor']),
      category = json['category'],
      path = json['path'],
      description = json['description'],
      report = json['report'];

  // Convert Note object to JSON //
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'doctor': doctor.toJson(),
    'category': category,
    'path': path,
    'description': description,
    'report': report,
  };
}
