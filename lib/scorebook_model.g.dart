// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scorebook_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScorebookModelAdapter extends TypeAdapter<ScorebookModel> {
  @override
  final typeId = 0;

  @override
  ScorebookModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScorebookModel()
      ..gameDatetime = fields[0] as DateTime
      ..members = (fields[1] as List)?.cast<MemberModel>()
      ..gameScores = (fields[2] as List)?.cast<GameScoreModel>()
      ..uma14 = fields[3] as int
      ..uma23 = fields[4] as int
      ..yaki = fields[5] as int
      ..tobi = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, ScorebookModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.gameDatetime)
      ..writeByte(1)
      ..write(obj.members)
      ..writeByte(2)
      ..write(obj.gameScores)
      ..writeByte(3)
      ..write(obj.uma14)
      ..writeByte(4)
      ..write(obj.uma23)
      ..writeByte(5)
      ..write(obj.yaki)
      ..writeByte(6)
      ..write(obj.tobi);
  }
}

class MemberModelAdapter extends TypeAdapter<MemberModel> {
  @override
  final typeId = 1;

  @override
  MemberModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberModel()
      ..id = fields[0] as int
      ..name = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, MemberModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }
}

class GameScoreModelAdapter extends TypeAdapter<GameScoreModel> {
  @override
  final typeId = 2;

  @override
  GameScoreModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameScoreModel()
      ..gameCount = fields[0] as int
      ..memberScores = (fields[1] as List)?.cast<MemberScoreModel>();
  }

  @override
  void write(BinaryWriter writer, GameScoreModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.gameCount)
      ..writeByte(1)
      ..write(obj.memberScores);
  }
}

class MemberScoreModelAdapter extends TypeAdapter<MemberScoreModel> {
  @override
  final typeId = 3;

  @override
  MemberScoreModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemberScoreModel()
      ..member = fields[0] as MemberModel
      ..score = fields[1] as int
      ..yaki = fields[2] as bool
      ..calcScore = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, MemberScoreModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.member)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.yaki)
      ..writeByte(3)
      ..write(obj.calcScore);
  }
}
