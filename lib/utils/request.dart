import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/tools.dart' show publicToast, ToastAlign;
import './config.dart' show hostUrl;

class BaseUrl {
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 3000;
}

class HttpUtil {
  static Future<void> get(String url,
      {Map<String, dynamic> data,
      Map<String, dynamic> headers = const {'Content-Type': 'application/json'},
      Map<String, bool> toast = const {'success': false, 'error': true},
      Function success,
      Function error}) async {
    // 数据拼接
    if (data != null && data.isNotEmpty) {
      StringBuffer options = new StringBuffer('?');
      data.forEach((key, value) {
        options.write('${key}=${value}&');
      });
      String optionsStr = options.toString();
      optionsStr = optionsStr.substring(0, optionsStr.length - 1);
      url += optionsStr;
    }

    // 发送get请求
    await _sendRequest(url, 'get', success,
        headers: headers, toast: toast, error: error);
  }

  static Future<void> post(String url,
      {Map<String, dynamic> data,
      Map<String, dynamic> headers,
      Function success,
      Function error}) async {
    // 发送post请求
    await _sendRequest(url, 'post', success,
        data: data, headers: headers, error: error);
  }

  // 请求处理
  static Future _sendRequest(String url, String method, Function success,
      {Map<String, dynamic> data,
      Map<String, dynamic> headers,
      Map toast,
      Function error}) async {
    int _code;
    String _msg;
    var _backData;

    // 检测请求地址是否是完整地址
    if (!url.startsWith('http')) {
      url = hostUrl + url;
    }

    try {
      Map<String, dynamic> dataMap = data == null ? new Map() : data;
      Map<String, dynamic> headersMap = headers == null ? new Map() : headers;

      // 配置dio请求信息
      Response response;
      Dio dio = new Dio();
      // 服务器链接超时，毫秒
      dio.options.connectTimeout = BaseUrl.connectTimeout;
      // 响应流上前后两次接受到数据的间隔，毫秒
      dio.options.receiveTimeout = BaseUrl.receiveTimeout;
      // 添加headers,如需设置统一的headers信息也可在此添加
      dio.options.headers.addAll(headersMap);

      if (method == 'get') {
        response = await dio.get(url);
      } else {
        response = await dio.post(url, data: dataMap);
      }

      if (response.statusCode != 200) {
        _msg = '网络请求错误,状态码:' + response.statusCode.toString();
        _handError(error, _msg, toast['error']);
        return;
      }

      // 返回结果处理
      Map<String, dynamic> resCallbackMap = response.data;
      _code = resCallbackMap['code'];
      _msg = resCallbackMap['text'];
      _backData = resCallbackMap['value'];

      if (success != null) {
        if (_code == 200) {
          // 提示
          if (toast['success']) {
            publicToast(_msg);
          }
          // 成功回调
          success(resCallbackMap);
        } else {
          String errorMsg = _code.toString() + ':' + _msg;
          _handError(error, errorMsg, toast['error']);
        }
      }
    } catch (exception) {
      // _handError(error, '数据请求错误：' + exception.toString(), toast['error']);
      _handError(error, '数据请求错误', toast['error']);
    }
  }

  // 返回错误信息
  static void _handError(Function errorCallback, String errorMsg, bool toast) {
    // 提示
    if (toast) {
      publicToast(errorMsg);
    }
    // 错误回调
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
  }
}
