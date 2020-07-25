import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_scorebook/scorebook_model.dart';
import 'package:provider/provider.dart';

class ViewScore extends StatelessWidget {

  /// インプットパラメータ
  //final ScorebookModel model = null;

  //InputScore(this.model);

  /// 最初のデータ
  ViewScoreModel _initData(ScorebookModel scorebookModel, GameScoreModel gameScoreModel) {

    // メンバー並び替え
    List<MemberModel> members = scorebookModel.members;
    members.sort((m1, m2) => m1.id.compareTo(m2.id));

    // メンバーのデータ作成
    List<MemberScoreInputModel> memberScores = members.map((e) {
      MemberScoreModel memberScoreModel = gameScoreModel.memberScores.firstWhere((element) => e.id == element.member.id);
      return MemberScoreInputModel()
        ..memberId = e.id
        ..yaki = memberScoreModel.yaki
        ..name = e.name
        ..score = memberScoreModel.score;
    }).toList();

    ViewScoreModel viewScoreModel = ViewScoreModel()
      ..memberScores = memberScores;

    // 更新用に保存
    viewScoreModel._scorebookModel = scorebookModel;

    return viewScoreModel;
  }

  /// 入力保存確認
  void _confirmDeleteScore(BuildContext context, ViewScoreModel viewScoreModel, GameScoreModel gameScoreModel) {
    // 一応確認
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('削除してよろしいですか？'),
          actions: <Widget>[
            FlatButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.pop(context);
                _deleteScore(context, viewScoreModel, gameScoreModel);
              },
            ),
            FlatButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// 入力保存
  void _deleteScore(BuildContext context, ViewScoreModel viewScoreModel, GameScoreModel gameScoreModel) {

    ScorebookModel scorebookModel = viewScoreModel.scorebookModel;
    scorebookModel.gameScores.remove(gameScoreModel);

    var box = Hive.box<ScorebookModel>("mahjong_scorebook");

    box.put(scorebookModel.key, scorebookModel);

    Navigator.pop(context, scorebookModel);

  }

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    ScorebookModel scorebookModel = args['scorebookModel'];
    GameScoreModel gameScoreModel = args['gameScoreModel'];

    return ChangeNotifierProvider<ViewScoreModel>(
      create: (context) => _initData(scorebookModel, gameScoreModel),
      child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // キーボード隠す
          child: Consumer<ViewScoreModel>(
            builder: (context, model, child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('点数入力'),
                ),
                body: Form(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                            itemCount:
                              model.memberScores != null ? model.memberScores.length : 0,
                            itemBuilder: (context, int index) {
                              var memberScore = model.memberScores[index];
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                  bottom: BorderSide(color: Colors.black38),
                                )),
                                child: ListTile(
                                  subtitle: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          '${memberScore.name}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${memberScore.score}',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text("ヤキトリ"),
                                            Checkbox(
                                              value: memberScore.yaki,
                                              onChanged: (value) {},
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                // 入力登録
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _confirmDeleteScore(context, model, gameScoreModel);
                  },
                  child: Icon(Icons.delete_forever),
                ),
              );
            }
          ),
        ),
    );
  }
}

/// 入力データ
class ViewScoreModel extends ChangeNotifier {
  /// 合計
  int _total = 0;

  /// 10満点の差額
  int _diff10 = 0;

  /// メンバーごとの入力値
  List<MemberScoreInputModel> _memberScores = [];

  /// 対局データ（保存用）
  ScorebookModel _scorebookModel;

  ScorebookModel get scorebookModel => _scorebookModel;

  set scorebookModel(ScorebookModel value) {
    _scorebookModel = value;
  }

  List<MemberScoreInputModel> get memberScores => _memberScores;

  set memberScores(List<MemberScoreInputModel> value) {
    _memberScores = value;
    notifyListeners();
  }

  int get total => _total;

  set total(int value) {
    _total = value;
    notifyListeners();
  }

  int get diff10 => _diff10;

  set diff10(int value) {
    _diff10 = value;
    notifyListeners();
  }
}

/// メンバーごとの入力値
class MemberScoreInputModel extends ChangeNotifier {
  /// メンツID
  int _memberId;

  /// メンバー名
  String _name;

  /// プラスマイナス
  String _plusMinus = '+';

  /// 得点
  int _score;

  /// ヤキトリチェック
  bool _yaki;

  int get memberId => _memberId;

  set memberId(int value) {
    _memberId = value;
    notifyListeners();
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get plusMinus => _plusMinus;

  set plusMinus(String value) {
    _plusMinus = value;
    notifyListeners();
  }

  int get score => _score;

  set score(int value) {
    _score = value;
    notifyListeners();
  }

  bool get yaki => _yaki;

  set yaki(bool value) {
    _yaki = value;
    notifyListeners();
  }
}
