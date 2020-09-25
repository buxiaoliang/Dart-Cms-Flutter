import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// 首页tabbar对应的组件
import './appBar/home.dart' show Home; // 首页 - tabBar（0）
import './appBar/article-type.dart' show ArticleType; // 首页 - tabBar（1）
import './appBar/video-type.dart' show VideoType; // 首页 - tabBar（2）
import './appBar/user.dart' show User; // 首页 - tabBar（3）

class HomeAppBar extends StatefulWidget {
  HomeAppBar({Key key}) : super(key: key);

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  // 当前tab下标
  int _curTabIndex = 0;

  List TabItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
    BottomNavigationBarItem(icon: Icon(Icons.bookmark), title: Text('文章')),
    BottomNavigationBarItem(icon: Icon(Icons.view_list), title: Text('分类')),
    BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我的')),
  ];

  List TabBodys = <Widget>[
    Home(),
    ArticleType(),
    VideoType(),
    User(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        items: TabItems,
        currentIndex: _curTabIndex,
        fixedColor: Theme.of(context).accentColor,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          this.setState(() {
            _curTabIndex = index;
          });
        },
      ),
      body: TabBodys[_curTabIndex],
    );
  }
}
