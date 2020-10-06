// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return Pagination()
    ..page = json['page'] as int
    ..pagecount = json['pagecount'] as int
    ..pagesize = json['pagesize'] as int
    ..recordcount = json['recordcount'] as int;
}

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pagecount': instance.pagecount,
      'pagesize': instance.pagesize,
      'recordcount': instance.recordcount,
    };
