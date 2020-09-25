import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
// schema
import '../../schema/nav-info-schema.dart' show NavInfoSchemaValueTabListList;
// utils
import '../../utils/tools.dart' show publicToast;

class Interest extends StatefulWidget {
  Map args;
  Interest({Key key, this.args}) : super(key: key);

  @override
  _InterestState createState() => _InterestState(args: args);
}

class _InterestState extends State<Interest> {
  Map args;
  List<dynamic> interestList = [];
  _InterestState({this.args});

  // 执行删除历史记录
  Future<void> _runRemoveHistory(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.remove('interest');
    if (result) {
      publicToast('删除成功');
      await _getInterestData();
    } else {
      publicToast('删除失败');
    }
  }

  // 初始化历史记录
  Future<void> _getInterestData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var starJsonStr = prefs.getString('interest');

    // 判断非空
    List<dynamic> starDataList =
        starJsonStr != null ? convert.jsonDecode(starJsonStr) : [];
    // prefs.remove('interest');

    this.setState(() {
      interestList = starDataList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInterestData();
  }

  List<Widget> _buildIntChild() {
    return interestList.map((item) {
      // Map<String, dynamic> item = new Map<String, dynamic>.from(cursor);
      return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: FlatButton(
          padding: EdgeInsets.only(top: 4, bottom: 4),
          onPressed: () {
            // map转class
            NavInfoSchemaValueTabListList curData =
                NavInfoSchemaValueTabListList.fromJson(item);
            // query schema
            Map args = <String, dynamic>{'schema': curData};
            // 再打开当前页
            Navigator.pushNamed(context, '/video', arguments: args);
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
                              item["videoTitle"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black87),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('类型： ' + item["video_type"]["name"]),
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
        title: Text('个人收藏'),
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
        children: _buildIntChild(),
      ),
    );
  }
}
