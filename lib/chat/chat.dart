import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({required this.room, super.key});

  final types.Room room;

  String get roomID => room.id;

  Future<void> _handleAttachmentPressed(final BuildContext context) async {
    await attachmentSheet(context, roomID: roomID);
  }

  @override
  Widget build(final BuildContext context) => ThemeWrapper(
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Text('Chat', style: buildJostTextStyle()),
            centerTitle: true,
          ),
          body: StreamBuilder<types.Room>(
            initialData: room,
            stream: FirebaseChatCore.instance.room(roomID),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<types.Room> snapshot,
            ) =>
                StreamBuilder<List<types.Message>>(
              initialData: const <types.Message>[],
              stream: FirebaseChatCore.instance.messages(snapshot.data!),
              builder: (
                final BuildContext context,
                final AsyncSnapshot<List<types.Message>> snapshot,
              ) =>
                  Chat(
                isAttachmentUploading: false,
                messages: snapshot.data ?? <types.Message>[],
                theme: buildChatTheme(context),
                onAttachmentPressed: () async {
                  await _handleAttachmentPressed(context);
                },
                onMessageTap: (
                  final BuildContext context,
                  final types.Message p1,
                ) async {
                  await handleMessageTap(context, p1, roomId: roomID);
                },
                onPreviewDataFetched: (
                  final types.TextMessage p0,
                  final types.PreviewData p1,
                ) {
                  handlePreviewDataFetched(
                    message: p0,
                    previewData: p1,
                    roomId: roomID,
                  );
                },
                onSendPressed: (final types.PartialText message) {
                  sendMessageTap(message, roomId: roomID);
                },
                user: types.User(
                  id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                ),
              ),
            ),
          ),
        ),
      );
}
