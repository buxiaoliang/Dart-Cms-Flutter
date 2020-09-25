import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './router.dart' show onGenerateRoute;

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

BuildContext topContext;

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    topContext = context;
    return MaterialApp(
      title: 'Dart-Cms管理系统',
      onGenerateRoute: onGenerateRoute,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      theme: ThemeData(
        accentColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
