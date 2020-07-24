
import 'package:flutter/material.dart';
import 'package:mahjong_scorebook/scorebook_model.dart';
import 'package:provider/provider.dart';

class BattleScore extends StatelessWidget {

  BattleScoreModel _initData(ScorebookModel scorebookModel) {

    // メンバー名
    Map<int, String> memberNames = {};
    scorebookModel.members.forEach((element) {
      memberNames[element.id] = element.name;
    });

    // 対戦成績
    List<GameScoreModel> gameScores = scorebookModel.gameScores.map((e) {

      // 得点
      Map<int, int> memberScores = {};
      e.memberScores.forEach((element) {
        memberScores[element.member.id] = element.calcScore;
      });

      GameScoreModel gameScoreModel = GameScoreModel()
        ..gameNo = e.gameCount
        ..memberScores = memberScores;

      return gameScoreModel;
    }).toList();

    BattleScoreModel battleScoreModel = BattleScoreModel()
      ..memberNames = memberNames
      ..gameScores = gameScores;

    return battleScoreModel;
  }

  /// テーブル行の作成
  List<DataRow> _createDataRow(Map<int, String> memberNames, List<GameScoreModel> gameScores) {
    List<DataRow> dataRowList = gameScores.map((e) {
      List<DataCell> scoreCellList = memberNames.keys.map((k) =>
          DataCell(
            Container(
              width: double.infinity,
              child: Text(
                "${e.memberScores[k]}",
                textAlign: TextAlign.end,
              )
            )
          )
      ).toList();

      return DataRow(
        cells: [
          DataCell(Text("${e.gameNo}")),
          ...scoreCellList,
        ]
      );
    }).toList();

    return dataRowList;
  }

  /// データソース作成
  DataTableSource _createDatasource(Map<int, String> memberNames, List<GameScoreModel> gameScores) {
    List<DataRow> dataRowList = _createDataRow(memberNames, gameScores);
    return GameScoreTableSource(dataRowList);
  }

  @override
  Widget build(BuildContext context) {

    ScorebookModel model = ModalRoute.of(context).settings.arguments;

    return ChangeNotifierProvider<BattleScoreModel>(
      create: (context) => _initData(model),
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
                      source: _createDatasource(model.memberNames, model.gameScores),
                      rowsPerPage: 10,
                    ),
                  ),
                );
              }
            ),
            bottomNavigationBar: BottomAppBar(
              shape: CircularNotchedRectangle(),
              child: Container(
                height: 50.0,
              ),
            ),
            // 対局追加
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                Navigator.of(context).pushNamed('/input_score', arguments: model);
              },
              child: Icon(Icons.add),
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
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _dataRowList.length ;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

}

/// 画面用データ
class BattleScoreModel extends ChangeNotifier {

  /// メンバーの名前
  Map<int, String> _memberNames;

  /// 対戦得点
  List<GameScoreModel> _gameScores;

  Map<int, String> get memberNames => _memberNames;

  set memberNames(Map<int, String> value) {
    _memberNames = value;
  }

  List<GameScoreModel> get gameScores => _gameScores;

  set gameScores(List<GameScoreModel> value) {
    _gameScores = value;
    notifyListeners();
  }
}

/// 1局の成績
class GameScoreModel {

  /// 回
  int _gameNo;

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
}