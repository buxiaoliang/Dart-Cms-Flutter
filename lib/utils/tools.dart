import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// utils loading
import '../utils/loading.dart' as Loading;
// api
import '../utils/api.dart' show GetCurVideoDetill;
// schema
import '../components/publicMovieGroup.dart' show VideoSchema;

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

// 公共的打开视频方法
Future<void> getVideoDetail(
  BuildContext context,
  String vid,
  bool isPop, {
  Map history,
}) async {
  // loading
  Loading.showLoading(context);
  // ajax
  await GetCurVideoDetill(
    (resData) {
      // query schema
      Map<String, dynamic> args = {
        'detillInfo': resData.value.videoInfo,
        'mealList': resData.value.mealList,
        'likeList': resData.value.list.likeMovie,
        'sourceList': resData.value.source,
      };
      if (history != null) {
        args["playFocus"] = history;
      }
      // router push
      Loading.hideLoading(context);
      if (isPop) {
        Navigator.of(context).pop();
      }

      Navigator.pushNamed(context, '/video', arguments: args);
    },
    vid,
    error: (msg) {
      Loading.hideLoading(context);
    },
  );
  // hide loading
  // Loading.hideLoading();
}
