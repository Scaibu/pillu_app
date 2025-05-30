import 'dart:io';

import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';

abstract class ExploreEvent {}

class ExploreInitEvent extends ExploreEvent {}

// AppTab CRUD
class CreateAppTab extends ExploreEvent {
  CreateAppTab(this.tab);

  final AppTab tab;
}

class UpdateAppTab extends ExploreEvent {
  UpdateAppTab(this.tab);

  final AppTab tab;
}

class DeleteAppTab extends ExploreEvent {
  DeleteAppTab(this.tabId);

  final String tabId;
}

// Post CRUD
class CreatePost extends ExploreEvent {
  CreatePost({required this.tabId, required this.postWithUser});

  final String tabId;
  final PostWithUser postWithUser;
}

class UpdatePost extends ExploreEvent {
  UpdatePost({required this.tabId, required this.postWithUser});

  final String tabId;
  final PostWithUser postWithUser;
}

class DeletePost extends ExploreEvent {
  DeletePost({
    required this.tabId,
    required this.postId,
    required this.imageUrl,
  });

  final String tabId;
  final String postId;
  final String? imageUrl;
}

class SelectTabEvent extends ExploreEvent {
  SelectTabEvent(this.tabId);

  final String tabId;
}

class TogglePostComposer extends ExploreEvent {
  TogglePostComposer({required this.isSelected});

  final bool isSelected;
}

class SelectImageEvent extends ExploreEvent {
  SelectImageEvent(this.imageFile);

  final File imageFile;
}

class UnselectImageEvent extends ExploreEvent {}

class FetchPostsByTabTypeEvent extends ExploreEvent {
  FetchPostsByTabTypeEvent(this.appTabType);

  final String appTabType;
}
