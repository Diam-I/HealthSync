import 'package:healthsync/enums/noteCaregory.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteCategory category;
  final List<String> tags;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.tags = const [],
  });

  // Create a copy of the Note with updated fields //
  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    NoteCategory? category,
    List<String>? tags,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }

  // Convert JSON to Note object //
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: NoteCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Convert Note object to JSON //
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category.name,
      'tags': tags,
    };
  }
}
