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
      body: fields[5] as String,
      cities: (fields[3] as List).cast<String>(),
      categories: (fields[4] as List).cast<String>(),
      urlImages: (fields[6] as List).cast<String>(),
      videoUrl: fields[21] as String?,
      type: fields[10] as String,
      status: fields[11] as String,
      lastUpdated: fields[26] as DateTime?,
      author: fields[7] as String,
      createdBy: fields[8] as String,
      createdAt: fields[9] as DateTime,
      validatedBy: fields[12] as String?,
      validatedByName: fields[30] as String?,
      validatedAt: fields[13] as DateTime?,
      validatedObservation: fields[19] as String?,
      rejectedBy: fields[23] as String?,
      rejectedAt: fields[24] as DateTime?,
      rejectedObservation: fields[25] as String?,
      editedAt: fields[15] as DateTime?,
      excludedBy: fields[16] as String?,
      excludedAt: fields[17] as DateTime?,
      excludedObservation: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NewsModel obj) {
    writer
      ..writeByte(25)
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
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(21)
      ..write(obj.videoUrl)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(26)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.author)
      ..writeByte(8)
      ..write(obj.createdBy)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.validatedBy)
      ..writeByte(30)
      ..write(obj.validatedByName)
      ..writeByte(13)
      ..write(obj.validatedAt)
      ..writeByte(19)
      ..write(obj.validatedObservation)
      ..writeByte(23)
      ..write(obj.rejectedBy)
      ..writeByte(24)
      ..write(obj.rejectedAt)
      ..writeByte(25)
      ..write(obj.rejectedObservation)
      ..writeByte(15)
      ..write(obj.editedAt)
      ..writeByte(16)
      ..write(obj.excludedBy)
      ..writeByte(17)
      ..write(obj.excludedAt)
      ..writeByte(20)
      ..write(obj.excludedObservation);
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
