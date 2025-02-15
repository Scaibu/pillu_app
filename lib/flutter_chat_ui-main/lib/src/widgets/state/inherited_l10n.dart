import 'package:flutter/widgets.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/chat_l10n.dart';

/// Used to make provided [ChatL10n] class available through the whole package.
class InheritedL10n extends InheritedWidget {
  /// Creates [InheritedWidget] from a provided [ChatL10n] class.
  const InheritedL10n({
    required this.l10n,
    required super.child,
    super.key,
  });

  static InheritedL10n of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedL10n>()!;

  /// Represents localized copy.
  final ChatL10n l10n;

  @override
  bool updateShouldNotify(final InheritedL10n oldWidget) =>
      l10n.hashCode != oldWidget.l10n.hashCode;
}
