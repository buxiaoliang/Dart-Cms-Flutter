import 'package:flutter/material.dart';
// 路由组件 - tab - bottom
import 'views/home/index.dart' show Home; // 首页
import 'views/article/index.dart' show Article; // 文章详情页
import 'views/video/index.dart' show Video; // 视频详情页
import 'views/history/index.dart' show History; // 历史记录
import 'views/declare/index.dart' show Declare; // 免责申明
import 'views/interest/index.dart' show Interest; // 收藏影视

final RouterMap = {
  '/home': (BuildContext context, {args}) => Home(args: args),
  '/article': (BuildContext context, {args}) => Article(args: args),
  '/video': (BuildContext context, {args}) => Video(args: args),
  '/history': (BuildContext context, {args}) => History(args: args),
  '/declare': (BuildContext context, {args}) => Declare(args: args),
  '/interest': (BuildContext context, {args}) => Interest(args: args),
};

Route onGenerateRoute(RouteSettings settings) {
  // 路由参数
  final args = settings.arguments;
  // 路由对应的名称
  final String curName = settings.name;
  // 对应的组件
  final Function PageRouteContextBuilder = RouterMap[curName];

  if (PageRouteContextBuilder != null) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        var arg = args == null ? {} : args;
        return PageRouteContextBuilder(context, args: arg);
      },
    );
  }
}
