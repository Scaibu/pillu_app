import 'package:pillu_app/core/library/pillu_lib.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(final BuildContext context) => SafeArea(
        child: Theme(
          data: AppTheme.lightTheme,
          child: BlocProvider<PilluAuthBloc>(
            create: (final BuildContext context) =>
                PilluAuthBloc(PilluAuthRepository()),
            child: Scaffold(
              appBar: buildAppBar(context),
              drawer: const AppDrawerData(),
              body: const AppBody(),
            ),
          ),
        ),
      );
}
