import 'package:json_annotation/json_annotation.dart';


part 'video_card.g.dart';

@JsonSerializable()
class VideoCard {
      VideoCard();

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

  factory VideoCard.fromJson(Map<String,dynamic> json) => _$VideoCardFromJson(json);
  Map<String, dynamic> toJson() => _$VideoCardToJson(this);
}

@JsonSerializable()
class Dl {
      Dl();

  String dd;

  factory Dl.fromJson(Map<String,dynamic> json) => _$DlFromJson(json);
  Map<String, dynamic> toJson() => _$DlToJson(this);
}
