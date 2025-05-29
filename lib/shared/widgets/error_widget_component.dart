import 'package:pillu_app/core/library/pillu_lib.dart';

class ErrorWidgetComponent extends StatelessWidget {
  const ErrorWidgetComponent({super.key});

  @override
  Widget build(final BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 250),
            const Icon(Icons.error_outline, size: 100),
            const SizedBox(height: 16),
            Text(
              'Code sequence \nis corrupted',
              style: buildJostTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 32,
                ),
                backgroundColor: Theme.of(context).primaryColor.withAlpha(10),
                // Subtle background color
              ),
              child: Text(
                'Start Over',
                style: buildJostTextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}
