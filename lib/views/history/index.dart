import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
// utils
import '../../utils/tools.dart' show publicToast, getVideoDetail;

class History extends StatefulWidget {
  Map args;
  History({Key key, this.args}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState(args: args);
}

class _HistoryState extends State<History> {
  Map args;
  List<dynamic> hisList = [];
  _HistoryState({this.args});

  // 执行删除历史记录
  Future<void> _runRemoveHistory(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.remove('history');
    if (result) {
      publicToast('删除成功');
      await _getHistoryData();
    } else {
      publicToast('删除失败');
    }
  }

  // 初始化历史记录
  Future<void> _getHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var hisJsonStr = prefs.getString('history');
    // 是否非空 null
    Map<String, dynamic> hisData = hisJsonStr != null
        ? convert.jsonDecode(hisJsonStr)
        : {"key": [], "val": {}};
    List hisKeys = hisData['key'];
    Map<String, dynamic> hisVal = new Map<String, dynamic>.from(hisData['val']);
    // prefs.remove('history');

    // 反序列
    List hisKeyOrder = hisKeys.reversed.toList();
    // 空，暂存
    List<dynamic> newHisList = [];
    for (int i = 0; i < hisKeyOrder.length; i++) {
      // cur key
      String hisValKey = hisKeyOrder[i];
      // 如果对于的val有值，加入暂存
      if (hisVal[hisValKey] != null) {
        Map<String, dynamic> curVal = hisVal[hisValKey];
        newHisList.add(curVal);
      }
    }
    this.setState(() {
      hisList = newHisList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHistoryData();
  }

  List<Widget> _buildHisChild(BuildContext context) {
    return hisList.map((item) {
      return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: FlatButton(
          padding: EdgeInsets.only(top: 4, bottom: 4),
          onPressed: () async {
            // 播放历史，行，列。多少集
            Map<String, int> playFocus = {
              "row_id": item["row_id"],
              "col_id": item["col_id"],
            };
            // 获取视频数据，
            await getVideoDetail(
              context,
              item["_id"],
              false,
              history: playFocus,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 120,
                    child: FadeInImage(
                      placeholder: AssetImage('images/lazy.gif'),
                      image: NetworkImage(item["videoImage"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 80,
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item["videoTitle"] + ' ' + item["coll_name"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black87),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('类型： ' + item["video_type"]),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _runRemoveHistory(context);
            },
            icon: Icon(Icons.restore_from_trash),
          ),
        ],
      ),
      body: ListView(
        children: _buildHisChild(context),
      ),
    );
  }
}
