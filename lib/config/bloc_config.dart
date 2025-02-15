import 'package:pillu_app/core/library/pillu_lib.dart';

///
class CustomBlocProvider<T extends BlocBase<Object?>> extends InheritedWidget {
  CustomBlocProvider({
    required super.child,
    required final T Function() create,
    super.key,
  }) : bloc = create();

  final T bloc;

  static T of<T extends BlocBase<Object?>>(final BuildContext context) {
    final CustomBlocProvider<T>? provider =
        context.dependOnInheritedWidgetOfExactType<CustomBlocProvider<T>>();
    if (provider == null) {
      throw Exception('BlocProvider<$T> not found in widgets tree');
    }
    return provider.bloc;
  }

  @override
  bool updateShouldNotify(final CustomBlocProvider<T> oldWidget) => false;
}

class CustomBlocBuilder<T extends BlocBase<Object?>> extends StatelessWidget {
  const CustomBlocBuilder({
    required this.builder,
    required this.create,
    this.init,
    super.key,
  });

  final T Function(BuildContext context) create;
  final Widget Function(BuildContext context, T bloc) builder;
  final void Function(T bloc)? init;

  @override
  Widget build(final BuildContext context) {
    try {
      final T bloc = CustomBlocProvider.of<T>(context);
      return builder(context, bloc);
    } catch (e) {
      return BlocProvider<T>(
        create: (final BuildContext context) {
          final T bloc = create(context);
          init?.call(bloc);
          return bloc;
        },
        child: Builder(
          builder: (final BuildContext context) {
            final T bloc = BlocProvider.of<T>(context);
            return BlocListener<T, Object?>(
              listenWhen: (final _, final __) => false,
              listener: (final BuildContext context, final Object? state) {},
              child: builder(context, bloc),
            );
          },
        ),
      );
    }
  }
}
