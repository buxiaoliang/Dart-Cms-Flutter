import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// api
import '../../utils/api.dart' show AppAuthUpgrade, AppInitTipsInfo;
// config
import '../../utils/config.dart' show appUniqueKey;
// 首页
import './appBar.dart' show HomeAppBar;
// 工具
import '../../utils/tools.dart' show publicToast;
// conponents
import '../../components/publicDialog.dart' show createPubDialog, launchUrl;

// 首页 - 路由
class Home extends StatefulWidget {
  Map args;
  Home({Key key, this.args}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(args: args);
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  DateTime lastPopTime;
  Map args;
  BuildContext topContext;
  _HomeState({this.args});

  void _pullData() {
    AppAuthUpgrade((appData1) {
      // 成功 && 开启升级
      if (appData1.code == 200 && appData1.value.upgrade) {
        String appDownUrl = appData1.value.download;
        String dialogText = appData1.value.dialog;
        return showDialog(
          context: topContext,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: createPubDialog(
                title: "升级提示",
                icon: Icon(FontAwesomeIcons.cloudDownloadAlt),
                dialogContext: dialogText,
                cbWidget: () {
                  return RaisedButton(
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    onPressed: () {
                      // 打开浏览器地址
                      launchUrl(appDownUrl);
                    },
                    child: Text('确认'),
                  );
                },
              ),
            );
          },
        );
      }
      AppInitTipsInfo((appData2) {
        // 是否开启问候全家模式
        if (appData2.code == 200 && appData2.value.theSwitch) {
          showDialog(
            context: topContext,
            builder: (context) {
              return createPubDialog(
                title: "温馨提示",
                icon: Icon(FontAwesomeIcons.bullhorn),
                dialogContext: appData2.value.notice,
              );
            },
          );
        }
      });
    }, appUniqueKey);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pullData();
  }

  @override
  Widget build(BuildContext context) {
    topContext = context;
    // 首页 - appBar
    return WillPopScope(
      child: HomeAppBar(),
      onWillPop: () async {
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
          // 存储当前按下back键的时间
          lastPopTime = DateTime.now();
          // toast
          publicToast(
            "再按一次退出APP",
            context: context,
          );
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
