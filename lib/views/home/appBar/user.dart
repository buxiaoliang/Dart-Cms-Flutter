import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// config
import '../../../utils/config.dart' show appName, hostUrl, appUniqueKey;
// schema
import '../../../schema/nav-info-schema.dart'
    show NavInfoSchemaValueTabListList;
// 缓存
import '../../../utils/cache.dart' show Cache;
// utils
import '../../../utils/tools.dart' show publicToast;
// components
import '../../../components/publicDialog.dart' show createPubDialog, launchUrl;
// api
import '../../../utils/api.dart' show AppAuthUpgrade;
// 公共获取视频数据方法
import '../../../utils/tools.dart' show getVideoDetail;

class User extends StatefulWidget {
  Map args;
  User({Key key, this.args}) : super(key: key);

  @override
  _UserState createState() => _UserState(args: args);
}

class _UserState extends State<User> {
  Map args;
  // 是否已经登录
  bool isLogin = false;
  // 缓存大小
  String cacheSize = '0';
  // 用户信息
  // 历史记录 本地集合
  List<dynamic> hisList = [];
  BuildContext topContext;
  _UserState({this.args});

  // 设置历史记录
  Future<void> _setHistory() async {
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
        // map初始化
        Map<String, dynamic> curVal =
            new Map<String, dynamic>.from(hisVal[hisValKey]);
        newHisList.add(curVal);
      }
    }
    this.setState(() {
      hisList = newHisList;
    });
  }

  // 检查更新
  void _runUpdate() {
    AppAuthUpgrade((data) {
      bool isUpgrade = data.value.upgrade;
      String appDownUrl = data.value.download;
      showDialog(
        context: topContext,
        builder: (context) {
          return createPubDialog(
            title: "检测升级",
            dialogContext: isUpgrade ? data.value.dialog : "当前版本已是最新",
            icon: Icon(FontAwesomeIcons.cloudDownloadAlt),
            cbWidget: () {
              return RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                onPressed: () {
                  // 打开浏览器地址
                  if (isUpgrade) {
                    launchUrl(appDownUrl);
                  } else {
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text('确认'),
              );
            },
          );
        },
      );
    }, appUniqueKey);
  }

  // 清除缓存
  void _clearCache() async {
    await Cache.clearCache(cb: () {
      publicToast('缓存清除成功');
    });
  }

  // 计算缓存大小
  Future<void> _getCacheSize() async {
    dynamic futrueCache = await Cache.loadCache();
    String cacheSize = futrueCache.toString();
    this.setState(() {
      this.cacheSize = cacheSize;
    });
  }

  // 初始化
  Future<void> _initData() async {
    await _setHistory();
    await _getCacheSize();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Widget _buildHisChild() {
    // 暂无历史
    if (hisList.length <= 0) {
      return Padding(
        padding: EdgeInsets.only(top: 40, bottom: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Icon(Icons.warning, color: Colors.black45),
            ),
            Text(
              '暂无历史记录',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    // 有历史记录
    List<Widget> child = hisList.map((item) {
      return Padding(
        padding: EdgeInsets.only(left: 3, right: 3, bottom: 5, top: 7),
        child: GestureDetector(
          onTap: () async {
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
          child: Column(
            children: <Widget>[
              Container(
                height: 80,
                width: 120,
                child: FadeInImage(
                  placeholder: AssetImage('images/lazy.gif'),
                  image: NetworkImage(item["videoImage"]),
                  fit: BoxFit.cover,
                ),
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     fit: BoxFit.cover,
                //     image: NetworkImage(item.videoImage),
                //   ),
                // ),
              ),
              Container(
                height: 25,
                width: 120,
                alignment: Alignment.center,
                child: Text(
                  item["videoTitle"] + ' ' + item["coll_name"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
      );
    }).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: child,
        ),
      ),
    );
  }

  // 生成行
  Widget _buildTableRows(String title,
      {String tip, TextStyle tipStyle, @required Function tapEvent}) {
    // 默认的tip style
    tipStyle = tipStyle != null ? tipStyle : TextStyle();
    return FlatButton(
      onPressed: tapEvent,
      child: Container(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              tip != null
                  ? Row(
                      children: <Widget>[
                        Text(
                          tip,
                          style: tipStyle,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.black12,
                        )
                      ],
                    )
                  : Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black12,
                    )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    topContext = context;
    return RefreshIndicator(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            // 头部
            Container(
              color: Theme.of(context).accentColor,
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    // 头像
                    ClipOval(
                      child: Container(
                        color: Colors.black12,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 历史记录行标题
                _buildTableRows(
                  '历史记录',
                  tip: '更多',
                  tipStyle: TextStyle(color: Colors.red),
                  tapEvent: () {
                    // 进入历史记录管理页面
                    Navigator.pushNamed(context, '/history', arguments: {});
                  },
                ),
                Divider(height: 1),
                // 历史记录
                _buildHisChild(),
                Divider(height: 1),
                // 我的收藏
                _buildTableRows(
                  '我的收藏',
                  tapEvent: () {
                    // 进入免责页面
                    Navigator.pushNamed(context, '/interest', arguments: {});
                  },
                ),
                Divider(height: 1),
                // 分享
                _buildTableRows(
                  '分享APP',
                  tapEvent: () {
                    // 调用系统分享
                    ShareExtend.share(appName + ' ' + hostUrl, "text");
                  },
                ),
                Divider(height: 1),
                // 免责申明
                _buildTableRows(
                  '免责申明',
                  tapEvent: () {
                    // 进入免责页面
                    Navigator.pushNamed(context, '/declare', arguments: {});
                  },
                ),
                Divider(height: 1),
                // 检查更新
                _buildTableRows(
                  '检查更新',
                  tapEvent: _runUpdate,
                ),
                Divider(height: 1),
                // 清除缓存
                _buildTableRows(
                  '清除缓存',
                  tip: cacheSize,
                  tipStyle: TextStyle(color: Colors.black45),
                  tapEvent: _clearCache,
                ),
              ],
            ),
          ],
        ),
      ),
      onRefresh: _initData,
    );
  }
}
