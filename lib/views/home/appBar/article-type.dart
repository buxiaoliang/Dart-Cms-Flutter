import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// conponents
import '../../../components/searchBar.dart';
// schema
import '../../../schema/all-article-schema.dart' show AllArtItemListValueList;
// api
import '../../../utils/api.dart' show GetAllArtItems;

class ArticleType extends StatefulWidget {
  Map args;
  ArticleType({Key key, this.args}) : super(key: key);

  @override
  _ArticleTypeState createState() => _ArticleTypeState(args: args);
}

class _ArticleTypeState extends State<ArticleType>
    with AutomaticKeepAliveClientMixin {
  Map args;
  // refresh
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  // is init ?
  bool isInit = false;
  int page = 1;
  // art items
  List<AllArtItemListValueList> allArtItems;
  _ArticleTypeState({this.args});

  // 拉数据
  Future<void> _pullData({bool refresh = true}) async {
    await GetAllArtItems((data) {
      this.setState(() {
        int curPage = data.value.page;
        int maxPage = (data.value.total / 10).ceil();
        // 如果当前页是最后一页，锁定上滑加载
        if (curPage >= maxPage) {
          _refreshController.loadNoData();
        }
        page = data.value.page;
        // 判断是否重置，刷新
        if (refresh) {
          allArtItems = data.value.list;
        } else {
          List<AllArtItemListValueList> newAllArtItems = data.value.list;
          allArtItems.addAll(newAllArtItems);
        }
        isInit = true;
      });
    }, page);
  }

  Future<void> _onRefresh() async {
    this.setState(() {
      page = 1;
    });
    await _pullData();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    page++;
    await _pullData(refresh: false);
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文章分类'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 跳转到搜索
              print('跳转到搜索');
              // SearchBar();
              showSearch(context: context, delegate: SearchBar());
            },
          )
        ],
      ),
      body: isInit
          ? SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: MaterialClassicHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("上拉加载");
                  } else if (mode == LoadStatus.loading) {
                    body = Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(width: 20),
                        Text('内容加载中'),
                      ],
                    );
                  } else if (mode == LoadStatus.failed) {
                    body = Text("加载失败！点击重试！");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("松手,加载更多!");
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
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  AllArtItemListValueList item = allArtItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black12, width: 1)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          // query schema
                          Map args = <String, AllArtItemListValueList>{
                            'schema': item
                          };
                          // router
                          Navigator.pushNamed(context, '/article',
                              arguments: args);
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 60,
                              // child: Image(image: NetworkImage(item.articleImage)),
                              child: FadeInImage(
                                placeholder: AssetImage('images/lazy.gif'),
                                image: NetworkImage(item.articleImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                child: Text(
                                  item.articleTitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                // itemExtent: 100.0,
                itemCount: allArtItems.length,
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
