import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(final BuildContext context) => SafeArea(
        child: Theme(
          data: AppTheme.lightTheme,
          child: CustomBlocBuilder<PilluAuthBloc>(
            create: (final BuildContext context) =>
                PilluAuthBloc(PilluAuthRepository()),
            init: (final PilluAuthBloc bloc) {
              bloc.add(AuthAuthenticated());
            },
            builder: (final BuildContext context, final PilluAuthBloc state) =>
                ThemeWrapper(
              child: Scaffold(
                appBar: buildAppBar(context),
                resizeToAvoidBottomInset: true,
                drawer: const AppDrawerData(),
                body: const AppBody(),
              ),
            ),
          ),
        ),
      );
}
