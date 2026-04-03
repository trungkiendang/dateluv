// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoupleProfileAdapter extends TypeAdapter<CoupleProfile> {
  @override
  final int typeId = 0;

  @override
  CoupleProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoupleProfile(
      person1Name: fields[0] as String,
      person2Name: fields[1] as String,
      person1PhotoPath: fields[2] as String?,
      person2PhotoPath: fields[3] as String?,
      startDate: fields[4] as DateTime,
      backgroundImagePath: fields[5] as String?,
      isDarkMode: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CoupleProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.person1Name)
      ..writeByte(1)
      ..write(obj.person2Name)
      ..writeByte(2)
      ..write(obj.person1PhotoPath)
      ..writeByte(3)
      ..write(obj.person2PhotoPath)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.backgroundImagePath)
      ..writeByte(6)
      ..write(obj.isDarkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoupleProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
