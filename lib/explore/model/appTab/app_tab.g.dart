// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'app_tab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppTab _$AppTabFromJson(Map<String, dynamic> json) => AppTab(
      id: json['id'] as String,
      title: json['title'] as String,
      isVisible: json['isVisible'] as bool,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$AppTabToJson(AppTab instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isVisible': instance.isVisible,
      'order': instance.order,
    };
