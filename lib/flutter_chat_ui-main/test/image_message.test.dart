import 'package:flutter/material.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/flutter_chat_types.dart' as types;
import 'package:flutter_test/flutter_test.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/flutter_chat_ui.dart';

void main() {
  testWidgets('contains image message', (WidgetTester tester) async {
    // Build the Chat widget.
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Chat(
            messages: const [
              types.ImageMessage(
                author: types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c'),
                height: 1080,
                id: 'id',
                name: 'image',
                size: 100,
                uri: 'image',
                width: 1920,
              ),
            ],
            onSendPressed: (types.PartialText message) => {},
            user: const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c'),
          ),
        ),
      ),
    );

    // Trigger a frame.
    await tester.pump();

    // Expect to find one ImageMessage.
    expect(find.byType(ImageMessage), findsOneWidget);
  });
}
