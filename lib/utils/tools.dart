import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ToastGravity => 位置映射
Map<String, ToastGravity> ToastAlign = {
  'bottom': ToastGravity.BOTTOM,
  'top': ToastGravity.TOP,
  'center': ToastGravity.CENTER
};

// 公共的Toast
Future<bool> publicToast(
  String msg, {
  BuildContext context,
  ToastGravity align: ToastGravity.BOTTOM,
}) {
  return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: align,
      timeInSecForIosWeb: 1,
      backgroundColor:
          context != null ? Theme.of(context).accentColor : Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0);
}

// 动态计算GridView父级的高度
double setContainerHight(
    {@required List arr,
    int lenH = 240,
    int limit = 3,
    bool isMax = false,
    int maxLen = 6}) {
  // int len = !isMax ? arr.length : (arr.length > maxLen) ? maxLen : arr.length;
  int len = !isMax || (isMax && arr.length < maxLen) ? arr.length : maxLen;
  double lineFloor = len / 3;
  int lineNum = lineFloor.ceil();
  return (lineNum * lenH).toDouble();
}
