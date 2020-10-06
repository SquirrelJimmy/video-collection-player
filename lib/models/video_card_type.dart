import 'package:json_annotation/json_annotation.dart';


part 'video_card_type.g.dart';

@JsonSerializable()
class VideoCardType {
      VideoCardType();

  String last;
  String id;
  String tid;
  String name;
  String type;
  String pic;
  String lang;
  String area;
  String year;
  String state;
  String note;
  String actor;
  String director;
  Dl dl;
  String des;

  factory VideoCardType.fromJson(Map<String,dynamic> json) => _$VideoCardTypeFromJson(json);
  Map<String, dynamic> toJson() => _$VideoCardTypeToJson(this);
}

@JsonSerializable()
class Dl {
      Dl();

  String dd;

  factory Dl.fromJson(Map<String,dynamic> json) => _$DlFromJson(json);
  Map<String, dynamic> toJson() => _$DlToJson(this);
}
