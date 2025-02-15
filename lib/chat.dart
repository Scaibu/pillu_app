import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/flutter_chat_ui.dart';
import 'package:pillu_app/core/library/flutter_firebase_chat_core.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({required this.room, super.key});

  final types.Room room;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isAttachmentUploading = false;

  Future<void> _handleAttachmentPressed() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (final BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFileSelection() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final String name = result.files.single.name;
      final String filePath = result.files.single.path!;
      final File file = File(filePath);

      try {
        final Reference reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final String uri = await reference.getDownloadURL();

        final types.PartialFile message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  Future<void> _handleImageSelection() async {
    final XFile? result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final File file = File(result.path);
      final int size = file.lengthSync();
      final Uint8List bytes = await result.readAsBytes();
      final Image image = (await decodeImageFromList(bytes)) as Image;
      final String name = result.name;

      try {
        final Reference reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final String uri = await reference.getDownloadURL();

        final types.PartialImage message = types.PartialImage(
          height: image.height?.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width?.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  Future<void> _handleMessageTap(
    final BuildContext _,
    final types.Message message,
  ) async {
    if (message is types.FileMessage) {
      String localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final types.Message updatedMessage =
              message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );

          final http.Client client = http.Client();
          final http.Response request =
              await client.get(Uri.parse(message.uri));
          final Uint8List bytes = request.bodyBytes;
          final String documentsDir =
              (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final File file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final types.Message updatedMessage =
              message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    final types.TextMessage message,
    final types.PreviewData previewData,
  ) {
    final types.Message updatedMessage =
        message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _handleSendPressed(final types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _setAttachmentUploading(final bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Chat'),
        ),
        body: StreamBuilder<types.Room>(
          initialData: widget.room,
          stream: FirebaseChatCore.instance.room(widget.room.id),
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
              isAttachmentUploading: _isAttachmentUploading,
              messages: snapshot.data ?? <types.Message>[],
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: types.User(
                id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
              ),
            ),
          ),
        ),
      );
}
