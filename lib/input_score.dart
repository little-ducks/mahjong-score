import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_scorebook/scorebook_model.dart';
import 'package:provider/provider.dart';

class InputScore extends StatelessWidget {

  /// インプットパラメータ
  //final ScorebookModel model = null;

  //InputScore(this.model);

  /// 最初のデータ
  InputScoreModel _initData(ScorebookModel scorebookModel) {

    // メンバー並び替え
    List<MemberModel> members = scorebookModel.members;
    members.sort((m1, m2) => m1.id.compareTo(m2.id));

    // メンバーのデータ作成
    List<MemberScoreInputModel> memberScores = members.map((e) {
      return MemberScoreInputModel()
        ..memberId = e.id
        ..yaki = false
        ..name = e.name;
    }).toList();

    InputScoreModel inputScoreModel = InputScoreModel()
      ..memberScores = memberScores;

    // 更新用に保存
    inputScoreModel._scorebookModel = scorebookModel;

    return inputScoreModel;
  }

  /// 点数入力
  void _inputScore(InputScoreModel inputScoreModel, String e, int index) {
    MemberScoreInputModel memberInput = inputScoreModel.memberScores[index];
    memberInput.score = int.tryParse(memberInput.plusMinus + e);

    int wkTotal = 0;
    inputScoreModel.memberScores.forEach((element) {
      wkTotal = wkTotal + (element.score != null ? element.score : 0);
    });
    inputScoreModel.total = wkTotal;
    inputScoreModel.diff10 = 100000 - wkTotal;
  }

  /// プラスとマイナスを変更するボタン
  void _changeSign(InputScoreModel inputScoreModel, int index) {
    MemberScoreInputModel memberInput = inputScoreModel.memberScores[index];
    memberInput.plusMinus =
        ['+', '-'].firstWhere((element) => memberInput.plusMinus != element);

    // 再計算
    _inputScore(inputScoreModel, memberInput.score.toString(), index);
  }

  /// ヤキトリチェックボックス
  void _changeYaki(InputScoreModel inputScoreModel, bool e, int index) {
    inputScoreModel.memberScores[index].yaki = e;
    inputScoreModel.memberScores = inputScoreModel.memberScores;
  }

  /// 入力保存確認
  void _confirmSaveInputScore(BuildContext context, InputScoreModel inputScoreModel) {
    // 一応確認
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('保存してよろしいですか？'),
          content: Text(
            '合計点数:${inputScoreModel.total}',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.pop(context);
                _saveInputScore(context, inputScoreModel);
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
  void _saveInputScore(BuildContext context, InputScoreModel inputScoreModel) {

    ScorebookModel scorebookModel = inputScoreModel.scorebookModel;
    List<MemberModel> members = scorebookModel.members;

    // 得点順に並べ替え
    List<MemberScoreModel> memberScores = inputScoreModel.memberScores.map((e) {
      MemberScoreModel score = MemberScoreModel()
          ..member = members.firstWhere((mem) => mem.id == e.memberId)
          ..score = e.score
          ..yaki = e.yaki;

      // 1000点未満取得
      int u1000 = score.score % 1000;

      // 計算用2桁の数字作成
      int calcScore = score.score ~/ 1000;

      // 1000点未満があって、30000点未満の場合は切り上げ
      if (u1000 > 0 && e.score < 30000) {
        calcScore = calcScore + 1;
      }

      // 30000点返し
      calcScore = calcScore - 30;

      score.calcScore = calcScore;

      return score;
    }).toList();

    // 順位
    memberScores.sort((e1, e2) => e2.score.compareTo(e1.score));
    int rank = 1;
    memberScores.forEach((element) {
      element.rank = rank++;
    });

    // トップの人オカもってけ
    int oka = memberScores.map((e) => e.calcScore).reduce((value, element) => value + element);
    MemberScoreModel top = memberScores.firstWhere((element) => element.rank == 1);
    top.calcScore = top.calcScore + oka.abs();

    // ヤキトリとトビの精算
    int yakiPool = 0;
    int tobiPool = 0;

    // ヤキトリの人集合
    memberScores.where((element) => element.yaki).forEach((element) {
      // 自身がヤキトリの場合、ヤキトリ点を引いてためる
      int yaki = scorebookModel.yaki ~/ 1000;
      element.calcScore = element.calcScore - yaki;
      yakiPool = yakiPool + yaki;
    });

    // トビの人集合
    memberScores.where((element) => element.score < 0).forEach((element) {
      // 自身がトビの場合、ヤキトリ点を引いてためる
      int tobi = scorebookModel.tobi ~/ 1000;
      element.calcScore = element.calcScore - tobi;
      tobiPool = tobiPool + tobi;
    });

    // 配分ロジック
    var share = (int pool, bool test(MemberScoreModel element)) {

      // 配分
      if (pool > 0) {

        // 配分の人取得
        Iterable<MemberScoreModel> shares = memberScores.where(test);
        // 全員配分対象外、ないけどね普通
        if (shares.length == 0) {
          shares = memberScores.where((element) => true);
        }
        // ヤキトリ配分
        int shareScore = pool ~/ shares.length;
        shares.forEach((element) {
          element.calcScore = element.calcScore + shareScore;
        });
      }

    };

    // ヤキトリ配分
    share(yakiPool, (e) => !e.yaki);

    // トビ配分
    share(tobiPool, (e) => e.score >= 0);

    GameScoreModel gameScoreModel = GameScoreModel()
      ..memberScores = memberScores;

    if (scorebookModel.gameScores == null) {
      gameScoreModel.gameCount = 1;
      scorebookModel.gameScores = [gameScoreModel];
    } else {
      gameScoreModel.gameCount = scorebookModel.gameScores.length + 1;
      scorebookModel.gameScores.add(gameScoreModel);
    }


    var box = Hive.box<ScorebookModel>("mahjong_scorebook");

    box.put(scorebookModel.key, scorebookModel);

    memberScores.forEach((element) {
      print('${element.member.name} = ${element.calcScore} [${element.rank}]');
    });

    //Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {

    ScorebookModel scorebookModel = ModalRoute.of(context).settings.arguments;

    return ChangeNotifierProvider<InputScoreModel>(
      create: (context) => _initData(scorebookModel),
      child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // キーボード隠す
          child: Consumer<InputScoreModel>(
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
                                      FlatButton(
                                        child: Text(
                                          memberScore.plusMinus,
                                          style: TextStyle(
                                            fontSize: 30,
                                          ),
                                        ),
                                        onPressed: () {
                                          _changeSign(model, index);
                                        },
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: memberScore.name,
                                            hintText: 'ex.32100',
                                            border: InputBorder.none,
                                          ),
                                          inputFormatters: [
                                            WhitelistingTextInputFormatter
                                                .digitsOnly
                                          ],
                                          onChanged: (e) {
                                            _inputScore(model, e, index);
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text("ヤキトリ"),
                                            Checkbox(
                                                value: memberScore.yaki,
                                                onChanged: (e) {
                                                  _changeYaki(model, e, index);
                                                })
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black38,
                                    ),
                                    top: BorderSide(
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          "合計：",
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        width: double.infinity,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormat('###,##0').format(model.total),
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black38,
                                      ),
                                    ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          "10万差分：",
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        width: double.infinity,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormat('###,##0').format(model.diff10),
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 入力登録
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _confirmSaveInputScore(context, model);
                  },
                  child: Icon(Icons.save),
                ),
              );
            }
          ),
        ),
    );
  }
}

/// 入力データ
class InputScoreModel extends ChangeNotifier {
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
