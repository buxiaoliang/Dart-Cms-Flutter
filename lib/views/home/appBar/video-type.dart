import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// schema
import '../../../schema/all-type-schema.dart';
// api
import '../../../utils/api.dart' show GetTypesDatas;
// components
import '../../../components/searchBar.dart' show SearchBar;
import '../../../components/publicMovieGroup.dart' show layoutGroupMovieCard;
// utils
import '../../../utils/loading.dart' as Loading;

// formantJson
class SortFrom {
  String Id;
  String name;
  SortFrom({this.Id, this.name});
}

class VideoType extends StatefulWidget {
  Map args;
  VideoType({Key key, this.args}) : super(key: key);

  @override
  _VideoTypeState createState() => _VideoTypeState(args: args);
}

class _VideoTypeState extends State<VideoType>
    with AutomaticKeepAliveClientMixin {
  Map args;
  // is init ?
  bool isInit = false;
  // params query
  Map<String, String> params = {
    'cid': '',
    'pid': '',
    'rel_time': '',
    'sub_region': '',
    'language': '',
    'page': '1',
    'sort': '_id'
  };
  List<SortFrom> sortList = [
    SortFrom(Id: '_id', name: '时间'),
    SortFrom(Id: 'rate', name: '人气'),
  ];

  // refresh
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  // 分类items
  List<AllTypesDatasValueCurQueryListList> curQueryList = [];
  AllTypesDatasValueAllTypeItem allTypeItem;
  _VideoTypeState({this.args});

  String _getParams() {
    List cache = [];
    params.forEach((key, value) {
      // 有效参数加入
      if (value.isNotEmpty) {
        cache.add('${key}=${value}');
      }
    });
    return cache.join('&');
  }

  Future<void> _pullData({bool refresh = true}) async {
    await GetTypesDatas((data) {
      this.setState(() {
        // if (mounted) {
        int curPage = data.value.curQueryList.page;
        int maxPage = (data.value.curQueryList.total / 36).ceil();
        params['page'] = curPage.toString();
        // 如果当前页是最后一页，锁定上滑加载
        if (curPage >= maxPage) {
          _refreshController.loadNoData();
        }
        allTypeItem = data.value.allTypeItem;
        // 是否重置列表
        if (refresh) {
          curQueryList = data.value.curQueryList.list;
        } else {
          // 不重置，则追加内容
          List<AllTypesDatasValueCurQueryListList> newQueryList =
              data.value.curQueryList.list;
          curQueryList.addAll(newQueryList);
        }
        isInit = true;
        // }
      });
    }, _getParams());
  }

  Future<void> _onRefresh() async {
    this.setState(() {
      params['page'] = '1';
    });
    await _pullData();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    int page = int.parse(params['page']);
    params['page'] = (++page).toString();
    await _pullData(refresh: false);
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  // 生成分类行中的各种细分类按钮
  List<Widget> _createTypeLine(List arr, String paramKey) {
    return arr.map((item) {
      return RaisedButton(
        padding: EdgeInsets.all(0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textColor: params[paramKey] == item.Id ? Colors.white : Colors.black,
        elevation: 0,
        color: params[paramKey] == item.Id
            ? Theme.of(context).accentColor
            : Colors.white,
        onPressed: () async {
          // 设置params的各项参数，并且刷新
          params[paramKey] = item.Id;
          // 刷新数据
          Loading.showLoading(context);
          await _pullData();
          Loading.hideLoading(context);
        },
        child: Text(
          item.name,
          style: TextStyle(fontSize: 14),
        ),
      );
    }).toList();
  }

  // 生成 分类行
  Widget _createTypesBox() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              Text('  ' + allTypeItem.nav.label + '：'),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(allTypeItem.nav.list, 'pid'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 2),
          Row(
            children: <Widget>[
              Text('  ' + allTypeItem.type.label + '：'),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(allTypeItem.type.list, 'cid'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 2),
          Row(
            children: <Widget>[
              Text('  ' + allTypeItem.region.label + '：'),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _createTypeLine(allTypeItem.region.list, 'sub_region'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 2),
          Row(
            children: <Widget>[
              Text('  ' + allTypeItem.years.label + '：'),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _createTypeLine(allTypeItem.years.list, 'rel_time'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 2),
          Row(
            children: <Widget>[
              Text('  ' + allTypeItem.language.label + '：'),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _createTypeLine(allTypeItem.language.list, 'language'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 2),
          Row(
            children: <Widget>[
              Text('  排序：'),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _createTypeLine(sortList, 'sort'),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('影片分类'),
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
                  switch (index) {
                    case 0:
                      return _createTypesBox();

                    case 1:
                      return layoutGroupMovieCard(
                        topList: curQueryList,
                        context: context,
                      );
                  }
                },
                // itemExtent: 100.0,
                itemCount: 2,
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
