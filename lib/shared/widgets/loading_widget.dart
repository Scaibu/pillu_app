import 'package:pillu_app/core/library/pillu_lib.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
}
