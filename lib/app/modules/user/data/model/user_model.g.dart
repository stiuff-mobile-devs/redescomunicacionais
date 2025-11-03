// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String?,
      email: fields[2] as String,
      urlImage: fields[3] as String?,
      role: fields[4] as String,
      createdAt: fields[5] as DateTime?,
      roleUpdatedAt: fields[6] as DateTime?,
      roleUpdatedBy: fields[7] as String?,
      status: fields[8] as String,
      statusUpdatedAt: fields[9] as DateTime?,
      statusUpdatedBy: fields[10] as String?,
      statusObservation: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.urlImage)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.roleUpdatedAt)
      ..writeByte(7)
      ..write(obj.roleUpdatedBy)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.statusUpdatedAt)
      ..writeByte(10)
      ..write(obj.statusUpdatedBy)
      ..writeByte(11)
      ..write(obj.statusObservation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
