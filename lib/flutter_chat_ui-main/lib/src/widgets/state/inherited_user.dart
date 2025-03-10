import 'package:flutter/widgets.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;

/// Used to make provided [types.User] class available through the whole
/// package.
class InheritedUser extends InheritedWidget {
  /// Creates [InheritedWidget] from a provided [types.User] class.
  const InheritedUser({
    required this.user,
    required super.child,
    super.key,
  });

  static InheritedUser of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedUser>()!;

  /// Represents current logged in user. Used to determine message's author.
  final types.User user;

  @override
  bool updateShouldNotify(final InheritedUser oldWidget) =>
      user.id != oldWidget.user.id;
}
