import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// schema
import '../../schema/article-ditell-schema.dart'
    show ArticleDitellSchemaValueArticleResultCur;
// api
import '../../utils/api.dart' show GetCurArtDetill;

class Article extends StatefulWidget {
  Map args;
  Article({Key key, this.args}) : super(key: key);

  @override
  _ArticleState createState() => _ArticleState(args: args);
}

class _ArticleState extends State<Article> {
  Map args;
  ArticleDitellSchemaValueArticleResultCur artInfo;
  bool isInit = false;
  _ArticleState({this.args});

  Future<void> _pullData() async {
    GetCurArtDetill((data) {
      this.setState(() {
        artInfo = data.value.articleResult.cur;
        isInit = true;
      });
    }, args['schema'].Id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pullData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文章详情'),
      ),
      body: isInit
          ? RefreshIndicator(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      // 标题
                      Container(
                        child: Text(
                          artInfo.articleTitle,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      // 类型,时间
                      Row(
                        children: <Widget>[
                          Text('类型：${artInfo.articleType}'),
                          Text(' / '),
                          Text('时间：${artInfo.updateTime}')
                        ],
                      ),
                      // 正文
                      Html(data: artInfo.content)
                    ],
                  ),
                ),
              ),
              onRefresh: _pullData,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
