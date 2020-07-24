import 'package:hive/hive.dart';

part 'scorebook_model.g.dart';

@HiveType(typeId: 0)
class ScorebookModel extends HiveObject {

  /// 記録日時
  @HiveField(0)
  DateTime gameDatetime;

  /// メンバーの情報
  @HiveField(1)
  List<MemberModel> members;

  /// 局ごとの点数
  @HiveField(2)
  List<GameScoreModel> gameScores;

  /// ウマ1-4
  @HiveField(3)
  int uma14;

  /// ウマ2-3
  @HiveField(4)
  int uma23;

  /// ヤキトリ
  @HiveField(5)
  int yaki;

  /// トビ
  @HiveField(6)
  int tobi;


}

@HiveType(typeId: 1)
class MemberModel extends HiveObject {

  /// メンバー識別番号
  @HiveField(0)
  int id;

  /// メンバー名
  @HiveField(1)
  String name;
}


@HiveType(typeId: 2)
class GameScoreModel extends HiveObject {

  /// 回数
  @HiveField(0)
  int gameCount;

  @HiveField(1)
  List<MemberScoreModel> memberScores;
}

@HiveType(typeId: 3)
class MemberScoreModel extends HiveObject {

  /// メンバー情報
  @HiveField(0)
  MemberModel member;

  /// 素点
  @HiveField(1)
  int score = 0;

  /// ヤキトリ
  @HiveField(2)
  bool yaki = false;

  /// 計算後点
  @HiveField(3)
  int calcScore = 0;

  /// 順位
  @HiveField(4)
  int rank = 0;

}


