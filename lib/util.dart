import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

const List<Color> localColors = <Color>[
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

Color getUserAvatarNameColor(final types.User user) {
  final int index = user.id.hashCode % localColors.length;
  return localColors[index];
}

String getUserName(final types.User user) =>
    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

Future<void> alertDialog(
  final BuildContext context,
  final String message,
) async {
  final ThemeData theme = Theme.of(context);
  const double fontSize = 14;

  await showDialog<dynamic>(
    context: context,
    builder: (final BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: theme.colorScheme.surface,
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.only(bottom: 12, right: 16),

      // 🟥 Title Section
      title: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Oops! Something went wrong',
              style: buildJostTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),

      // 🟦 Message Section
      content: Text(
        message,
        style: buildJostTextStyle(
          fontSize: fontSize * 0.9,
          color: theme.textTheme.bodyMedium?.color,
        ),
        textAlign: TextAlign.left,
      ),

      // 🟩 Action Button
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: buildJostTextStyle(fontSize: fontSize * 0.85),
          ),
          onPressed: () async {
            await HapticFeedback.mediumImpact();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            'OK',
            style: buildJostTextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<String?> showMessageBox({
  required final BuildContext context,
  required final String title,
  required final String hint,
}) async {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ThemeData theme = Theme.of(context);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (final BuildContext context) => MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Center(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
                minWidth: 320,
              ),
              child: AlertDialog(
                backgroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                titlePadding:
                    const EdgeInsets.only(top: 24, left: 24, right: 24),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                actionsPadding:
                    const EdgeInsets.only(bottom: 16, right: 16, left: 16),

                // Title
                title: Text(
                  title,
                  style: buildJostTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                // Form wrapping the input
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Add a short, friendly message.'
                        ' Let them know why you want to connect!',
                        style: buildJostTextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LuxuryTextField(
                        controller: controller,
                        focusNode: focusNode,
                        labelText: hint,
                        hintText: 'Hey, I’d love to connect!',
                        textInputAction: TextInputAction.done,
                        maxLines: 3,

                        // Add validator for non-empty check
                        validator: (final String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Message cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Actions
                actions: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // cancel
                          },
                          child: Text(
                            'Cancel',
                            style: buildJostTextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Validate form before sending
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.of(context).pop(controller.text.trim());
                            }
                          },
                          child: Text(
                            'Send Request',
                            style: buildJostTextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
