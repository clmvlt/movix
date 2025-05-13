// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Spooler.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpoolerAdapter extends TypeAdapter<Spooler> {
  @override
  final int typeId = 0;

  @override
  Spooler read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Spooler(
      url: fields[0] as String,
      headers: (fields[1] as Map).cast<String, String>(),
      body: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Spooler obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.headers)
      ..writeByte(2)
      ..write(obj.body);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpoolerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
