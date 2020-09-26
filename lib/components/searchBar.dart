import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../schema/video-search-schema.dart';
// api
import '../utils/api.dart' show GetVideoSearch;
// schema
import '../schema/video-search-schema.dart';

class SearchBar extends SearchDelegate<String> {
  //复写点击搜索框右侧图标方法,此方法也就是点击右侧图标的回调函数,点击右侧图标把搜索内容情空
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        //点击后清除搜索框内容
        onPressed: () => query = '',
      ),
    ];
  }

  //点击搜索框右侧的图标,案例这里放的是返回按钮
  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  //点击了搜索显示的页面
  @override
  Widget buildResults(BuildContext context) {
    return soResult(query, UniqueKey());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

// 搜索结果
class soResult extends StatefulWidget {
  String query;
  final UniqueKey newKey;
  soResult(this.query, this.newKey) : super(key: newKey);

  @override
  _soResultState createState() => _soResultState(query);
}

class _soResultState extends State<soResult>
    with AutomaticKeepAliveClientMixin {
  String query;
  bool isInit = false;
  bool lock = false;
  int page = 1;

  _soResultState(this.query, {Key key});
  // refresh
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  // search result
  List<VideoSearchResultValueSearchResultList> resultList = [];

  @override
  @override
  void initState() {
    super.initState();
    _pullData();
  }

  // 每一项结果
  List<Widget> _bulderItems(BuildContext context) {
    return resultList.map((cursor) {
      return GestureDetector(
        onTap: () {
          // query schema
          Map args = <String, dynamic>{'schema': cursor};
          // router push
          Navigator.pushNamed(context, '/video', arguments: args);
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: <Widget>[
              Container(
                width: 130,
                height: 190,
                // child: Image(image: NetworkImage(item.articleImage)),
                child: FadeInImage(
                  placeholder: AssetImage('images/lazy.gif'),
                  image: NetworkImage(cursor.videoImage),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      cursor.videoTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text('类型： '),
                        Text(cursor.videoType.name),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text('年代： '),
                        Text(cursor.relTime),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text('语言： '),
                        Text(cursor.language),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text('地区： '),
                        Text(cursor.subRegion),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  RaisedButton(
                    onPressed: () {
                      // query schema
                      Map args = {'schema': cursor};
                      // router push
                      Navigator.pushNamed(context, '/video', arguments: args);
                    },
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Text('点击播放'),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _createBody(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Column(
            children: _bulderItems(context),
          ),
        ),
      ),
    );
  }

  // ajax pull result
  Future<void> _pullData({bool refresh = true}) async {
    GetVideoSearch((data) {
      int curPage = data.value.searchResult.page;
      int maxPage = (data.value.searchResult.total / 10).ceil();
      // 如果当前页是最后一页，锁定上滑加载
      if (curPage >= maxPage) {
        this.setState(() {
          lock = true;
        });
      }
      page = data.value.searchResult.page;
      // is refresh
      if (!refresh) {
        List<VideoSearchResultValueSearchResultList> newResultList =
            data.value.searchResult.list;
        resultList.addAll(newResultList);
      } else {
        this.setState(() {
          resultList = data.value.searchResult.list;
        });
      }
      this.setState(() {
        isInit = true;
      });
    }, query, page);
  }

  void _onRefresh() async {
    await _pullData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    page++;
    await _pullData(refresh: false);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return isInit
        ? SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: MaterialClassicHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (lock) {
                  body = Text("没有更多数据了!");
                } else {
                  if (mode == LoadStatus.idle) {
                    body = Text("上拉加载");
                  } else if (mode == LoadStatus.loading) {
                    body = CircularProgressIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("加载失败！点击重试！");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("松手,加载更多!");
                  }
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _createBody(context),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  @override
  bool get wantKeepAlive => true;
}
