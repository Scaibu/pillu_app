import 'package:pillu_app/core/library/pillu_lib.dart';

Future<void> createPage(final BuildContext context, final Widget widget) async {
  await Navigator.of(context).push(
    PageRouteBuilder<dynamic>(
      pageBuilder: (
        final BuildContext context,
        final Animation<double> animation,
        final Animation<double> secondaryAnimation,
      ) =>
          widget,
      transitionsBuilder: (
        final BuildContext context,
        final Animation<double> animation,
        final Animation<double> secondaryAnimation,
        final Widget child,
      ) {
        final Animation<Offset> slideAnimation = Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        final Animation<double> fadeAnimation = animation;

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    ),
  );
}
