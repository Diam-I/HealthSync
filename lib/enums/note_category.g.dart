// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteCategoryAdapter extends TypeAdapter<NoteCategory> {
  @override
  final int typeId = 1;

  @override
  NoteCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteCategory.consultation;
      case 1:
        return NoteCategory.symptome;
      case 2:
        return NoteCategory.traitement;
      case 3:
        return NoteCategory.maladie;
      case 4:
        return NoteCategory.personnel;
      case 5:
        return NoteCategory.autre;
      default:
        return NoteCategory.consultation;
    }
  }

  @override
  void write(BinaryWriter writer, NoteCategory obj) {
    switch (obj) {
      case NoteCategory.consultation:
        writer.writeByte(0);
        break;
      case NoteCategory.symptome:
        writer.writeByte(1);
        break;
      case NoteCategory.traitement:
        writer.writeByte(2);
        break;
      case NoteCategory.maladie:
        writer.writeByte(3);
        break;
      case NoteCategory.personnel:
        writer.writeByte(4);
        break;
      case NoteCategory.autre:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
