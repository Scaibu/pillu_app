import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/post/post.dart';
import 'package:pillu_app/explore/repository/post_repository.dart';
import 'package:uuid/uuid.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc(this._postRepository)
      : super(
          ExploreState(
            tabs: <AppTab>[],
            postsByTabId: <String, List<Post>>{},
          ),
        ) {
    on<ExploreInitEvent>(_init);
    on<CreateAppTab>(_createTab);
    on<UpdateAppTab>(_updateTab);
    on<DeleteAppTab>(_deleteTab);
    on<CreatePost>(_createPost);
    on<UpdatePost>(_updatePost);
    on<DeletePost>(_deletePost);
    on<SelectTabEvent>(
        (final SelectTabEvent event, final Emitter<ExploreState> emit) {
      emit(state.copyWith(selectedTabId: event.tabId));
    });
    on<TogglePostComposer>(
        (final TogglePostComposer event, final Emitter<ExploreState> emit) {
      emit(state.copyWith(isComposerVisible: event.isSelected));
    });
  }

  final PostRepository _postRepository;

  static const Uuid _uuid = Uuid();

  Future<void> _init(
    final ExploreInitEvent event,
    final Emitter<ExploreState> emit,
  ) async {
    final List<AppTab> tabs = <AppTab>[
      AppTab(id: _uuid.v4(), title: 'All', isVisible: true, order: 0),
      AppTab(id: _uuid.v4(), title: 'Following', isVisible: true, order: 1),
      AppTab(id: _uuid.v4(), title: 'For You', isVisible: true, order: 2),
    ];

    final String allTabId =
        tabs.firstWhere((final AppTab tab) => tab.title == 'All').id;

    final List<Post> samplePosts = List<Post>.generate(
      3,
      (final int index) => Post(
        id: _uuid.v4(),
        authorId: 'author_$index',
        type: PostType.text,
        text: 'Sample Post ${index + 1}',
        createdAt: DateTime.now(),
      ),
    );

    final Map<String, List<Post>> postsByTabId = <String, List<Post>>{
      for (final AppTab tab in tabs)
        tab.id: tab.id == allTabId ? samplePosts : <Post>[],
    };

    emit(
      ExploreState(
        tabs: tabs,
        postsByTabId: postsByTabId,
        selectedTabId: allTabId,
      ),
    );
  }

  void _createTab(final CreateAppTab event, final Emitter<ExploreState> emit) {
    final List<AppTab> updatedTabs = <AppTab>[...state.tabs, event.tab];
    final Map<String, List<Post>> updatedPosts =
        Map<String, List<Post>>.from(state.postsByTabId)
          ..putIfAbsent(event.tab.id, () => <Post>[]);
    emit(state.copyWith(tabs: updatedTabs, postsByTabId: updatedPosts));
  }

  void _updateTab(final UpdateAppTab event, final Emitter<ExploreState> emit) {
    final List<AppTab> updatedTabs = state.tabs
        .map((final AppTab tab) => tab.id == event.tab.id ? event.tab : tab)
        .toList();
    emit(state.copyWith(tabs: updatedTabs));
  }

  void _deleteTab(final DeleteAppTab event, final Emitter<ExploreState> emit) {
    final List<AppTab> updatedTabs =
        state.tabs.where((final AppTab tab) => tab.id != event.tabId).toList();
    final Map<String, List<Post>> updatedPosts =
        Map<String, List<Post>>.from(state.postsByTabId)..remove(event.tabId);
    emit(state.copyWith(tabs: updatedTabs, postsByTabId: updatedPosts));
  }

  Future<void> _createPost(
    final CreatePost event,
    final Emitter<ExploreState> emit,
  ) async {
    final List<Post> posts =
        List<Post>.from(state.postsByTabId[event.tabId] ?? <Post>[])
          ..add(event.post);

    final Map<String, List<Post>> updatedPosts =
        Map<String, List<Post>>.from(state.postsByTabId)..[event.tabId] = posts;

    emit(state.copyWith(postsByTabId: updatedPosts));

    try {
      await _postRepository.createPost(event.post);
    } catch (e) {
      debugPrint('Failed to create post in Firestore: $e');
    }
  }

  void _updatePost(final UpdatePost event, final Emitter<ExploreState> emit) {
    final List<Post> posts = (state.postsByTabId[event.tabId] ?? <Post>[])
        .map((final Post p) => p.id == event.post.id ? event.post : p)
        .toList();
    final Map<String, List<Post>> updatedPosts =
        Map<String, List<Post>>.from(state.postsByTabId)..[event.tabId] = posts;
    emit(state.copyWith(postsByTabId: updatedPosts));
  }

  void _deletePost(final DeletePost event, final Emitter<ExploreState> emit) {
    final List<Post> posts = (state.postsByTabId[event.tabId] ?? <Post>[])
        .where((final Post p) => p.id != event.postId)
        .toList();
    final Map<String, List<Post>> updatedPosts =
        Map<String, List<Post>>.from(state.postsByTabId)..[event.tabId] = posts;
    emit(state.copyWith(postsByTabId: updatedPosts));
  }
}
