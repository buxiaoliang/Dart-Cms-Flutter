import 'package:flutter/material.dart';

void showLoading(
  BuildContext topContext,
) {
  showDialog(
    context: topContext,
    builder: (context) {
      return WillPopScope(
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 115.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 140,
            child: new Center(
              ///弹框大小
              child: new SizedBox(
                width: 120.0,
                height: 120.0,
                child: new Container(
                  ///弹框背景和圆角
                  decoration: ShapeDecoration(
                    color: Color(0xffffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new CircularProgressIndicator(),
                      new Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                        ),
                        child: new Text(
                          "加载中",
                          style: new TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return false;
        },
      );
    },
  );
}

void hideLoading(BuildContext context) {
  Navigator.of(context).pop();
}
