import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/bloc/explore_bloc.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/components/profile_image_component.dart';
import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/post/post.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';
import 'package:uuid/uuid.dart';

class PostComposer extends HookWidget {
  const PostComposer({super.key});

  Future<void> _createPost(
    final BuildContext context,
    final TextEditingController controller,
    final ExploreState state,
  ) async {
    if (controller.text.isEmpty) {
      context.read<ExploreBloc>().add(TogglePostComposer(isSelected: false));
      return;
    }

    final AuthDataState userState = context.read<PilluAuthBloc>().state;
    final types.User? user = await FirebaseChatCore.instance.user();

    if (context.mounted) {
      context.read<ExploreBloc>().add(
            CreatePost(
              postWithUser: PostWithUser(
                post: Post(
                  id: const Uuid().v4(),
                  authorId: user?.id ?? userState.user?.uid ?? '',
                  type: PostType.text,
                  createdAt: DateTime.now(),
                  text: controller.text,
                  appTabId: state.selectedTabId ?? '',
                  appTabType: _appTabType(state),
                ),
                user: user ??
                    types.User(
                      id: user?.id ?? userState.user?.uid ?? '',
                      firstName: user?.firstName,
                      lastName: user?.lastName,
                      imageUrl: user?.imageUrl,
                    ),
              ),
              tabId: state.selectedTabId ?? '',
            ),
          );
    }

    controller.clear();
    if (context.mounted) {
      context.read<ExploreBloc>().add(TogglePostComposer(isSelected: false));
    }
  }

  String _appTabType(final ExploreState state) => ExploreBloc.tabs
      .firstWhere(
        (final AppTab element) => element.id == state.selectedTabId,
      )
      .title;

  Widget _icon(final BuildContext context, final IconData icon) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
      );

  @override
  Widget build(final BuildContext context) {
    final TextEditingController controller = useTextEditingController();
    final FocusNode focusNode = useFocusNode();

    context.read<ExploreBloc>();
    final ValueNotifier<bool> hasText = useState(false);

    useEffect(
      () {
        focusNode.requestFocus();
        controller.addListener(() {
          hasText.value = controller.text.trim().isNotEmpty;
        });
        return null;
      },
      <Object?>[],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        color: Theme.of(context).canvasColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const ProfileImageComponent(),
              const SizedBox(width: 8),
              BlocBuilder<ExploreBloc, ExploreState>(
                builder:
                    (final BuildContext context, final ExploreState state) =>
                        Center(
                  child: DropdownButton<String>(
                    value: state.selectedTabId,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    style: buildJostTextStyle(color: Colors.white70),
                    items: state.tabs
                        .map(
                          (final AppTab tab) => DropdownMenuItem<String>(
                            value: tab.id,
                            child: Text(
                              tab.title,
                              textAlign: TextAlign.center,
                              style: buildJostTextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (final String? newTabId) {
                      if (newTabId != null) {
                        context
                            .read<ExploreBloc>()
                            .add(SelectTabEvent(newTabId));
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        await _saveTempImage(context);
                      },
                      child: _icon(context, Icons.image),
                    ),
                    _icon(context, Icons.poll),
                    _icon(context, Icons.emoji_emotions_outlined),
                    _icon(context, Icons.schedule),
                    _icon(context, Icons.location_on),
                  ],
                ),
              ),
            ],
          ),
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (final BuildContext context, final ExploreState state) {
              final Widget widget;
              final bool hidePrefixIcon;

              if (state.selectedImageFile != null) {
                hidePrefixIcon = false;
                widget = GestureDetector(
                  onTap: () {
                    context.read<ExploreBloc>().add(UnselectImageEvent());
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            state.selectedImageFile!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                hidePrefixIcon = true;
                widget = const Offstage();
              }

              return LuxuryTextField(
                controller: controller,
                focusNode: focusNode,
                labelText: '',
                hintText: "What's happening?",
                maxLines: 3,
                hidePrefixIcon: hidePrefixIcon,
                suffixIcon: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        if (controller.text.isEmpty) {
                          context
                              .read<ExploreBloc>()
                              .add(TogglePostComposer(isSelected: false));
                        }

                        if (controller.text.isNotEmpty) {
                          controller.clear();
                        }
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    BlocBuilder<ExploreBloc, ExploreState>(
                      builder: (
                        final BuildContext context,
                        final ExploreState state,
                      ) =>
                          IconButton(
                        onPressed: () async {
                          await _createPost(context, controller, state);
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                prefixIcon: widget,
                onFieldSubmitted: (final _) {},
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveTempImage(final BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final File imageFile = File(pickedFile.path);
    context.read<ExploreBloc>().add(SelectImageEvent(imageFile));
  }
}
