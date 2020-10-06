import 'package:json_annotation/json_annotation.dart';


part 'video_source_type.g.dart';

@JsonSerializable()
class VideoSourceType {
      VideoSourceType();

  int id;
  String name;
  String uri;
  String httpsApi;
  String httpApi;
  String type;

  factory VideoSourceType.fromJson(Map<String,dynamic> json) => _$VideoSourceTypeFromJson(json);
  Map<String, dynamic> toJson() => _$VideoSourceTypeToJson(this);
}
