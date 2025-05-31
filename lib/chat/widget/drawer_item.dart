import 'package:pillu_app/core/library/pillu_lib.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        // Slightly larger radius for smoothness
        splashColor: theme.colorScheme.primary.withOpacity(0.2),
        // Subtle splash
        highlightColor: theme.colorScheme.primary.withOpacity(0.1),
        // Light highlight on tap
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          // Bigger touch area
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                // Larger padding for icon touch target
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20), // Increased spacing for clarity
              Expanded(
                child: Text(
                  title,
                  style: buildJostTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 21,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
