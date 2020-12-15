library smart_dio;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class ApiService {
  static Dio dio = new Dio();
  static Future<Map<String, dynamic>> put(
      String url, Map<dynamic, dynamic> body,
      {bool globalDio = false, bool saveData = false, bool enableOffline=false}) async {
    Box box;
    await Hive.openBox("get");
    box = Hive.box('get');
    try {
      Response response = globalDio
          ? await dio.put(url, data: body)
          : await Dio().put(url, data: body);
      if(saveData){
        box.put(url, response.data);
      }
      return response.data;
    } on DioError catch (e) {
      if(enableOffline && box.containsKey(url)){
        var b = box.get(url);
        var m = jsonEncode(b);
        var map = jsonDecode(m);
        print("From Offline");
        return map;
      }
      if (e.response != null) {
        throw TunnelException(message: e.response.data);
      } else {
        throw TunnelException(message: e.message);
      }
    }
  }

  static Future<Map<String, dynamic>> patch(
      String url, Map<dynamic, dynamic> body,
      {bool globalDio = false, bool saveData = false, bool enableOffline = false}) async {
    Box box;
    await Hive.openBox("get");
    box = Hive.box('get');
    try {
      Response response = globalDio
          ? await dio.patch(url, data: body)
          : await Dio().patch(url, data: body);
      if(saveData){
        box.put(url, response.data);
      }
      return response.data;
    } on DioError catch (e) {
      if (enableOffline && box.containsKey(url)) {
        var b = box.get(url);
        var m = jsonEncode(b);
        var map = jsonDecode(m);
        print("From Offline");
        return map;
      }
      if (e.response != null) {
        throw TunnelException(message: e.response.data);
      } else {
        throw TunnelException(message: e.message);
      }
    }
  }

  static Future<Map<String, dynamic>> post(String url,
      {Map<String, dynamic> body,
      bool globalDio = false,
      bool saveData = false,
      bool enableOffline = false,}) async {
    Box box;
    await Hive.openBox("get");
    box = Hive.box('get');

    try {
      Response response = globalDio
          ? await dio.post(url, data: body)
          : await Dio().post(url, data: body);
      if(saveData){
        box.put(url, response.data);
      }
      return response.data;
    } on DioError catch (e) {
      if (enableOffline && box.containsKey(url)) {
        var b = box.get(url);
        var m = jsonEncode(b);
        var map = jsonDecode(m);
        print("From Offline");
        return map;
      }
      if (e.response != null) {
        throw TunnelException(message: e.response.data);
      } else {
        throw TunnelException(message: e.message);
      }
    }
  }

  static Future<Map<String, dynamic>> get(String url,
      {Map<dynamic, dynamic> map,
      bool globalDio = false,
      bool saveData = true,
        bool enableOffline = true,
      }) async {
    var path = (await getApplicationDocumentsDirectory()).path;
    Hive..init(path);
    Box box;
    await Hive.openBox("get");
    box = Hive.box('get');

    try {
      Response response = globalDio ? await dio.get(url) : await Dio().get(url);
      if(saveData){
        box.put(url, response.data);
      }
      print("From Online");
      return response.data;
    } on DioError catch (e) {
      if (enableOffline && box.containsKey(url)) {
        var b = box.get(url);
        var m = jsonEncode(b);
        var map = jsonDecode(m);
        print("From Offline");
        return map;
      }
      if (e.response != null) {
        throw TunnelException(message: e.response.data);
      } else {
        throw TunnelException(message: e.message);
      }
    }
  }
}

class TunnelException implements Exception {
  final dynamic message;

  TunnelException({this.message});

  String toString() {
    return message ?? "Something went wrong!";
  }
}
