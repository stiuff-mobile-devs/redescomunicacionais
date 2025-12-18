// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsModelAdapter extends TypeAdapter<NewsModel> {
  @override
  final int typeId = 1;

  @override
  NewsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsModel(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String?,
      cities: (fields[3] as List).cast<String>(),
      categories: (fields[4] as List).cast<String>(),
      body: fields[5] as String,
      urlImages: (fields[6] as List).cast<String>(),
      author: fields[7] as String,
      createdBy: fields[8] as String,
      createdAt: fields[9] as DateTime,
      type: fields[10] as String,
      status: fields[11] as String,
      validatedBy: fields[12] as String?,
      validatedAt: fields[13] as DateTime?,
      editedBy: fields[14] as String?,
      editedAt: fields[15] as DateTime?,
      excluedBy: fields[16] as String?,
      excluedAt: fields[17] as DateTime?,
      editedObservation: fields[18] as String?,
      validatedObservation: fields[19] as String?,
      excludedObservation: fields[20] as String?,
      videoUrl: fields[21] as String?,
      validatedByName: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NewsModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.cities)
      ..writeByte(4)
      ..write(obj.categories)
      ..writeByte(5)
      ..write(obj.body)
      ..writeByte(6)
      ..write(obj.urlImages)
      ..writeByte(7)
      ..write(obj.author)
      ..writeByte(8)
      ..write(obj.createdBy)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.validatedBy)
      ..writeByte(13)
      ..write(obj.validatedAt)
      ..writeByte(14)
      ..write(obj.editedBy)
      ..writeByte(15)
      ..write(obj.editedAt)
      ..writeByte(16)
      ..write(obj.excluedBy)
      ..writeByte(17)
      ..write(obj.excluedAt)
      ..writeByte(18)
      ..write(obj.editedObservation)
      ..writeByte(19)
      ..write(obj.validatedObservation)
      ..writeByte(20)
      ..write(obj.excludedObservation)
      ..writeByte(21)
      ..write(obj.videoUrl)
      ..writeByte(22)
      ..write(obj.validatedByName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
