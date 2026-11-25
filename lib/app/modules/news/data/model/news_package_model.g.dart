// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_package_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsPackageModelAdapter extends TypeAdapter<NewsPackageModel> {
  @override
  final int typeId = 2;

  @override
  NewsPackageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsPackageModel(
      news: fields[0] as NewsModel?,
      signature: fields[1] as String?,
      email: fields[2] as String?,
      lastUpdated: fields[3] as DateTime?,
      isUploaded: fields[4] as bool?,
      id: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NewsPackageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.news)
      ..writeByte(1)
      ..write(obj.signature)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.isUploaded)
      ..writeByte(5)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsPackageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
