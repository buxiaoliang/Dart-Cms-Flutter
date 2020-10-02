import 'package:flutter/material.dart';
// 公共获取视频数据方法
import '../utils/tools.dart' show getVideoDetail;

class VideoSchema {
  String Id;
  String videoTitle;
  String director;
  String videoImage;
  String poster;
  String performer;
  String videoType;
  int videoRate;
  String updateTime;
  String language;
  String subRegion;
  String relTime;
  String introduce;
  String remindTip;
  bool popular;
  bool allowReply;
  bool openSwiper;
  bool display;
  bool scourceSort;

  VideoSchema({
    this.Id,
    this.videoTitle,
    this.director,
    this.videoImage,
    this.poster,
    this.performer,
    this.videoType,
    this.videoRate,
    this.updateTime,
    this.language,
    this.subRegion,
    this.relTime,
    this.introduce,
    this.remindTip,
    this.popular,
    this.allowReply,
    this.openSwiper,
    this.display,
    this.scourceSort,
  });
  VideoSchema.formantData(dynamic data) {
    this.Id = data.Id;
    this.videoTitle = data.videoTitle;
    this.director = data.director;
    this.videoImage = data.videoImage;
    this.poster = data.poster;
    this.performer = data.performer;
    this.videoType = data.videoType;
    this.videoRate = data.videoRate;
    this.updateTime = data.updateTime;
    this.language = data.language;
    this.subRegion = data.subRegion;
    this.relTime = data.relTime;
    this.introduce = data.introduce;
    this.remindTip = data.remindTip;
    this.popular = data.popular;
    this.allowReply = data.allowReply;
    this.openSwiper = data.openSwiper;
    this.display = data.display;
    this.scourceSort = data.scourceSort;
  }
}

List<Widget> _getMovieItems(
  List<VideoSchema> curRow,
  BuildContext context,
  bool isPop, {
  Map history,
}) {
  List mapList = new List(3);
  return mapList.asMap().keys.map((int iKey) {
    VideoSchema item;
    // 如果是补空
    try {
      item = curRow[iKey];
    } catch (err) {
      return Expanded(child: Container(height: 1), flex: 1);
    }

    // 正常显示
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () async {
          // 获取视频数据，
          await getVideoDetail(context, item.Id, isPop, history: history);
        },
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Column(
            children: <Widget>[
              Container(
                height: 180,
                child: FadeInImage(
                  placeholder: AssetImage('images/lazy.gif'),
                  image: NetworkImage(item.videoImage),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 5),
              Container(
                alignment: Alignment.center,
                child: Text(
                  item.videoTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }).toList();
}

List<Widget> _getMovieRows(
  List<List<VideoSchema>> items,
  BuildContext context,
  int rowItemNum,
  bool isPop, {
  Map history,
}) {
  return items.map((List<VideoSchema> curRow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getMovieItems(curRow, context, isPop, history: history),
    );
  }).toList();
}

// 自适应布局
Widget layoutGroupMovieCard({
  @required List<dynamic> topList,
  String title,
  int rowItemNum = 3,
  @required BuildContext context,
  bool isPop = false,
  Map history,
}) {
  List<List<VideoSchema>> items = [];
  int topLen = topList.length;
  for (var i = 0; i < topLen; i += rowItemNum) {
    int ml = i + rowItemNum;
    List<VideoSchema> curRows = [];
    for (var j = i; j < ml; j++) {
      if (j < topLen) {
        dynamic curItem = topList[j];
        VideoSchema curdata = VideoSchema.formantData(curItem);
        curRows.add(curdata);
      }
    }
    items.add(curRows);
  }

  // 没有传标题
  if (title == null) {
    return Padding(
      padding: EdgeInsets.only(left: 2, right: 2),
      child: Column(
        children: _getMovieRows(items, context, rowItemNum, isPop),
      ),
    );
  }
  // 传标题
  return Padding(
    padding: EdgeInsets.only(left: 2, right: 2, top: 5),
    child: Column(
      children: <Widget>[
        // 行 - 标题
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.videocam),
              SizedBox(width: 3),
              Text(
                // 板块标题
                title,
                style: TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // 行 - 内容
        Column(
          children: _getMovieRows(items, context, rowItemNum, isPop,
              history: history),
        ),
      ],
    ),
  );
}
