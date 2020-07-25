
import 'package:flutter/material.dart';
import 'package:mahjong_scorebook/scorebook_model.dart';
import 'package:provider/provider.dart';

class BattleScore extends StatelessWidget {

  /// 画面用モデル作成
  BattleScoreModel _initData(ScorebookModel scorebookModel) {
    BattleScoreModel battleScoreModel = BattleScoreModel();
    return _setData(scorebookModel, battleScoreModel);
  }

  /// 画面モデルにDBモデルを設定する
  BattleScoreModel _setData(ScorebookModel scorebookModel, BattleScoreModel battleScoreModel) {

    // メンバー名
    Map<int, String> memberNames = {};
    scorebookModel.members.forEach((element) {
      memberNames[element.id] = element.name;
    });

    // 対戦成績
    List<GameScoreModel> gameScoresDb = scorebookModel.gameScores??[];
    List<GameScoreListModel> gameScores = gameScoresDb.map((e) {

      // 得点
      Map<int, int> memberScores = {};
      e.memberScores.forEach((element) {
        memberScores[element.member.id] = element.calcScore;
      });

      GameScoreListModel gameScoreModel = GameScoreListModel()
        ..gameNo = e.gameCount
        ..memberScores = memberScores;

      return gameScoreModel;
    }).toList();

    battleScoreModel.memberNames = memberNames;
    battleScoreModel.gameScores = gameScores;

    return battleScoreModel;
  }

  /// テーブル行の作成
  List<DataRow> _createDataRow(BuildContext context, BattleScoreModel battleScoreModel, ScorebookModel scorebookModel) {

    Map<int, String> memberNames = battleScoreModel.memberNames;
    List<GameScoreListModel> gameScores = battleScoreModel.gameScores;

    var handleOnTap = (GameScoreListModel e) async {
      var resultScorebookModel = await Navigator.of(context).pushNamed(
        '/view_score',
        arguments: <String, dynamic> {
          'scorebookModel': scorebookModel,
          'gameScoreModel' : scorebookModel.gameScores.firstWhere((element) => element.gameCount == e.gameNo)
        }
      );
      if (resultScorebookModel != null) {
        _setData(resultScorebookModel, battleScoreModel);
      }
    };

    List<DataRow> dataRowList = gameScores.map((e) {
      List<DataCell> scoreCellList = memberNames.keys.map((k) =>
          DataCell(
            Container(
              width: double.infinity,
              child: Text(
                "${e.memberScores[k]}",
                textAlign: TextAlign.end,
              )
            ),
            onTap: () {
              handleOnTap(e);
            },
          )
      ).toList();

      List<DataCell> cells = [
        DataCell(
          Text("${e.gameNo}"),
          onTap: () {
            handleOnTap(e);
          },
        ),
        ...scoreCellList,
      ];
      return DataRow(
        cells: cells,
      );
    }).toList();

    return dataRowList;
  }

  /// データソース作成
  DataTableSource _createDatasource(BuildContext context, BattleScoreModel battleScoreModel, ScorebookModel scorebookModel) {

    List<DataRow> dataRowList = _createDataRow(context, battleScoreModel, scorebookModel);
    return GameScoreTableSource(dataRowList);
  }

  /// 合計表示
  void _showTotal(BuildContext context, Map<int, String> memberNames, List<GameScoreListModel> gameScores) {
    List<DataColumn> headers = memberNames.values.map((e) => DataColumn(label: Text(e))).toList();
    List<DataCell> totalRow = memberNames.keys.map((e){
      int total = gameScores.map((element) => element.memberScores[e]??0).fold(0, (previousValue, element) => previousValue + element);

      return DataCell(
          Container(
            width: double.infinity,
            child: Text(
              "${total}",
              textAlign: TextAlign.end,
            ),
          ),
        onTap: (){

        }
      );
    }).toList();

    // ポップアップで合計点表示
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: double.infinity,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: headers,
                      rows: [
                        DataRow(cells: totalRow),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: RaisedButton(
                      child: Text('閉じる'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );
    
  }

  /// 設定を表示
  void _showSettings(BuildContext context, ScorebookModel scorebookModel) {
    List<Map<String, int>> data = [
      {"ウマ1-4" : scorebookModel.uma14},
      {"ウマ2-3" : scorebookModel.uma23},
      {"ヤキトリ" : scorebookModel.uma14},
      {"トビ" : scorebookModel.tobi},
    ];

    // ポップアップで合計点表示
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: double.infinity,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:  BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: ListTile(
                          title: Text(data[index].keys.first),
                          subtitle: Text('${data[index].values.first}'),
                        ),
                      );
                    }
                  ),
                ),
                Expanded(
                  child: Center(
                    child: RaisedButton(
                      child: Text('閉じる'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    ScorebookModel scorebookModel = ModalRoute.of(context).settings.arguments;

    return ChangeNotifierProvider<BattleScoreModel>(
      create: (context) => _initData(scorebookModel),
      child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),  // キーボード隠す
          child: Scaffold(
            appBar: AppBar(
            title: Text('点数表'),
            ),
            body: Consumer<BattleScoreModel>(
              builder: (context, model, child) {
                return Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: PaginatedDataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(label: Text("回"),),
                        for (var name in model.memberNames.values) DataColumn(
                          label: Text(name),
                          numeric: true,
                        )
                      ],
                      header: Container(
                        height: 0,
                      ),
                      source: _createDatasource(context, model, scorebookModel),
                      rowsPerPage: 10,
                    ),
                  ),
                );
              }
            ),
            bottomNavigationBar: BottomAppBar(
              shape: CircularNotchedRectangle(),
              child: Consumer<BattleScoreModel>(
                builder: (context, model, child) {
                  return Container(
                    height: 60.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.assignment),
                              Text('合計'),
                            ],
                          ),
                          onPressed: () {
                            _showTotal(context, model.memberNames, model.gameScores);
                          },
                        ),
                        FlatButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.settings_applications),
                              Text('設定確認'),
                            ],
                          ),
                          onPressed: () {
                            _showSettings(context, scorebookModel);
                          },
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
            // 対局追加
            floatingActionButton: Consumer<BattleScoreModel>(
              builder: (context, model, child) {
                return FloatingActionButton(
                  onPressed: () async {
                    var resultScorebookModel = await Navigator.of(context).pushNamed('/input_score', arguments: scorebookModel);
                    if (resultScorebookModel != null) {
                      _setData(resultScorebookModel, model);
                    }
                  },
                  child: Icon(Icons.add),
                );
              }
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          ),
      ),
    );
  }

}

/// 得点表示テーブル用のデータソース
class GameScoreTableSource extends DataTableSource {

  List<DataRow> _dataRowList;
  GameScoreTableSource(this._dataRowList);

  @override
  DataRow getRow(int index) {
    return _dataRowList[index];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _dataRowList.length ;

  @override
  int get selectedRowCount => 0;

}

/// 画面用データ
class BattleScoreModel extends ChangeNotifier {

  /// メンバーの名前
  Map<int, String> _memberNames;

  /// 対戦得点
  List<GameScoreListModel> _gameScores;

  Map<int, String> get memberNames => _memberNames;

  set memberNames(Map<int, String> value) {
    _memberNames = value;
  }

  List<GameScoreListModel> get gameScores => _gameScores;

  set gameScores(List<GameScoreListModel> value) {
    _gameScores = value;
    notifyListeners();
  }
}

/// 1局の成績
class GameScoreListModel {

  /// 回
  int _gameNo;

  /// 選択
  bool _selected = false;

  /// 対戦者の点数
  Map<int, int> _memberScores;

  Map<int, int> get memberScores => _memberScores;

  set memberScores(Map<int, int> value) {
    _memberScores = value;
  }

  int get gameNo => _gameNo;

  set gameNo(int value) {
    _gameNo = value;
  }

  bool get selected => _selected;

  set selected(bool value) {
    _selected = value;
  }
}