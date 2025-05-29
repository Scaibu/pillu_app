import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/bloc/explore_bloc.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/components/profile_image_component.dart';
import 'package:pillu_app/explore/model/appTab/app_tab.dart';
import 'package:pillu_app/explore/model/post/post.dart';
import 'package:uuid/uuid.dart';

class PostComposer extends HookWidget {
  const PostComposer({super.key});

  void _createPost(
    final BuildContext context,
    final TextEditingController controller,
    final ExploreState state,
  ) {
    if(controller.text.isEmpty){
      context.read<ExploreBloc>().add(TogglePostComposer(isSelected: false));
      return;
    }

    final AuthLocalState userState = context.read<PilluAuthBloc>().state;
    if (userState is AuthDataState) {
      context.read<ExploreBloc>().add(
            CreatePost(
              post: Post(
                id: const Uuid().v4(),
                authorId: userState.user?.uid ?? '',
                type: PostType.text,
                createdAt: DateTime.now(),
                text: controller.text,
              ),
              tabId: state.selectedTabId ?? '',
            ),
          );

      controller.clear();
      context.read<ExploreBloc>().add(TogglePostComposer(isSelected: false));
    }
  }

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
                    _icon(context, Icons.image),
                    _icon(context, Icons.poll),
                    _icon(context, Icons.emoji_emotions_outlined),
                    _icon(context, Icons.schedule),
                    _icon(context, Icons.location_on),
                  ],
                ),
              ),
            ],
          ),
          LuxuryTextField(
            controller: controller,
            focusNode: focusNode,
            labelText: '',
            hintText: "What's happening?",
            maxLines: 3,
            hidePrefixIcon: true,
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
                  builder:
                      (final BuildContext context, final ExploreState state) =>
                          IconButton(
                    onPressed: () {
                      _createPost(context, controller, state);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            onFieldSubmitted: (final _) {},
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ],
      ),
    );
  }
}
