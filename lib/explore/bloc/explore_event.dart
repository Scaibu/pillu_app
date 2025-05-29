import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/post/post.dart';

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
  CreatePost({required this.tabId, required this.post});

  final String tabId;
  final Post post;
}

class UpdatePost extends ExploreEvent {
  UpdatePost({required this.tabId, required this.post});

  final String tabId;
  final Post post;
}

class DeletePost extends ExploreEvent {
  DeletePost({required this.tabId, required this.postId});

  final String tabId;
  final String postId;
}

class SelectTabEvent extends ExploreEvent {
  SelectTabEvent(this.tabId);

  final String tabId;
}

class TogglePostComposer extends ExploreEvent {
  TogglePostComposer({required this.isSelected});

  final bool isSelected;
}
