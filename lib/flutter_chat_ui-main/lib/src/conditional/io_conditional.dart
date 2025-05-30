import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/conditional/base_conditional.dart';

/// Create a [IOConditional].
///
/// Used from conditional imports, matches the definition in
/// `conditional_stub.dart`.
BaseConditional createConditional() => IOConditional();

/// A conditional for anything but browser.
class IOConditional extends BaseConditional {
  /// Returns [NetworkImage] if URI starts with http
  /// otherwise uses IO to create File.
  @override
  ImageProvider getProvider(
    final String uri, {
    final Map<String, String>? headers,
  }) {
    if (uri.startsWith('http')) {
      return NetworkImage(uri, headers: headers);
    } else {
      return FileImage(File(uri));
    }
  }
}
