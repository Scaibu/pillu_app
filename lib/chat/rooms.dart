import 'package:pillu_app/core/library/pillu_lib.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(final BuildContext context) => SafeArea(
        child: Theme(
          data: AppTheme.lightTheme,
          child: BlocProvider<AuthBloc>(
            create: (final BuildContext context) =>
                AuthBloc(AuthRepository())..add(AuthAuthenticated()),
            child: Scaffold(
              appBar: buildAppBar(context),
              drawer: const AppDrawerData(),
              body: const AppBody(),
            ),
          ),
        ),
      );
}
