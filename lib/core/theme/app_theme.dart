import 'package:flutter/material.dart';
import 'package:pillu_app/config/app_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primaryColor: AppConfig.primary,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppConfig.background,
        cardColor: AppConfig.card,
        textTheme: _textTheme,
        inputDecorationTheme: _inputDecorationTheme,
      );

  static final TextTheme _textTheme = TextTheme(
    bodyLarge: TextStyle(
      color: AppConfig.textPrimary,
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppConfig.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: buildJostTextStyle(color: AppConfig.hint),
    labelStyle: buildJostTextStyle(
      color: AppConfig.label,
      fontWeight: FontWeight.w900,
    ),
  );
}

class ThemeWrapper extends StatelessWidget {
  const ThemeWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(final BuildContext context) =>
      Theme.of(context) == AppTheme.lightTheme
          ? child
          : Theme(data: AppTheme.lightTheme, child: child);
}
