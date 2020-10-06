import 'package:fluttertoast/fluttertoast.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../index.dart';

class HHttpClient {
  HHttpClient([this.context, this._baseUrl]) {
    _options = Options(extra: {
      "context": context,
    }, headers: {
      'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
    });
    dio.options.baseUrl = _baseUrl;
  }

  BuildContext context;
  String _baseUrl = '';
  Options _options;
  static Dio dio = new Dio();

  static init() {
    dio.interceptors.add(Global.netCache);
  }

  netGet<T>(String path, Map<String, dynamic> queryParameters) async {
    var result = await dio.get<T>(path,
        queryParameters: queryParameters, options: _options);
    // print(result.request.headers.toString());
    if (result.statusCode >= 400) {
      Fluttertoast.showToast(
        msg: '请求错误, 请重试',
        backgroundColor: Color.fromARGB(128, 0, 0, 0),
        gravity: ToastGravity.CENTER,
      );
    }
    return result.data;
  }
}
