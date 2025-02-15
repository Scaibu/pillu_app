import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle buildJostTextStyle({
  final FontWeight? fontWeight,
  final double? fontSize,
  final Color? color,
}) =>
    GoogleFonts.jost(
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? Colors.black87,
    );
