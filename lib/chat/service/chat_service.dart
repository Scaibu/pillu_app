import 'package:pillu_app/core/library/pillu_lib.dart';

class ChatService {
  ChatService({required this.pilluUser});

  final PilluUserModel pilluUser;

  String get _welcomeMessage =>
      'Welcome back, ${pilluUser.firstName} ${pilluUser.lastName}!';

  PilluAuthBloc pilluBlocOf(final BuildContext context) =>
      context.read<PilluAuthBloc>();

  Future<void> createChatUser(final BuildContext context) async {
    try {
      await pilluBlocOf(context).createChatUser(authApi, pilluUser: pilluUser);
      if (context.mounted) {
        toast(context, message: _welcomeMessage);
      }
    } catch (e) {
      if (context.mounted) {
        pilluBlocOf(context).add(UserLogOutEvent());
      }
    }
  }
}
