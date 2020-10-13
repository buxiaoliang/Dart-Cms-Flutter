import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:convert' as convert;
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
// config
import '../../utils/config.dart' show appName, hostUrl;
// utils
import '../../utils/tools.dart' show publicToast;
// schema
import '../../schema/video-detill-schema.dart'
    show
        CurVideoDetillValueVideoInfo,
        CurVideoDetillValueListLikeMovie,
        CurVideoDetillValueMealList,
        CurVideoDetillValueSource;
// components
import '../../components/publicMeal.dart' show createMealList;
import '../../components/publicMovieGroup.dart' show layoutGroupMovieCard;

// 存下根组件context
BuildContext curContext;

// 首页 - 路由
class Video extends StatefulWidget {
  // schema
  Map<String, dynamic> args;
  Video({Key key, @required this.args}) : super(key: key);

  @override
  _VideoState createState() => _VideoState(args: args);
}

class _VideoState extends State<Video> with TickerProviderStateMixin {
  // schema
  Map<String, dynamic> args;
  bool isInit = false;
  // detill data
  CurVideoDetillValueVideoInfo detillInfo;
  // like list
  List<CurVideoDetillValueListLikeMovie> likeList = [];
  // meal list
  List<CurVideoDetillValueMealList> mealList = [];
  // source list
  List<CurVideoDetillValueSource> sourceList = [];
  // tabBar
  TabController tabController;
  // curSourceIndex
  Map<String, int> playFocus = {
    "row_id": 0,
    "col_id": 0,
  };
  // 加载失败
  bool isError = false;
  // player url
  String url;
  // cur playing the video list name
  String videoName;
  // widget uniqueKey
  UniqueKey uniqueKey = UniqueKey();
  _VideoState({@required this.args}) {
    Map<String, dynamic> arg = new Map<String, dynamic>.from(args);
    // this.setState(() {
    if (arg["playFocus"] != null) {
      this.playFocus = arg["playFocus"];
    }
    // video info
    this.detillInfo = arg["detillInfo"];
    // meal list
    this.mealList = arg["mealList"];
    // like list
    this.likeList = arg["likeList"];
    // source list
    this.sourceList = arg["sourceList"];
    // });
  }

  void _initData() {
    // 播放源
    String url = sourceList.length > 0 &&
            sourceList[playFocus["row_id"]] != null &&
            sourceList[playFocus["row_id"]].list[playFocus["col_id"]] != null
        ? sourceList[playFocus["row_id"]]
            .list[playFocus["col_id"]]
            .split('\$')[1]
        : "";
    this.setState(() {
      this.tabController = TabController(
        length: 2,
        vsync: this,
      );
      this.url = url;
      this.videoName = detillInfo.videoTitle +
          ' ' +
          (url.isNotEmpty
              ? sourceList[playFocus["row_id"]]
                  .list[playFocus["col_id"]]
                  .split('\$')[0]
              : '');
    });
    // 当前播放焦点名称
    String curPlayBtnName = this.url.isNotEmpty
        ? this
            .sourceList[playFocus["row_id"]]
            .list[playFocus["col_id"]]
            .split('\$')[0]
        : "";
    // 设置历史
    _setHistory(playFocus, curPlayBtnName);
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Map<String, dynamic> formantObject(
      Map<String, int> playFocus, String curPlayBtnName) {
    return {
      "_id": detillInfo.Id,
      "videoTitle": detillInfo.videoTitle,
      "director": detillInfo.director,
      "poster": detillInfo.performer,
      "videoImage": detillInfo.videoImage,
      "video_type": detillInfo.videoType.name,
      "video_rate": detillInfo.videoRate,
      "update_time": detillInfo.updateTime,
      "language": detillInfo.language,
      "sub_region": detillInfo.subRegion,
      "rel_time": detillInfo.relTime,
      "introduce": detillInfo.introduce,
      "remind_tip": detillInfo.remindTip,
      "popular": detillInfo.popular,
      "allow_reply": detillInfo.allowReply,
      "display": detillInfo.display,
      "scource_sort": detillInfo.scourceSort,
      // player cur index
      "row_id": playFocus["row_id"],
      "col_id": playFocus["col_id"],
      // cur focus play btn name
      "coll_name": curPlayBtnName,
    };
  }

  // 加入一条历史记录
  void _setHistory(Map<String, int> playFocus, String curPlayBtnName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var hisJsonStr = prefs.getString('history');

    // 是否非空 null
    Map<String, dynamic> hisData = hisJsonStr != null
        ? convert.jsonDecode(hisJsonStr)
        : {"key": [], "val": {}};

    List hisKeys = hisData['key'];
    Map<String, dynamic> hisVal = new Map<String, dynamic>.from(hisData['val']);

    // 判断长度是否 > 20 , 删除最先的元素
    if (hisKeys.length >= 20) {
      String firstHisEl = hisKeys[0];
      hisKeys.removeAt(0);
      hisVal.removeWhere((String key, dynamic value) => key == firstHisEl);
    }

    // 插入一条新的
    String newKey = detillInfo.Id;
    // 当前的id是否已经存在
    if (hisKeys.contains(newKey)) {
      // 存在就删除，重新插入，变化位置，插入到最前
      hisKeys.remove(newKey);
    }
    // 插入新的
    hisKeys.add(newKey);
    // 当前视频的数据 formant
    Map<String, dynamic> curVideoMap = formantObject(playFocus, curPlayBtnName);
    // map加入当前视频数据
    hisVal[newKey] = curVideoMap;
    // 上面的 hisVal 重新创建了，所以这里需要重新赋值
    hisData["val"] = hisVal;
    // 存入
    String hisDataStr = convert.jsonEncode(hisData);
    prefs.setString('history', hisDataStr);
  }

  Widget _buildInkWellButton({
    @required String tagName,
    @required IconData icon,
    @required Function callBack,
  }) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          borderRadius: new BorderRadius.circular(15),
          onTap: callBack,
          child: Container(
            child: Padding(
              padding: EdgeInsets.only(left: 17, right: 17, top: 5, bottom: 5),
              child: Column(
                children: <Widget>[
                  Icon(icon, color: Colors.black87),
                  Text(tagName, style: TextStyle(color: Colors.black87))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Wakelock.disable();
    tabController.dispose();
    super.dispose();
  }

  // 加入本地收藏
  void _joinLikeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var starJsonStr = prefs.getString('interest');

    // 判断非空
    List<dynamic> starData =
        starJsonStr != null ? convert.jsonDecode(starJsonStr) : [];

    // 超过长度
    if (starData.length >= 50) {
      publicToast('收藏最大长度 50 个');
      return null;
    }

    // 已存在
    bool isAllow = starData.any((element) => element["_id"] == detillInfo.Id);
    if (isAllow) {
      publicToast('该视频已存在收藏列表');
      return null;
    }

    // +1
    starData.add(detillInfo);
    // 存入
    String starDataStr = convert.jsonEncode(starData);
    // 结果
    bool result = await prefs.setString('interest', starDataStr);
    if (result) {
      publicToast('收藏成功');
    } else {
      publicToast('收藏失败');
    }
  }

  // 分享
  void _shareCurVideo() {
    ShareExtend.share("${detillInfo.videoTitle} ${appName} ${hostUrl}", "text");
  }

  // 小字
  Widget _getTextTip(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black45,
      ),
    );
  }

  // 底部弹窗 - 视频信息
  void _showVideoInfoModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      detillInfo.videoTitle,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                // 年代，语言，分类，地区，评分
                _createCrumb(),
                // 演员表
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: Colors.black12,
                      ),
                      bottom: BorderSide(
                        width: 1,
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              '导演： ${detillInfo.director.isEmpty ? "暂无" : detillInfo.director}',
                              style: TextStyle(color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Text(
                              '主演： ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(detillInfo.performer != null
                                      ? detillInfo.performer
                                          .split(',')
                                          .join('  ')
                                      : "暂无")),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 简介
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text('简介'),
                        ),
                        SizedBox(height: 8),
                        Container(
                          child: Text(
                            detillInfo.introduce,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // bulder play btns
  List<Widget> _createPlayBtns(
    List playList,
    String sourceName,
    EdgeInsetsGeometry padding,
    int row_id,
  ) {
    return playList.asMap().keys.map((int index) {
      return Padding(
        padding: padding,
        child: RaisedButton(
          elevation: 0,
          color: playFocus["row_id"] == row_id && playFocus["col_id"] == index
              ? Theme.of(context).accentColor
              : Colors.black12,
          onPressed: () async {
            // 存当前源所在的项
            this.setState(() {
              playFocus["row_id"] = row_id;
              playFocus["col_id"] = index;
            });
            // 拆源 - 播放源 名称
            String curPlayBtnName = playList[index].split('\$')[0];
            // 拆源 - 播放源 url
            String url = playList[index].split('\$')[1];
            this.setState(() {
              this.uniqueKey = UniqueKey();
              this.videoName = detillInfo.videoTitle + ' ' + curPlayBtnName;
              this.url = url;
            });
            // 设置历史
            _setHistory(playFocus, curPlayBtnName);
          },
          child: Text(
            playList[index].split('\$')[0],
            style: TextStyle(
                color: playFocus["row_id"] == row_id &&
                        playFocus["col_id"] == index
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      );
    }).toList();
  }

  // builder play box
  List<Widget> _createPlayBox() {
    return sourceList.asMap().keys.map((int index) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // 源标题
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        // 每一组源的名称
                        sourceList[index].name,
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ),
                  // 源更多
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 500,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    spacing: 0,
                                    runSpacing: 0,
                                    children: _createPlayBtns(
                                      sourceList[index].list,
                                      sourceList[index].name,
                                      EdgeInsets.only(
                                        left: 5,
                                        right: 5,
                                      ),
                                      index,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        '更多',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _createPlayBtns(
                    sourceList[index].list,
                    sourceList[index].name,
                    EdgeInsets.all(5),
                    index,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // video 下半部 分集
  Widget _getCurPlayList() {
    return Column(
      children: <Widget>[
        // 当前卡片标题
        Container(
          height: 50,
          color: Colors.white,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              '播放列表',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Divider(height: 1),
        // 源列表
        Container(
          child: Column(
            children: sourceList.length > 0
                ? _createPlayBox()
                : [
                    Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                        child: Text(
                          '暂无播放源',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ),
                    )
                  ],
          ),
        ),
      ],
    );
  }

  // 评分，年代，语言，地区，分类
  Widget _createCrumb() {
    return Container(
      height: 30,
      color: Colors.white,
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          children: <Widget>[
            // 发布时间
            _getTextTip(detillInfo.relTime.isEmpty ? '暂无' : detillInfo.relTime),
            _getTextTip(' | '),
            // 分类
            _getTextTip(detillInfo?.videoType?.name ?? '暂无'),
            _getTextTip(' | '),
            // 评分
            _getTextTip(detillInfo.videoRate.toString() + ' 分'),
            _getTextTip(' | '),
            // 语言
            _getTextTip(
                detillInfo.language.isEmpty ? '暂无' : detillInfo.language),
            _getTextTip(' | '),
            // 发布地区
            _getTextTip(
                detillInfo.subRegion.isEmpty ? '暂无' : detillInfo.subRegion),
          ],
        ),
      ),
    );
  }

  // 下半部 推荐视频
  Widget _createVideoLike() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: layoutGroupMovieCard(
        context: curContext,
        topList: this.likeList,
        isPop: true,
      ),
    );
  }

  // video 下半部 信息
  Widget _createVideoInfo() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          SizedBox(height: 5),
          // 广告
          createMealList(mealList),
          // 标题
          Container(
            height: 50,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        detillInfo.videoTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showVideoInfoModule(context);
                      },
                      child: Text(
                        '更多',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // 评分，年代，语言，地区，分类
          _createCrumb(),
          SizedBox(height: 5),
          // 评价。分享。收藏
          Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildInkWellButton(
                    icon: Icons.star,
                    callBack: _joinLikeList,
                    tagName: "收藏",
                  ),
                  _buildInkWellButton(
                    icon: Icons.share,
                    callBack: _shareCurVideo,
                    tagName: "分享",
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          // 选集
          _getCurPlayList(),
          SizedBox(height: 5),
          // 推荐视频
          // LikeMovieCard(likeList, UniqueKey()),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  // video 下半部主体
  Widget _createVideo() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(22),
          child: AppBar(
            primary: false,
            elevation: 0.3,
            automaticallyImplyLeading: false,
            title: Center(
              child: TabBar(
                tabs: <Widget>[
                  Tab(text: '视频信息'),
                  Tab(text: '推荐视频'),
                ],
                isScrollable: true,
                controller: tabController,
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: <Widget>[
            // tab1 video info
            _createVideoInfo(),
            // tab2 video message
            _createVideoLike(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    curContext = context;
    return Scaffold(
      body: Column(
        children: <Widget>[
          // 播放器
          ChewiePlayer(this.url, this.videoName, this.uniqueKey),
          // 描述信息
          Expanded(
            flex: 1,
            child: _createVideo(),
          )
        ],
      ),
    );
  }
}

// 播放器
class ChewiePlayer extends StatefulWidget {
  final String url;
  final String videoName;
  final UniqueKey newKey;
  ChewiePlayer(this.url, this.videoName, this.newKey) : super(key: newKey);

  @override
  _ChewiePlayerState createState() => _ChewiePlayerState(url, videoName);
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  final String url;
  final String videoName;
  IjkMediaController controller;
  _ChewiePlayerState(this.url, this.videoName);

  _initState() {
    controller = IjkMediaController();
    controller
      ..setDataSource(
        DataSource.network(url),
        autoPlay: true,
      );
    Wakelock.enable();
  }

  @override
  void initState() {
    super.initState();
    _initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      child: IjkPlayer(
        mediaController: controller,
      ),
    );
  }
}
