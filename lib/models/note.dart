import 'package:healthsync/enums/note_category.dart';
import 'package:hive/hive.dart';
part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final DateTime createdAt;
  @HiveField(4)
  final DateTime updatedAt;
  @HiveField(5)
  final NoteCategory category;
  @HiveField(6)
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
    if (json['id'] == null ||
        json['id'] == '' ||
        json['title'] == null ||
        json['title'] == '' ||
        json['content'] == null ||
        json['content'] == '' ||
        json['createdAt'] == null ||
        json['createdAt'] == '' ||
        json['updatedAt'] == null ||
        json['updatedAt'] == '' ||
        json['category'] == null ||
        json['category'] == '') {
      throw ArgumentError('Missing required fields in JSON');
    }
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
