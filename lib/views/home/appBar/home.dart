import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:transparent_image/transparent_image.dart';
// conponents
import '../../../components/searchBar.dart';
// api
import '../../../utils/api.dart' show GetTypeList, GetCurNavData;
// schema
import '../../../schema/nav-info-schema.dart';
// tools
import '../../../utils/tools.dart' show setContainerHight;

class Home extends StatefulWidget {
  Map args;
  Home({Key key, this.args}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(args: args);
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Map args;
  TabController _tabController;
  int _index;
  _HomeState({this.args});
  List _tabData = <Map<String, String>>[];

  // 初始化先拉接口，然后初始化tabbar
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 0);
    _tabController.addListener(() {
      setState(() => _index = _tabController.index);
      print("点击tabBar下标-> ${_tabController.indexIsChanging}");
    });
    var This = this;
    GetTypeList(
      (schema) {
        List val = schema.value;
        _tabData =
            val.map((item) => {'name': item.name, 'Id': item.Id}).toList();
        this.setState(
          () {
            _tabController = new TabController(
                vsync: This, //固定写法
                length: val.length //指定tab长度
                );
            // 设置label
          },
        );
      },
    );
  }

  // 生成tabBarView
  List<Widget> _GetHomeBodys() {
    List list = <Widget>[];
    for (int i = 0; i < _tabData.length; i++) {
      Widget hoemBody = HomeBody(_tabData[i]['Id']);
      list.add(hoemBody);
    }
    return list;
  }

  // 销毁
  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Text('data');
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // 跳转到搜索
                  print('跳转到搜索');
                  // SearchBar();
                  showSearch(context: context, delegate: SearchBar());
                },
                child: Container(
                  height: 30,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // 跳转到搜索
                  print('跳转到搜索');
                  // SearchBar();
                  showSearch(context: context, delegate: SearchBar());
                },
              ),
            )
          ],
        ),
        bottom: TabBar(
          tabs: _tabData.map((e) => Tab(text: e['name'])).toList(),
          isScrollable: true,
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _GetHomeBodys(),
      ),
    );
  }
}

// home内容
class HomeBody extends StatefulWidget {
  String _path;
  HomeBody(this._path, {Key key}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState(_path);
}

class _HomeBodyState extends State<HomeBody> {
  // 当前页的objectID
  String _path;
  // 是否开启轮播图
  bool _isOpenSwiper = false;
  // 轮播图
  List _swiperItems = <NavInfoSchemaValueSwiperList>[];
  // 一组内容
  List _contextItems = <NavInfoSchemaValueTabList>[];
  // 《带带大师兄》要吃饭的嘛
  List _mealItems = <NavInfoSchemaValueMealList>[];
  // 是否已经初始化
  bool isInit = false;
  _HomeBodyState(this._path);

  void _pullData() async {
    await GetCurNavData((data) {
      if (mounted) {
        this.setState(() {
          _swiperItems = data.value.swiperList;
          _isOpenSwiper = data.value.isOpenSwiper;
          _contextItems = data.value.tabList;
          _mealItems = data.value.mealList;
          isInit = true;
        });
      }
    }, this._path);
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    await _pullData();
  }

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isInit
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: RefreshIndicator(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    // 轮播图
                    SwiperCard(_swiperItems),
                    // 卡片组
                    CardGroup(_contextItems),
                  ],
                ),
              ),
              onRefresh: _onRefresh,
            ),
          );
  }
}

// ------
// swiper
// ------
class SwiperCard extends StatefulWidget {
  List _data = <NavInfoSchemaValueSwiperList>[];
  SwiperCard(this._data, {Key key}) : super(key: key);

  @override
  _SwiperCardState createState() => _SwiperCardState(_data);
}

class _SwiperCardState extends State<SwiperCard> {
  List _data = <NavInfoSchemaValueSwiperList>[];
  _SwiperCardState(this._data);

  @override
  Widget build(BuildContext context) {
    return _data.length > 0
        ? Container(
            height: 160,
            child: new Swiper(
              itemBuilder: (BuildContext context, int index) {
                return new Image.network(
                  _data[index].poster,
                  fit: BoxFit.fill,
                  height: 160,
                );
              },
              onTap: (index) {
                // query schema
                Map args = <String, dynamic>{'schema': _data[index]};
                // router push
                Navigator.pushNamed(context, '/video', arguments: args);
              },
              itemCount: _data.length,
              pagination: new SwiperPagination(),
            ),
          )
        : Container();
  }
}

// 一组卡片，分为标题和list数据
class CardGroup extends StatefulWidget {
  List _items = <NavInfoSchemaValueTabList>[];
  CardGroup(this._items, {Key key}) : super(key: key);

  @override
  _CardGroupState createState() => _CardGroupState(_items);
}

class _CardGroupState extends State<CardGroup> {
  List _items = <NavInfoSchemaValueTabList>[];
  _CardGroupState(this._items);

  List<Widget> _buildWidget() {
    List _cardList = <Widget>[];
    _cardList = _items.map((curItem) {
      return curItem.list.length > 0
          ? Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
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
                          curItem.name,
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: setContainerHight(
                      arr: curItem.list,
                      isMax: true,
                      maxLen: 6,
                    ),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.485,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            curItem.list.length >= 6 ? 6 : curItem.list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              // query schema
                              Map args =
                                  <String, NavInfoSchemaValueTabListList>{
                                'schema': curItem.list[index]
                              };
                              // router push
                              Navigator.pushNamed(context, '/video',
                                  arguments: args);
                            },
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 200,
                                  child: FadeInImage(
                                    placeholder: AssetImage('images/lazy.gif'),
                                    image: NetworkImage(
                                        curItem.list[index].videoImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    curItem.list[index].videoTitle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  )
                ],
              ),
            )
          : Container();
    }).toList();
    return _cardList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: _buildWidget());
  }
}
