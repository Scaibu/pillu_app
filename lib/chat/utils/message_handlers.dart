import 'dart:io';
import 'dart:ui' as ui show Image;

import 'package:http/http.dart' as http;
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

Future<void> handleMessageTap(
  final BuildContext _,
  final types.Message message, {
  required final String roomId,
}) async {
  if (message is types.FileMessage) {
    String localPath = message.uri;

    if (message.uri.startsWith('http')) {
      try {
        final types.Message updatedMessage = message.copyWith(isLoading: true);
        FirebaseChatCore.instance.updateMessage(updatedMessage, roomId);

        final http.Client client = http.Client();
        final http.Response request = await client.get(Uri.parse(message.uri));
        final Uint8List bytes = request.bodyBytes;
        final String documentsDir =
            (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final File file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      } finally {
        final types.Message updatedMessage = message.copyWith(isLoading: false);
        FirebaseChatCore.instance.updateMessage(
          updatedMessage,
          roomId,
        );
      }
    }

    await OpenFilex.open(localPath);
  }
}

String convertUrl(final String url) =>
    url.replaceFirst('chat_images/', 'chat_images//');

void sendMessage(final dynamic message, final String roomId) {
  if (kDebugMode) {
    FirebaseChatCore.instance.sendMessage(
      message,
      roomId,
    );
  }
}

Future<void> handleFileSelection({
  required final String roomId,
}) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null && result.files.single.path != null) {
    final String name = result.files.single.name;
    final String filePath = result.files.single.path!;
    final File file = File(filePath);

    try {
      await Supabase.instance.client.storage
          .from('chat_images')
          .upload(name, file);

      final String fileUrl = Supabase.instance.client.storage
          .from('chat_images')
          .getPublicUrl(name); // ✅ Use name instead of response

      final types.PartialFile message = types.PartialFile(
        mimeType: lookupMimeType(filePath),
        name: name,
        size: result.files.single.size,
        uri: convertUrl(fileUrl),
      );

      sendMessage(message, roomId);
    } catch (e) {
      if (kDebugMode) {
        print('File upload failed: $e');
      }
    }
  }
}

Future<void> handleImageSelection(final String roomId) async {
  final XFile? result = await ImagePicker().pickImage(
    imageQuality: 70,
    maxWidth: 1440,
    source: ImageSource.gallery,
  );

  if (result != null) {
    final File file = File(result.path);
    final int size = file.lengthSync();
    final Uint8List bytes = await result.readAsBytes();
    final ui.Image image = await decodeImageFromList(bytes);
    final String name = result.name;

    try {
      await Supabase.instance.client.storage
          .from('chat_images')
          .upload(name, file);

      final String imageUrl = Supabase.instance.client.storage
          .from('chat_images')
          .getPublicUrl(name);

      final types.PartialImage message = types.PartialImage(
        height: image.height.toDouble(),
        width: image.width.toDouble(),
        name: name,
        size: size,
        uri: convertUrl(imageUrl),
      );

      sendMessage(message, roomId); // No type casting needed ✅
    } catch (e) {
      if (kDebugMode) {
        print('Image upload failed: $e');
      }
    }
  }
}

void handlePreviewDataFetched({
  required final types.TextMessage message,
  required final types.PreviewData previewData,
  required final String roomId,
}) {
  final types.Message updatedMessage =
      message.copyWith(previewData: previewData);

  FirebaseChatCore.instance.updateMessage(updatedMessage, roomId);
}

void sendMessageTap(
  final types.PartialText message, {
  required final String roomId,
}) {
  FirebaseChatCore.instance.sendMessage(message, roomId);
}
