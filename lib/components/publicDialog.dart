import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

Widget createPubDialog({
  @required String title,
  @required String dialogContext,
  @required Icon icon,
  Function cbWidget,
}) {
  return AlertDialog(
    contentPadding: EdgeInsets.only(
      top: 5,
      bottom: 5,
      left: 15,
      right: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: icon,
        ),
        Text(
          // 标题
          title,
          style: TextStyle(fontSize: 20),
        ),
      ],
    ),
    content: Container(
      height: 170,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Expanded(
            child: Container(
              child: ListView(
                children: <Widget>[
                  Text(
                    // 弹窗内容
                    dialogContext,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          cbWidget != null ? cbWidget() : Container()
        ],
      ),
    ),
  );
}
