/*
 * @Author: Benster
 * @Date: 2020-11-02 19:37:03
 * @Description: qq SDK插件
 * @FilePath: /mall_yc/plugs/flutter_qq/lib/flutter_qq.dart
 */

import 'dart:async';
import 'package:flutter/services.dart';

class QQResult {
  int code = 1;
  String? message;
  Map<dynamic, dynamic>? response;
}

class FlutterQQ {
  static const MethodChannel _channel = const MethodChannel('flutter_qq');

  static void registerQQ(String appId, String univeralLink) async {
    await _channel.invokeMethod('registerQQ', {'appId': appId, 'univeralLink': univeralLink});
  }

  static Future<bool?> isQQInstalled() async {
    return await _channel.invokeMethod('isQQInstalled');
  }

  /// 登录
  static Future<QQResult> login() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('login');
    QQResult qqResult = QQResult();
    qqResult.code = result["Code"] ?? 1;
    qqResult.message = result["Message"];
    qqResult.response = result["Response"];
    return qqResult;
  }

  /// 获取用户信息
  static Future<QQResult> getUserInfo() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('getUserInfo');
    QQResult qqResult = QQResult();
    qqResult.code = result["Code"] ?? 1;
    qqResult.message = result["Message"];
    qqResult.response = result["Response"];
    return qqResult;
  }
}
