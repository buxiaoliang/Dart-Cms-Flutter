import './request.dart' show HttpUtil; // axios
// 模型
import '../schema/type-list-schema.dart' show TypeListSchema;
import '../schema/nav-info-schema.dart' show NavInfoSchema;
import '../schema/video-detill-schema.dart' show CurVideoDetill;
import '../schema/all-type-schema.dart' show AllTypesDatas;
import '../schema/all-article-schema.dart' show AllArtItemList;
import '../schema/video-search-schema.dart' show VideoSearchResult;
import '../schema/article-ditell-schema.dart' show ArticleDitellSchema;
import '../schema/other-schema.dart' show AppInitNoticeCon, AppAuthUpgradeInfo;

// 获取首页所有的导航（视频导航）
void GetTypeList(Function cb) async {
  var result = null;
  await HttpUtil.get('/app/getTypeList', success: (data) {
    result = TypeListSchema.fromJson(data);
    cb(result);
  });
}

// 获取当前视频导航的数据
void GetCurNavData(Function cb, String nid) async {
  var result = null;
  await HttpUtil.get('/app/getCurNavItemList/${nid}', success: (data) {
    result = NavInfoSchema.fromJson(data);
    cb(result);
  });
}

// 获取当前视频的 详细信息、播放列表
void GetCurVideoDetill(Function cb, String vid, {Function error}) async {
  var result = null;
  await HttpUtil.get(
    '/app/getDetillData/${vid}',
    success: (data) {
      result = CurVideoDetill.fromJson(data);
      cb(result);
    },
    error: error,
  );
}

// 获取各种详细分类，以及分类下的数据
void GetTypesDatas(Function cb, String params) async {
  var result = null;
  await HttpUtil.get('/app/getTypesDatas?${params}', success: (data) {
    result = AllTypesDatas.fromJson(data);
    cb(result);
  });
}

// 获取所有的文章
void GetAllArtItems(Function cb, int page) async {
  var result = null;
  await HttpUtil.get('/app/getAllArtItemList', data: {'page': page},
      success: (data) {
    result = AllArtItemList.fromJson(data);
    cb(result);
  });
}

// 文章详细信息
void GetCurArtDetill(Function cb, String paramID, {Function error}) async {
  var result = null;
  await HttpUtil.get('/app/getArtDetill/${paramID}', error: error,
      success: (data) {
    result = ArticleDitellSchema.fromJson(data);
    cb(result);
  });
}

// 获取视频搜索结果
void GetVideoSearch(Function cb, String query, int page) async {
  var result = null;
  await HttpUtil.get('/app/getSearchDatas',
      data: {'name': query, 'page': page.toString()}, success: (data) {
    result = VideoSearchResult.fromJson(data);
    cb(result);
  });
}

// app检测升级
void AppAuthUpgrade(Function cb, String appKey) async {
  var result = null;
  await HttpUtil.get('/app/appAuthUpgrade', data: {'appKey': appKey},
      success: (data) {
    result = AppAuthUpgradeInfo.fromJson(data);
    cb(result);
  });
}

// app初始化公告
void AppInitTipsInfo(Function cb) async {
  var result = null;
  await HttpUtil.get('/app/appInitTipsInfo', success: (data) {
    result = AppInitNoticeCon.fromJson(data);
    cb(result);
  });
}
