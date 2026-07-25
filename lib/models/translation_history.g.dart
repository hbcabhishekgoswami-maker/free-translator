// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationHistoryAdapter extends TypeAdapter<TranslationHistory> {
  @override
  final int typeId = 0;

  @override
  TranslationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranslationHistory(
      originalText: fields[0] as String,
      translatedText: fields[1] as String,
      sourceLang: fields[2] as String,
      targetLang: fields[3] as String,
      timestamp: fields[4] as DateTime,
      type: fields[5] as String,
      isFavorite: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TranslationHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.originalText)
      ..writeByte(1)
      ..write(obj.translatedText)
      ..writeByte(2)
      ..write(obj.sourceLang)
      ..writeByte(3)
      ..write(obj.targetLang)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
