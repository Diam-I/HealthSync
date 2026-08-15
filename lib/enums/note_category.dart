import 'package:hive/hive.dart';
part 'note_category.g.dart';

@HiveType(typeId: 1)
enum NoteCategory {
  @HiveField(0)
  consultation,
  @HiveField(1)
  symptome,
  @HiveField(2)
  traitement,
  @HiveField(3)
  maladie,
  @HiveField(4)
  personnel,
  @HiveField(5)
  autre,
}
