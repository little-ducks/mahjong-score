import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mahjong_scorebook/scorebook_model.dart';

class SettingPage extends StatelessWidget {

  /// FORM KEY
  final _formKey = GlobalKey<FormState>();
  /// メンツ（将来用追加できるようにリスト）
  final List<TextEditingController> _memberControllers = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()];
  /// 1-4位のウマ
  final TextEditingController uma14Controller = TextEditingController();
  /// 2-3位のウマ
  final TextEditingController uma23Controller = TextEditingController();
  /// ヤキトリ（ヤキトリの人ひとりが払う。３と２の公倍数で）
  final TextEditingController yakiController = TextEditingController();
  /// トビ（トビの人ひとりが払う点数。３と３の公倍数で）
  final TextEditingController tobiController = TextEditingController();

  /// 対局追加
  void _saveSetting(BuildContext context) {
    var box = Hive.box<ScorebookModel>("mahjong_scorebook");
    var scorebook = ScorebookModel()
      ..gameDatetime = DateTime.now()
      ..uma14 = int.parse(uma14Controller.text)
      ..uma23 = int.parse(uma23Controller.text)
      ..yaki = int.parse(yakiController.text)
      ..tobi = int.parse(tobiController.text)
      ;
    // メンツ追加
    int id = 0;
    List<MemberModel> members = _memberControllers.map((e) {
      return MemberModel()
          ..id = id++
          ..name = e.text;
    }).toList();
    scorebook.members = members;

    box.add(scorebook);
    Navigator.pop(context);
  }

  /// 数値で1000点以上の共通チェック
  String _validateNumThousand(String value) {

    if (value.isEmpty) {
      return null;
    }

    final int point = int.tryParse(value);
    if (point == null) {
      return "数字で入力してください。";
    }

    final rem = point % 1000;
    if (rem > 0) {
      return "1000点単位で入力してください。";
    }

    return null;
  }

  /// やきとり、とび用
  String _validateYakiTobi(String value) {

    if (value.isEmpty) {
      return null;
    }

    final msg = _validateNumThousand(value);
    if (msg != null) {
      return msg;
    }

    // 2000と3000の倍数（１人か２人か３人かに分配するから）
    final num = int.parse(value);
    if ((num % 2000) != 0 || (num % 3000) != 0) {
      return "2人にも3人にも分配できる点数にしてください。";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),  // キーボード隠す
      child: Scaffold(
        appBar: AppBar(
          title: Text('対局追加'),
        ),
        //resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // メンツ
                Container(
                  height: 330,
                  child: ListView.builder(
                      itemCount: _memberControllers.length,
                      itemBuilder:  (BuildContext context, int index) {
                        final memberController = _memberControllers[index];
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(
                                bottom:  BorderSide(color: Colors.black38),
                              ),
                          ),
                          child: ListTile(
                            subtitle: TextFormField(
                              controller: memberController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.person),
                                hintText: 'メンツ${index + 1}',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "メンツを入力してください。";
                                }
                                return null;
                              },
                              autovalidate: false,
                            ),
                          ),
                        );
                      },
                  ),
                ),

                // ウマ
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: uma14Controller,
                  decoration: InputDecoration(
                    icon: Icon(Icons.payment),
                    labelText: "ウマ1-4",
                    hintText: "ex.30000",
                  ),
                  validator: _validateNumThousand,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: uma23Controller,
                  decoration: InputDecoration(
                      icon: Icon(Icons.payment),
                      labelText: "ウマ2-3",
                      hintText: "ex.10000"
                  ),
                  validator: _validateNumThousand,
                ),

                // ヤキトリ＆トビ
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: yakiController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.payment),
                    labelText: "ヤキトリ",
                    hintText: "ex.30000",
                  ),
                  validator: _validateYakiTobi,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: tobiController,
                  decoration: InputDecoration(
                      icon: Icon(Icons.payment),
                      labelText: "トビ",
                      hintText: "ex.30000"
                  ),
                  validator: _validateYakiTobi,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _saveSetting(context);

            }
            },
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}