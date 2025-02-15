import 'dart:async';

import 'package:diffutil_dart/diffutil.dart';
import 'package:flutter/material.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/bubble_rtl_alignment.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_user.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/typing_indicator.dart';

/// Animated list that handles automatic animations and pagination.
class ChatList extends StatefulWidget {
  /// Creates a chat list widgets.
  const ChatList({
    required this.bubbleRtlAlignment,
    required this.itemBuilder,
    required this.items,
    required this.scrollController,
    required this.useTopSafeAreaInset,
    super.key,
    this.bottomWidget,
    this.isLastPage,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.scrollPhysics,
    this.typingIndicatorOptions,
  });

  /// A custom widgets at the bottom of the list.
  final Widget? bottomWidget;

  /// Used to set alignment of typing indicator.
  /// See [BubbleRtlAlignment].
  final BubbleRtlAlignment bubbleRtlAlignment;

  /// Used for pagination (infinite scroll) together with [onEndReached].
  /// When true, indicates that there are no more pages to load and
  /// pagination will not be triggered.
  final bool? isLastPage;

  /// Item builder.
  final Widget Function(Object, int? index) itemBuilder;

  /// Items to build.
  final List<Object> items;

  /// Used for pagination (infinite scroll). Called when user scrolls
  /// to the very end of the list (minus [onEndReachedThreshold]).
  final Future<void> Function()? onEndReached;

  /// A representation of how a [ScrollView] should dismiss the
  /// on-screen keyboard.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Used for pagination (infinite scroll) together with [onEndReached]. Can be anything from 0 to 1, where 0 is immediate load of the next page as soon as scroll starts, and 1 is load of the next page only if scrolled to the very end of the list. Default value is 0.75, e.g. start loading next page when scrolled through about 3/4 of the available content.
  final double? onEndReachedThreshold;

  /// Scroll controller for the main [CustomScrollView]. Also used
  /// to auto scroll
  /// to specific messages.
  final ScrollController scrollController;

  /// Determines the physics of the scroll view.
  final ScrollPhysics? scrollPhysics;

  /// Used to build typing indicator according to options.
  /// See [TypingIndicatorOptions].
  final TypingIndicatorOptions? typingIndicatorOptions;

  /// Whether to use top safe area inset for the list.
  final bool useTopSafeAreaInset;

  @override
  State<ChatList> createState() => _ChatListState();
}

/// [ChatList] widgets state.
class _ChatListState extends State<ChatList>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _animation = CurvedAnimation(
    curve: Curves.easeOutQuad,
    parent: _controller,
  );
  late final AnimationController _controller = AnimationController(vsync: this);

  bool _indicatorOnScrollStatus = false;
  bool _isNextPageLoading = false;
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  late List<Object> _oldData = List<Object>.from(widget.items);

  @override
  void initState() {
    super.initState();

    didUpdateWidget(widget);
  }

  Future<void> _calculateDiffs(final List<Object> oldList) async {
    final DiffResult<Object> diffResult = calculateListDiff<Object>(
      oldList,
      widget.items,
      equalityChecker: (final Object item1, final Object item2) {
        if (item1 is Map<String, Object> && item2 is Map<String, Object>) {
          final types.Message message1 = item1['message']! as types.Message;
          final types.Message message2 = item2['message']! as types.Message;

          return message1.id == message2.id;
        } else {
          return item1 == item2;
        }
      },
    );

    for (final DiffUpdate update in diffResult.getUpdates(batch: false)) {
      update.when(
        insert: (final int pos, final int count) {
          _listKey.currentState?.insertItem(pos);
        },
        remove: (final int pos, final int count) {
          final Object item = oldList[pos];
          _listKey.currentState?.removeItem(
            pos,
            (final _, final Animation<double> animation) =>
                _removedMessageBuilder(item, animation),
          );
        },
        change: (final int pos, final Object? payload) {},
        move: (final int from, final int to) {},
      );
    }

    _scrollToBottomIfNeeded(oldList);

    _oldData = List<Object>.from(widget.items);
  }

  Widget _newMessageBuilder(
    final int index,
    final Animation<double> animation,
  ) {
    try {
      final Object item = _oldData[index];

      return SizeTransition(
        key: _valueKeyForItem(item),
        axisAlignment: -1,
        sizeFactor: animation.drive(CurveTween(curve: Curves.easeOutQuad)),
        child: widget.itemBuilder(item, index),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _removedMessageBuilder(
    final Object item,
    final Animation<double> animation,
  ) =>
      SizeTransition(
        key: _valueKeyForItem(item),
        axisAlignment: -1,
        sizeFactor: animation.drive(CurveTween(curve: Curves.easeInQuad)),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeInQuad)),
          child: widget.itemBuilder(item, null),
        ),
      );

  // Hacky solution to reconsider.
  void _scrollToBottomIfNeeded(final List<Object> oldList) {
    try {
      // Take index 1 because there is always a spacer on index 0.
      final Object oldItem = oldList[1];
      final Object item = widget.items[1];

      if (oldItem is Map<String, Object> && item is Map<String, Object>) {
        final types.Message oldMessage = oldItem['message']! as types.Message;
        final types.Message message = item['message']! as types.Message;

        // Compare items to fire only on newly added messages.
        if (oldMessage.id != message.id) {
          // Run only for sent message.
          if (message.author.id == InheritedUser.of(context).user.id) {
            // Delay to give some time for Flutter to calculate new
            // size after new message was added.
            Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
              if (widget.scrollController.hasClients) {
                unawaited(
                  widget.scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInQuad,
                  ),
                );
              }
            });
          }
        }
      }
    } catch (e) {
      // Do nothing if there are no items.
    }
  }

  Key? _valueKeyForItem(final Object item) => _mapMessage(
        item,
        (final types.Message message) => ValueKey<dynamic>(message.id),
      );

  T? _mapMessage<T>(
    final Object maybeMessage,
    final T Function(types.Message) f,
  ) {
    if (maybeMessage is Map<String, Object>) {
      return f(maybeMessage['message']! as types.Message);
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant final ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    unawaited(_calculateDiffs(oldWidget.items));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (final ScrollNotification notification) {
          if (notification.metrics.pixels > 10.0 && !_indicatorOnScrollStatus) {
            setState(() {
              _indicatorOnScrollStatus = !_indicatorOnScrollStatus;
            });
          } else if (notification.metrics.pixels == 0.0 &&
              _indicatorOnScrollStatus) {
            setState(() {
              _indicatorOnScrollStatus = !_indicatorOnScrollStatus;
            });
          }

          if (widget.onEndReached == null ||
              (widget.isLastPage ?? false) == true) {
            return false;
          }

          if (notification.metrics.pixels >=
              (notification.metrics.maxScrollExtent *
                  (widget.onEndReachedThreshold ?? 0.75))) {
            if (widget.items.isEmpty || _isNextPageLoading) {
              return false;
            }

            _controller
              ..duration = Duration.zero
              ..forward();

            setState(() {
              _isNextPageLoading = true;
            });

            unawaited(
              widget.onEndReached!().whenComplete(() {
                if (mounted) {
                  _controller
                    ..duration = const Duration(milliseconds: 300)
                    ..reverse();

                  setState(() {
                    _isNextPageLoading = false;
                  });
                }
              }),
            );
          }

          return false;
        },
        child: CustomScrollView(
          controller: widget.scrollController,
          keyboardDismissBehavior: widget.keyboardDismissBehavior,
          physics: widget.scrollPhysics,
          reverse: true,
          slivers: <Widget>[
            if (widget.bottomWidget != null)
              SliverToBoxAdapter(child: widget.bottomWidget),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 4),
              sliver: SliverToBoxAdapter(
                child: (widget.typingIndicatorOptions!.typingUsers.isNotEmpty &&
                        !_indicatorOnScrollStatus)
                    ? (widget.typingIndicatorOptions
                                ?.customTypingIndicatorBuilder !=
                            null
                        ? widget.typingIndicatorOptions!
                            .customTypingIndicatorBuilder!(
                            context: context,
                            bubbleAlignment: widget.bubbleRtlAlignment,
                            options: widget.typingIndicatorOptions!,
                            indicatorOnScrollStatus: _indicatorOnScrollStatus,
                          )
                        : widget.typingIndicatorOptions
                                ?.customTypingIndicator ??
                            TypingIndicator(
                              bubbleAlignment: widget.bubbleRtlAlignment,
                              options: widget.typingIndicatorOptions!,
                              showIndicator: widget.typingIndicatorOptions!
                                      .typingUsers.isNotEmpty &&
                                  !_indicatorOnScrollStatus,
                            ))
                    : const SizedBox.shrink(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 4),
              sliver: SliverAnimatedList(
                findChildIndexCallback: (final Key key) {
                  if (key is ValueKey<Object>) {
                    final int newIndex = widget.items.indexWhere(
                      (final Object v) => _valueKeyForItem(v) == key,
                    );
                    if (newIndex != -1) {
                      return newIndex;
                    }
                  }
                  return null;
                },
                initialItemCount: widget.items.length,
                key: _listKey,
                itemBuilder: (
                  final _,
                  final int index,
                  final Animation<double> animation,
                ) =>
                    _newMessageBuilder(index, animation),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 16 +
                    (widget.useTopSafeAreaInset
                        ? MediaQuery.of(context).padding.top
                        : 0),
              ),
              sliver: SliverToBoxAdapter(
                child: SizeTransition(
                  axisAlignment: 1,
                  sizeFactor: _animation,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 32,
                      width: 32,
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: _isNextPageLoading
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.transparent,
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  InheritedChatTheme.of(context)
                                      .theme
                                      .primaryColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
