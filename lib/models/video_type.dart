import 'package:json_annotation/json_annotation.dart';


part 'video_type.g.dart';

@JsonSerializable()
class VideoType {
      VideoType();

  String id;
  String label;

  factory VideoType.fromJson(Map<String,dynamic> json) => _$VideoTypeFromJson(json);
  Map<String, dynamic> toJson() => _$VideoTypeToJson(this);
}
