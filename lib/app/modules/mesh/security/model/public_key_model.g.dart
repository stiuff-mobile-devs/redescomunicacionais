// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_key_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublicKeyModelAdapter extends TypeAdapter<PublicKeyModel> {
  @override
  final int typeId = 4;

  @override
  PublicKeyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PublicKeyModel(
      id: fields[0] as String?,
      email: fields[1] as String?,
      publicKey: fields[2] as String?,
      oldPublicKeys: (fields[3] as List?)?.cast<String>(),
      cities: (fields[4] as List?)?.cast<String>(),
      createdAt: fields[5] as DateTime?,
      lastUpdated: fields[6] as DateTime?,
      revocationInfo: fields[7] as RevocationInfo?,
    );
  }

  @override
  void write(BinaryWriter writer, PublicKeyModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.publicKey)
      ..writeByte(3)
      ..write(obj.oldPublicKeys)
      ..writeByte(4)
      ..write(obj.cities)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.revocationInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicKeyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RevocationInfoAdapter extends TypeAdapter<RevocationInfo> {
  @override
  final int typeId = 12;

  @override
  RevocationInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RevocationInfo(
      isRevoked: fields[0] as bool?,
      revokedAt: fields[1] as DateTime?,
      revokedBy: fields[2] as String?,
      revocationReason: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RevocationInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isRevoked)
      ..writeByte(1)
      ..write(obj.revokedAt)
      ..writeByte(2)
      ..write(obj.revokedBy)
      ..writeByte(3)
      ..write(obj.revocationReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevocationInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
