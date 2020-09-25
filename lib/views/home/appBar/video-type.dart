import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// schema
import '../../../schema/all-type-schema.dart';
// api
import '../../../utils/api.dart' show GetTypesDatas;
// tools
import '../../../utils/tools.dart' show setContainerHight;
// components
import 'package:flutter_app/components/searchBar.dart' show SearchBar;

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

class _VideoTypeState extends State<VideoType> {
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
  bool lock = false;
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

  void _pullData({bool refresh = true}) async {
    await GetTypesDatas((data) {
      this.setState(() {
        // if (mounted) {
        int curPage = data.value.curQueryList.page;
        int maxPage = (data.value.curQueryList.total / 36).ceil();
        params['page'] = curPage.toString();
        // 如果当前页是最后一页，锁定上滑加载
        if (curPage >= maxPage) {
          lock = true;
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
          // if (newQueryList.length == 0) {
          //   lock = true;
          // }
        }
        isInit = true;
        // }
      });
    }, _getParams());
  }

  void _onRefresh() async {
    // monitor network fetch
    await _pullData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    int page = int.parse(params['page']);
    params['page'] = (++page).toString();
    // print(params['page']);
    await _pullData(refresh: false);
    // if failed,use refreshFailed()
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  // 生成视频列表
  Widget _createGridVideo() {
    return Container(
      height: setContainerHight(arr: curQueryList),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.5,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: curQueryList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child: GestureDetector(
              onTap: () {
                // query schema
                Map args = <String, AllTypesDatasValueCurQueryListList>{
                  'schema': curQueryList[index]
                };
                // router push
                Navigator.pushNamed(context, '/video', arguments: args);
              },
              child: Column(
                children: <Widget>[
                  Container(
                    height: 200,
                    child: FadeInImage(
                      placeholder: AssetImage('images/lazy.gif'),
                      image: NetworkImage(curQueryList[index].videoImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      curQueryList[index].videoTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
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
          await _pullData();
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
        title: Row(
          children: <Widget>[
            Expanded(child: Container(child: Text('影片分类'))),
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
      ),
      body: isInit
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    _createTypesBox(),
                    _createGridVideo(),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
