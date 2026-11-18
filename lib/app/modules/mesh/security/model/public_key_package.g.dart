// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_key_package.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublicKeyPackageAdapter extends TypeAdapter<PublicKeyPackage> {
  @override
  final int typeId = 3;

  @override
  PublicKeyPackage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PublicKeyPackage(
      publicKeys: fields[4] == null
          ? {}
          : (fields[4] as Map).map((dynamic k, dynamic v) =>
              MapEntry(k as String, (v as List).cast<String>())),
      sender: fields[1] as String,
      timestamp: fields[2] as DateTime,
      signature: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PublicKeyPackage obj) {
    writer
      ..writeByte(4)
      ..writeByte(4)
      ..write(obj.publicKeys)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.signature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicKeyPackageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
