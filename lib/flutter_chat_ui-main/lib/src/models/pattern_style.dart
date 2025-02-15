import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PatternStyle {
  PatternStyle(this.from, this.regExp, this.replace, this.textStyle);

  final Pattern from;
  final RegExp regExp;
  final String replace;
  final TextStyle textStyle;

  String get pattern => regExp.pattern;

  static Future<PatternStyle> get bold async => PatternStyle(
        '*',
        RegExp(r'\*[^\*]+\*'),
        '',
        const TextStyle(fontWeight: FontWeight.bold),
      );

  static PatternStyle get code => PatternStyle(
        '`',
        RegExp('`[^`]+`'),
        '',
        TextStyle(
          fontFamily: defaultTargetPlatform == TargetPlatform.iOS
              ? 'Courier'
              : 'monospace',
        ),
      );

  static PatternStyle get italic => PatternStyle(
        '_',
        RegExp('_[^_]+_'),
        '',
        const TextStyle(fontStyle: FontStyle.italic),
      );

  static Future<PatternStyle> get lineThrough async => PatternStyle(
        '~',
        RegExp('~[^~]+~'),
        '',
        const TextStyle(decoration: TextDecoration.lineThrough),
      );
}
