import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mahjong_scorebook/game_score.dart';
import 'package:mahjong_scorebook/input_score.dart';
import 'package:mahjong_scorebook/scorebook_model.dart';
import 'package:mahjong_scorebook/setting.dart';

void main() async {

  await Hive.initFlutter();
  Hive.registerAdapter(ScorebookModelAdapter());
  Hive.registerAdapter(MemberModelAdapter());
  Hive.registerAdapter(GameScoreModelAdapter());
  Hive.registerAdapter(MemberScoreModelAdapter());
  await Hive.openBox<ScorebookModel>("mahjong_scorebook");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final RouteObserver<PageRoute> _routeObserver = new RouteObserver<PageRoute>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '対局リスト',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
          child: MyHomePage(this._routeObserver)
      ),
      routes: <String, WidgetBuilder> {
        '/setting': (BuildContext context) => SettingPage(),
        '/game_score': (BuildContext context) => BattleScore(),
        '/input_score': (BuildContext context) => InputScore(),
      },
      navigatorObservers: <NavigatorObserver>[_routeObserver],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final RouteObserver<PageRoute> routeObserver;
  const MyHomePage(this.routeObserver);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {

  /// ListView更新用
  final _onChangeScorebookList = StreamController<List<ScorebookModel>>();

  /// 対局データ
  List<ScorebookModel> _scorebookList = [];

  /// 設定画面（新規追加画面）へ移動
  void _moveSetting() {
    Navigator.of(context).pushNamed('/setting');
  }

  /// １ゲームの点数表へ移動
  void _moveGameScore(ScorebookModel model) {
    //Navigator.of(context).pushNamed('/game_score', arguments: model);
    Navigator.pushNamed(context, '/game_score', arguments: model);
  }

  /// BDから対局を取得する
  void _readScorebook() {
    this._scorebookList = Hive.box<ScorebookModel>("mahjong_scorebook").values.toList();
    _onChangeScorebookList.sink.add(this._scorebookList);
  }

  /// リスト長押しで削除
  void _deleteScorebook(ScorebookModel model) {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.remove_circle),
              ],
            ),
            content: Container(
              child:  Text("対局を削除してよろしいですか？"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('はい'),
                onPressed: () async {
                  // データ削除
                  await model.delete().catchError((e) => print(e));
                  // 再読み込み
                  _readScorebook();
                  Navigator.pop(context);
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

  /// 画面が表示されたらデータを再読込するためにObserver設定
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  /// StreamクローズとObserver終了
  @override
  void dispose() {
    _onChangeScorebookList.close();
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("対局一覧"),
      ),
      body: StreamBuilder<List<ScorebookModel>>(  // データの再読み込みでListView更新するため
        stream: this._onChangeScorebookList.stream,
        builder: (BuildContext context, snapshot) {
          return ListView.builder(
              itemBuilder: (context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom:  BorderSide(color: Colors.black38),
                    )
                  ),
                  child:  ListTile(
                    leading: const Icon(Icons.event_available, size: 40,),
                    title: Text(snapshot.data[index].gameDatetime.toIso8601String(),),
                    onTap: (){
                      _moveGameScore(snapshot.data[index]);
                    },
                    onLongPress:(){
                      _deleteScorebook(snapshot.data[index]);
                    },
                  ),
                );
              },
              itemCount: snapshot.data?.length,
          );
        }
      ),
      // 対局追加
      floatingActionButton: FloatingActionButton(
        onPressed: _moveSetting,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // 戻ってきたら
  @override
  void didPopNext() {
    _readScorebook();
  }

  // 主に初期表示
  @override
  void didPush() {
    _readScorebook();
  }
}
