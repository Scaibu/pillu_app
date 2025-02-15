import 'package:flutter/material.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/pattern_style.dart';

/// To highlighting the matches for pattern.
class InputTextFieldController extends TextEditingController {
  /// A map of style to apply to the text pattern.
  final List<PatternStyle> _listPatternStyle = <PatternStyle>[
    PatternStyle.bold,
    PatternStyle.italic,
    PatternStyle.lineThrough,
    PatternStyle.code,
  ];

  @override
  TextSpan buildTextSpan({
    required final BuildContext context,
    required final bool withComposing,
    final TextStyle? style,
  }) {
    final List<TextSpan> children = <TextSpan>[];

    text.splitMapJoin(
      RegExp(
        _listPatternStyle
            .map((final PatternStyle it) => it.regExp.pattern)
            .join('|'),
      ),
      onMatch: (final Match match) {
        final String text = match[0]!;
        final TextStyle style = _listPatternStyle
            .firstWhere(
              (final PatternStyle element) => element.regExp.hasMatch(text),
            )
            .textStyle;

        final TextSpan span = TextSpan(text: match.group(0), style: style);
        children.add(span);
        return span.toPlainText();
      },
      onNonMatch: (final String text) {
        final TextSpan span = TextSpan(text: text, style: style);
        children.add(span);
        return span.toPlainText();
      },
    );

    return TextSpan(style: style, children: children);
  }
}
