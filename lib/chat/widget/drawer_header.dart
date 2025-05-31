import 'package:cached_network_image/cached_network_image.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<PilluAuthBloc, AuthDataState, User?>(
        selector: (final AuthDataState state) => state.user,
        builder: (final BuildContext context, final User? state) {
          if (state == null) {
            return const Offstage();
          }

          return StreamBuilder<types.User?>(
            stream: FirebaseChatCore.instance
                .currentUser()
                .map((final types.User? user) => user),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<types.User?> snapshot,
            ) {
              if (!snapshot.hasData || snapshot.hasError) {
                return Container(
                  height: 329,
                  color: Theme.of(context).primaryColor,
                );
              }

              final types.User? data = snapshot.data;

              return Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: 70,
                      child: (data?.imageUrl != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                imageUrl: data?.imageUrl ?? '',
                                fit: BoxFit.contain,
                                placeholder: (
                                  final BuildContext context,
                                  final String url,
                                ) =>
                                    const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  maxRadius: 70,
                                  child: Icon(Icons.person, size: 40),
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: 70,
                              child: Icon(Icons.person, size: 40),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${data?.firstName ?? ''} ${data?.lastName ?? ''}',
                          style: buildJostTextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          state.email ?? '',
                          style: buildJostTextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
}
