import 'package:pillu_app/auth/auth_repository.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/core/theme/app_theme.dart';
import 'package:pillu_app/shared/widgets/app_bars.dart';
import 'package:pillu_app/shared/widgets/app_body.dart';
import 'package:pillu_app/shared/widgets/app_drawer_data.dart';

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
