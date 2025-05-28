import 'package:flutter/material.dart';
import 'package:pillu_app/chat/utils/message_handlers.dart';
import 'package:pillu_app/shared/text_styles.dart';

Future<void> attachmentSheet(
  final BuildContext context, {
  required final String roomID,
}) async =>
    showModalBottomSheet<void>(
      context: context,
      builder: (final BuildContext context) => SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 180,
          ),
          padding: const EdgeInsets.only(left: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await handleImageSelection(roomID);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Photo',
                      style: buildJostTextStyle(),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Theme.of(context).dividerColor,
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await handleFileSelection(roomId: roomID);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File', style: buildJostTextStyle()),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 0.5,
                  color: Theme.of(context).dividerColor,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cancel',
                      style: buildJostTextStyle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

void toast(
  final BuildContext context, {
  required final String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: buildJostTextStyle(color: Theme.of(context).cardColor),
      ),
    ),
  );
}
