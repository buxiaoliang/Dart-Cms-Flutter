import 'package:flutter/material.dart';
import '../utils/config.dart' show hostUrl;
import '../components/publicDialog.dart' show launchUrl;

Widget createMealList(List<dynamic> mealList) {
  // 遍历
  List<Widget> meal_child = mealList.map((cur) {
    // 恰饭图片地址
    String curMealImgUrl = hostUrl + cur.path;
    // 恰饭链接
    String curMealLink = cur.link;
    return GestureDetector(
      onTap: () {
        // 打开浏览器地址
        launchUrl(curMealLink);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
        child: Container(
          child: Image(
            image: NetworkImage(curMealImgUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }).toList();
  return Column(
    children: meal_child,
  );
}
