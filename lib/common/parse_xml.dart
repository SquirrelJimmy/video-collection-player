import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xml2json/xml2json.dart';

import '../index.dart';

const List<String> paginationKeys = [
  'page',
  'pagecount',
  'pagesize',
  'recordcount',
];

class XmlListResultModel {
  XmlListResultModel({
    this.videoIdList,
    this.videoTypeList,
    this.pagination,
  });
  Pagination pagination;
  List<String> videoIdList;
  List<VideoType> videoTypeList;
}

class ParseXmlToModel {
  static final Xml2Json _xml = Xml2Json();
  static XmlListResultModel fromXmlList(String xmlString) {
    try {
      _xml.parse(xmlString);
      var gDataJson = _xml.toGData();

      var valueGData = jsonDecode(gDataJson);

      Iterable videoListIterable = [];

      if (valueGData['rss']['list']['video'] != null) {
        videoListIterable = valueGData['rss']['list']['video'] is List<dynamic>
            ? valueGData['rss']['list']['video']
            : [valueGData['rss']['list']['video']];
      }

      final Iterable classListIterable = valueGData['rss']['class']['ty'];
      final Map<String, dynamic> paginationMap =
          (valueGData['rss']['list'] as Map<String, dynamic>).map((key, value) {
        MapEntry<String, dynamic> mapEntry;
        if (paginationKeys.contains(key)) {
          mapEntry = MapEntry<String, dynamic>(key, int.parse(value));
        } else {
          mapEntry = MapEntry(key, '');
        }

        return mapEntry;
      });
      final List<String> videoIdList = videoListIterable == null
          ? []
          : List<Map<String, dynamic>>.from(videoListIterable)
              .map((json) => (json['id']['\$t']).toString())
              .toList();
      final List<VideoType> videoTypeList =
          List<Map<String, dynamic>>.from(classListIterable)
              .map((json) => VideoType.fromJson({
                    'id': json['id'].toString(),
                    'label': (json['\$t'] as String)
                        .replaceAll(RegExp('\{.+\}'), ''),
                  }))
              .toList();
      final Pagination pagination = Pagination.fromJson(paginationMap);

      return XmlListResultModel(
        videoIdList: videoIdList,
        videoTypeList: videoTypeList,
        pagination: pagination,
      );
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'xml解析错误',
        backgroundColor: Color.fromARGB(128, 0, 0, 0),
        gravity: ToastGravity.CENTER,
      );
      return null;
    }
  }

  static xmlVideoResultModel(String xmlString) {
    try {
      _xml.parse(xmlString);
      var gDataJson = _xml.toParker();
      var value = jsonDecode(
        gDataJson
            .replaceAll("\\\"", "'")
            .replaceAll(r'\', '')
            .replaceAll(RegExp('<[^>]+>'), ''),
      );

      final Iterable videoListIterable =
          value['rss']['list']['video'] is List<dynamic>
              ? value['rss']['list']['video']
              : [value['rss']['list']['video']];
      final List<VideoCardType> videoList =
          List<Map<String, dynamic>>.from(videoListIterable)
              .map((json) => VideoCardType.fromJson(json))
              .toList();
      return videoList;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'xml解析错误',
        backgroundColor: Color.fromARGB(128, 0, 0, 0),
        gravity: ToastGravity.CENTER,
      );
      return null;
    }
  }

  static xmlSearchToModel(String xmlString) {
    try {
      _xml.parse(xmlString);
      var gDataJson = _xml.toGData();

      var valueGData = jsonDecode(gDataJson.replaceAll(r'\', ''));

      Iterable videoListIterable = [];

      if (valueGData['rss']['list']['video'] != null) {
        videoListIterable = valueGData['rss']['list']['video'] is List<dynamic>
            ? valueGData['rss']['list']['video']
            : [valueGData['rss']['list']['video']];
      }
      final Map<String, dynamic> paginationMap =
          (valueGData['rss']['list'] as Map<String, dynamic>).map((key, value) {
        MapEntry<String, dynamic> mapEntry;
        if (paginationKeys.contains(key)) {
          mapEntry = MapEntry<String, dynamic>(key, int.parse(value));
        } else {
          mapEntry = MapEntry(key, '');
        }

        return mapEntry;
      });

      final List<String> videoIdList = videoListIterable == null
          ? []
          : List<Map<String, dynamic>>.from(videoListIterable)
              .map((json) => (json['id']['\$t']).toString())
              .toList();

      final Pagination pagination = Pagination.fromJson(paginationMap);
      return XmlListResultModel(
        videoIdList: videoIdList,
        pagination: pagination,
      );
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'xml解析错误',
        backgroundColor: Color.fromARGB(128, 0, 0, 0),
        gravity: ToastGravity.CENTER,
      );
      return null;
    }
  }
}
