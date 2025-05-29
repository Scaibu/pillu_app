import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/bloc/explore_bloc.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/components/list_of_posts.dart';
import 'package:pillu_app/explore/components/list_of_tabs.dart';
import 'package:pillu_app/explore/components/post_composer.dart';
import 'package:pillu_app/explore/repository/post_repository.dart';
import 'package:pillu_app/shared/widgets/error_widget_component.dart';
import 'package:pillu_app/shared/widgets/loading_widget.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(final BuildContext context) => BlocProvider<ExploreBloc>(
        create: (final BuildContext context) =>
            ExploreBloc(PostRepository())..add(ExploreInitEvent()),
        child: Builder(
          builder: (final BuildContext context) => Builder(
            builder: (final BuildContext context) =>
                CustomBlocBuilder<PilluAuthBloc>(
              create: (final BuildContext context) =>
                  PilluAuthBloc(PilluAuthRepository()),
              builder: (final BuildContext context, final PilluAuthBloc bloc) =>
                  ThemeWrapper(
                child: SafeArea(
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    appBar: buildAppBar(context, title: ''),
                    floatingActionButton:
                        BlocBuilder<ExploreBloc, ExploreState>(
                      builder: (
                        final BuildContext context,
                        final ExploreState state,
                      ) {
                        if (state.isComposerVisible) {
                          return const SizedBox.shrink();
                        }
                        return FloatingActionButton(
                          onPressed: () {
                            context
                                .read<ExploreBloc>()
                                .add(TogglePostComposer(isSelected: true));
                          },
                          shape: const CircleBorder(),
                          child: const Icon(Icons.edit, size: 21),
                        );
                      },
                    ),
                    body: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        SingleChildScrollView(
                          child: BlocSelector<PilluAuthBloc, AuthLocalState,
                              User?>(
                            selector: (final AuthLocalState state) =>
                                (state as AuthDataState).user,
                            builder: (
                              final BuildContext context,
                              final User? state,
                            ) =>
                                StreamBuilder<types.User?>(
                              stream: FirebaseChatCore.instance
                                  .currentUser()
                                  .map((final types.User? user) => user),
                              builder: (
                                final BuildContext context,
                                final AsyncSnapshot<types.User?> snapshot,
                              ) {
                                if (!snapshot.hasData) {
                                  return const LoadingWidget();
                                }

                                if (snapshot.hasError) {
                                  return const ErrorWidgetComponent();
                                }

                                return const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    SizedBox(height: 8),
                                    ListOfTabs(),
                                    ListOfPost(),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        BlocBuilder<ExploreBloc, ExploreState>(
                          builder: (
                            final BuildContext context,
                            final ExploreState state,
                          ) {
                            if (!state.isComposerVisible) {
                              return const SizedBox.shrink();
                            }
                            return const Positioned(
                              bottom: 8,
                              right: 0,
                              left: 0,
                              child: PostComposer(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
