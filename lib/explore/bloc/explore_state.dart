import 'dart:io';

import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';

enum ExploreStatus {
  initial,
  loading,
  success,
  error,
  empty,
  refreshing,
  paginating,
}

class ExploreState {
  ExploreState({
    required this.tabs,
    required this.postsByTabId,
    this.selectedTabId,
    this.isComposerVisible = false,
    this.status = ExploreStatus.initial,
    this.errorMessage,
    this.selectedImageFile,
  });

  final List<AppTab> tabs;
  final Map<String, List<PostWithUser>> postsByTabId;
  final String? selectedTabId;
  final bool isComposerVisible;
  final File? selectedImageFile;
  final ExploreStatus status;
  final String? errorMessage;

  ExploreState init() => ExploreState(
        tabs: <AppTab>[],
        postsByTabId: <String, List<PostWithUser>>{},
      );

  ExploreState copyWith({
    final List<AppTab>? tabs,
    final Map<String, List<PostWithUser>>? postsByTabId,
    final String? selectedTabId,
    final bool? isComposerVisible,
    final ExploreStatus? status,
    final String? errorMessage,
    final File? selectedImageFile,
    final bool selectedImageFileIsNull = false,
  }) =>
      ExploreState(
        tabs: tabs ?? this.tabs,
        postsByTabId: postsByTabId ?? this.postsByTabId,
        selectedTabId: selectedTabId ?? this.selectedTabId,
        isComposerVisible: isComposerVisible ?? this.isComposerVisible,
        status: status ?? this.status,
        errorMessage: errorMessage,
        selectedImageFile: selectedImageFileIsNull
            ? null
            : selectedImageFile ?? this.selectedImageFile,
      );
}
