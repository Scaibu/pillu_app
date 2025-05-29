// @dart = 3.0
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_tab.g.dart';

@JsonSerializable()
@immutable
abstract class AppTab {
  const factory AppTab({
    required final String id,
    required final String title,
    required final bool isVisible,
    required final int order,
  }) = _AppTab;

  const AppTab._({
    required this.id,
    required this.title,
    required this.isVisible,
    required this.order,
  });

  factory AppTab.fromJson(final Map<String, dynamic> json) =>
      _$AppTabFromJson(json);

  final String id;
  final String title;
  final bool isVisible;
  final int order;

  Map<String, dynamic> toJson() => _$AppTabToJson(this);

  List<Object?> get props => <Object?>[id, title, isVisible, order];

  AppTab copyWith({
    final String? id,
    final String? title,
    final bool? isVisible,
    final int? order,
  });
}

/// Private class to support immutability and override copyWith
class _AppTab extends AppTab {
  const _AppTab({
    required super.id,
    required super.title,
    required super.isVisible,
    required super.order,
  }) : super._();

  @override
  AppTab copyWith({
    final String? id,
    final String? title,
    final bool? isVisible,
    final int? order,
  }) =>
      _AppTab(
        id: id ?? this.id,
        title: title ?? this.title,
        isVisible: isVisible ?? this.isVisible,
        order: order ?? this.order,
      );
}
