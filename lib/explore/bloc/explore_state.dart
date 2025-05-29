import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/post/post.dart';

class ExploreState {
  ExploreState({
    required this.tabs,
    required this.postsByTabId,
    this.selectedTabId,
    this.isComposerVisible = false,
  });

  final List<AppTab> tabs;
  final Map<String, List<Post>> postsByTabId;
  final String? selectedTabId;
  final bool isComposerVisible;

  ExploreState init() => ExploreState(
        tabs: <AppTab>[],
        postsByTabId: <String, List<Post>>{},
      );

  ExploreState copyWith({
    final List<AppTab>? tabs,
    final Map<String, List<Post>>? postsByTabId,
    final String? selectedTabId,
    final bool? isComposerVisible,
  }) =>
      ExploreState(
        tabs: tabs ?? this.tabs,
        postsByTabId: postsByTabId ?? this.postsByTabId,
        selectedTabId: selectedTabId ?? this.selectedTabId,
        isComposerVisible: isComposerVisible ?? this.isComposerVisible,
      );
}
