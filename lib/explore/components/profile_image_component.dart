import 'package:cached_network_image/cached_network_image.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class ProfileImageComponent extends StatelessWidget {
  const ProfileImageComponent({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<PilluAuthBloc, AuthLocalState, User?>(
        selector: (final AuthLocalState state) => (state as AuthDataState).user,
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
                return const CircleAvatar(
                  backgroundColor: Colors.white,
                  maxRadius: 20,
                  child: Icon(Icons.person, size: 40),
                );
              }

              final types.User? data = snapshot.data;

              if (data?.imageUrl == null) {
                return const CircleAvatar(
                  backgroundColor: Colors.white,
                  maxRadius: 20,
                  child: Icon(Icons.person, size: 40),
                );
              }

              return CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: CachedNetworkImage(
                    imageUrl: data?.imageUrl ?? '',
                    height: 40,
                    width: 40,
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
          );
        },
      );
}
