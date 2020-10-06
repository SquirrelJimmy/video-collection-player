// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoCard _$VideoCardFromJson(Map<String, dynamic> json) {
  return VideoCard()
    ..last = json['last'] as String
    ..id = json['id'] as String
    ..tid = json['tid'] as String
    ..name = json['name'] as String
    ..type = json['type'] as String
    ..pic = json['pic'] as String
    ..lang = json['lang'] as String
    ..area = json['area'] as String
    ..year = json['year'] as String
    ..state = json['state'] as String
    ..note = json['note'] as String
    ..actor = json['actor'] as String
    ..director = json['director'] as String
    ..dl = json['dl'] == null
        ? null
        : Dl.fromJson(json['dl'] as Map<String, dynamic>)
    ..des = json['des'] as String;
}

Map<String, dynamic> _$VideoCardToJson(VideoCard instance) => <String, dynamic>{
      'last': instance.last,
      'id': instance.id,
      'tid': instance.tid,
      'name': instance.name,
      'type': instance.type,
      'pic': instance.pic,
      'lang': instance.lang,
      'area': instance.area,
      'year': instance.year,
      'state': instance.state,
      'note': instance.note,
      'actor': instance.actor,
      'director': instance.director,
      'dl': instance.dl,
      'des': instance.des,
    };

Dl _$DlFromJson(Map<String, dynamic> json) {
  return Dl()..dd = json['dd'] as String;
}

Map<String, dynamic> _$DlToJson(Dl instance) => <String, dynamic>{
      'dd': instance.dd,
    };
