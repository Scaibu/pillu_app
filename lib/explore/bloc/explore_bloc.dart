import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';
import 'package:pillu_app/explore/repository/post_repository.dart';
import 'package:uuid/uuid.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc(this._postRepository)
      : super(
          ExploreState(
            tabs: <AppTab>[],
            postsByTabId: <String, List<PostWithUser>>{},
          ),
        ) {
    on<ExploreInitEvent>(_init);
    on<CreateAppTab>(_createTab);
    on<UpdateAppTab>(_updateTab);
    on<DeleteAppTab>(_deleteTab);
    on<CreatePost>(_createPost);
    on<UpdatePost>(_updatePost);
    on<DeletePost>(_deletePost);
    on<FetchPostsByTabTypeEvent>(_fetchPostsByTabType);
    on<SelectTabEvent>(
        (final SelectTabEvent event, final Emitter<ExploreState> emit) {
      emit(state.copyWith(selectedTabId: event.tabId));
    });
    on<TogglePostComposer>(
        (final TogglePostComposer event, final Emitter<ExploreState> emit) {
      emit(state.copyWith(isComposerVisible: event.isSelected));
    });
    on<SelectImageEvent>(
        (final SelectImageEvent event, final Emitter<ExploreState> emit) {
      emit(state.copyWith(selectedImageFile: event.imageFile));
    });

    on<UnselectImageEvent>(
        (final UnselectImageEvent event, final Emitter<ExploreState> emit) {
      emit(state.copyWith(selectedImageFileIsNull: true));
    });
  }

  final PostRepository _postRepository;

  static const Uuid _uuid = Uuid();

  static final List<AppTab> tabs = <AppTab>[
    AppTab(id: _uuid.v4(), title: 'All', isVisible: true, order: 0),
    AppTab(id: _uuid.v4(), title: 'Following', isVisible: true, order: 1),
    AppTab(id: _uuid.v4(), title: 'For You', isVisible: true, order: 2),
  ];

  Future<void> _init(
    final ExploreInitEvent event,
    final Emitter<ExploreState> emit,
  ) async {
    final String allTabId =
        tabs.firstWhere((final AppTab tab) => tab.title == 'All').id;

    final Map<String, List<PostWithUser>> postsByTabId =
        <String, List<PostWithUser>>{
      for (final AppTab tab in tabs) tab.id: <PostWithUser>[],
    };

    emit(
      ExploreState(
        tabs: tabs,
        postsByTabId: postsByTabId,
        selectedTabId: allTabId,
        status: ExploreStatus.success,
      ),
    );

    try {
      emit(state.copyWith(status: ExploreStatus.loading));
      final List<PostWithUser> fetchedPosts =
          await _postRepository.getPaginatedPosts();

      postsByTabId[allTabId] = fetchedPosts;

      final List<AppTab> updatedTabs =
          _updateTabs(ExploreBloc.tabs, fetchedPosts);
      tabs
        ..clear()
        ..addAll(updatedTabs);

      _groupPostByTabIds(fetchedPosts, postsByTabId);

      emit(
        ExploreState(
          tabs: tabs,
          postsByTabId: postsByTabId,
          selectedTabId: allTabId,
          status: fetchedPosts.isEmpty
              ? ExploreStatus.empty
              : ExploreStatus.success,
        ),
      );
    } catch (e) {
      debugPrint('Failed to load posts: $e');

      emit(
        ExploreState(
          tabs: tabs,
          postsByTabId: postsByTabId,
          selectedTabId: allTabId,
          status: ExploreStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _groupPostByTabIds(
    final List<PostWithUser> fetchedPosts,
    final Map<String, List<PostWithUser>> postsByTabId,
  ) {
    final Map<String, List<PostWithUser>> grouped =
        <String, List<PostWithUser>>{};

    for (final PostWithUser post in fetchedPosts) {
      final String tabType = post.post.appTabType;
      grouped.putIfAbsent(tabType, () => <PostWithUser>[]).add(post);
    }

    for (final AppTab tab in tabs) {
      if (tab.title == 'All') {
        postsByTabId[tab.id] = fetchedPosts;
      } else if (grouped.containsKey(tab.title)) {
        postsByTabId[tab.id] = grouped[tab.title]!;
      }
    }
  }

  List<AppTab> _updateTabs(
    final List<AppTab> currentTabs,
    final List<PostWithUser> fetchedPosts,
  ) {
    const List<String> fixedTitles = <String>['All', 'Following', 'For You'];

    final List<AppTab> fixedTabs = fixedTitles
        .map(
          (final String title) => currentTabs.firstWhere(
            (final AppTab tab) => tab.title == title,
            orElse: () => AppTab(
              id: const Uuid().v4(),
              title: title,
              isVisible: true,
              order: fixedTitles.indexOf(title),
            ),
          ),
        )
        .toList();

    final Set<String> existingTitles =
        fixedTabs.map((final AppTab tab) => tab.title).toSet();

    final List<AppTab> otherTabs = currentTabs
        .where((final AppTab tab) => !fixedTitles.contains(tab.title))
        .toList();

    for (final AppTab tab in otherTabs) {
      existingTitles.add(tab.title);
    }

    int startingOrder = fixedTabs.length + otherTabs.length;

    final List<AppTab> newTabs = <AppTab>[];

    for (final PostWithUser postWithUser in fetchedPosts) {
      final String appTabType = postWithUser.post.appTabType;
      final String appTabId = postWithUser.post.appTabId;

      if (!existingTitles.contains(appTabType)) {
        newTabs.add(
          AppTab(
            id: appTabId,
            title: appTabType,
            isVisible: true,
            order: startingOrder++,
          ),
        );
        existingTitles.add(appTabType);
      }
    }

    return <AppTab>[
      ...fixedTabs,
      ...otherTabs,
      ...newTabs,
    ];
  }

  void _createTab(final CreateAppTab event, final Emitter<ExploreState> emit) {
    final List<AppTab> updatedTabs = <AppTab>[...state.tabs, event.tab];
    final Map<String, List<PostWithUser>> updatedPosts =
        Map<String, List<PostWithUser>>.from(state.postsByTabId)
          ..putIfAbsent(event.tab.id, () => <PostWithUser>[]);

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

    final Map<String, List<PostWithUser>> updatedPosts =
        Map<String, List<PostWithUser>>.from(state.postsByTabId)
          ..remove(event.tabId);

    emit(state.copyWith(tabs: updatedTabs, postsByTabId: updatedPosts));
  }

  Future<void> _createPost(
    final CreatePost event,
    final Emitter<ExploreState> emit,
  ) async {
    final List<PostWithUser> posts = List<PostWithUser>.from(
      state.postsByTabId[event.tabId] ?? <PostWithUser>[],
    )..add(event.postWithUser);

    final Map<String, List<PostWithUser>> updatedPosts =
        Map<String, List<PostWithUser>>.from(state.postsByTabId)
          ..[event.tabId] = posts;

    emit(state.copyWith(postsByTabId: updatedPosts));

    try {
      String? imageUrl;
      if (state.selectedImageFile != null) {
        imageUrl = await _postRepository.uploadImageToFirebase(
          state.selectedImageFile!,
          event.postWithUser.user.id,
        );
        emit(state.copyWith(selectedImageFileIsNull: true));
      }

      await _postRepository.createPost(
        event.postWithUser.post.copyWith(imageUrl: imageUrl),
      );
      add(FetchPostsByTabTypeEvent(event.postWithUser.post.appTabType));
    } catch (e) {
      debugPrint('Failed to create post in Firestore: $e');
    }
  }

  void _updatePost(final UpdatePost event, final Emitter<ExploreState> emit) {
    final List<PostWithUser> posts =
        (state.postsByTabId[event.tabId] ?? <PostWithUser>[])
            .map(
              (final PostWithUser pwu) =>
                  pwu.post.id == event.postWithUser.post.id
                      ? event.postWithUser
                      : pwu,
            )
            .toList();

    final Map<String, List<PostWithUser>> updatedPosts =
        Map<String, List<PostWithUser>>.from(state.postsByTabId)
          ..[event.tabId] = posts;

    emit(state.copyWith(postsByTabId: updatedPosts));
  }

  Future<void> _deletePost(
    final DeletePost event,
    final Emitter<ExploreState> emit,
  ) async {
    try {
      await _postRepository.deletePost(event.postId);
      if (event.imageUrl != null) {
        await _postRepository.deleteImageFromFirebase(
          imageUrl: event.imageUrl ?? '',
        );
      }

      final List<PostWithUser> posts =
          (state.postsByTabId[event.tabId] ?? <PostWithUser>[])
              .where((final PostWithUser pwu) => pwu.post.id != event.postId)
              .toList();

      final Map<String, List<PostWithUser>> updatedPosts =
          Map<String, List<PostWithUser>>.from(state.postsByTabId)
            ..[event.tabId] = posts;

      emit(state.copyWith(postsByTabId: updatedPosts));
    } catch (e, stack) {
      debugPrint('Error deleting post: $e\n$stack');
    }
  }

  Future<void> _fetchPostsByTabType(
    final FetchPostsByTabTypeEvent event,
    final Emitter<ExploreState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ExploreStatus.loading));

      final List<PostWithUser> fetchedPosts =
          await _postRepository.getPaginatedPostsByAppBarType(
        appTabType: event.appTabType,
      );

      if (fetchedPosts.isEmpty) {
        emit(state.copyWith(status: ExploreStatus.empty));
        return;
      }

      final Map<String, List<PostWithUser>> updatedPostsByTabId =
          Map<String, List<PostWithUser>>.from(state.postsByTabId);

      if (state.selectedTabId != null) {
        final List<PostWithUser> selectedTabPosts = fetchedPosts
            .where(
              (final PostWithUser post) =>
                  post.post.appTabId == state.selectedTabId,
            )
            .toList();

        updatedPostsByTabId[state.selectedTabId!] = selectedTabPosts;
      }

      final List<AppTab> updatedTabs = _updateTabs(state.tabs, fetchedPosts);
      final List<AppTab> finalTabs = _ensureAllTabExists(updatedTabs);

      final AppTab allTab =
          finalTabs.firstWhere((final AppTab tab) => tab.title == 'All');

      updatedPostsByTabId[allTab.id] = _mergePosts(
        existing: updatedPostsByTabId[allTab.id],
        incoming: fetchedPosts,
      );

      emit(
        state.copyWith(
          status: ExploreStatus.success,
          postsByTabId: updatedPostsByTabId,
          tabs: finalTabs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExploreStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  List<PostWithUser> _mergePosts({
    required final List<PostWithUser>? existing,
    required final List<PostWithUser> incoming,
  }) {
    final List<PostWithUser> existingPosts = existing ?? <PostWithUser>[];

    final Set<String> existingIds =
        existingPosts.map((final PostWithUser p) => p.post.id).toSet();

    final List<PostWithUser> newPosts = incoming
        .where((final PostWithUser p) => !existingIds.contains(p.post.id))
        .toList();

    return <PostWithUser>[...existingPosts, ...newPosts];
  }

  List<AppTab> _ensureAllTabExists(final List<AppTab> tabs) {
    final bool allTabExists =
        tabs.any((final AppTab tab) => tab.title == 'All');

    if (allTabExists) {
      return tabs;
    }

    final AppTab allTab = AppTab(
      id: const Uuid().v4(),
      title: 'All',
      isVisible: true,
      order: 0,
    );

    final List<AppTab> adjustedTabs = tabs
        .map((final AppTab tab) => tab.copyWith(order: tab.order + 1))
        .toList();

    return <AppTab>[allTab, ...adjustedTabs];
  }
}
