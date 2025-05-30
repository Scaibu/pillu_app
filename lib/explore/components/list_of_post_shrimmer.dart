import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/shared/widgets/shimmer_box.dart';

class ListOfPostShrimmer extends StatelessWidget {
  const ListOfPostShrimmer({
    super.key,
  });

  @override
  Widget build(final BuildContext context) => ListView.builder(
        itemCount: 14,
        shrinkWrap: true,
        itemBuilder: (final BuildContext context, final int index) => Column(
          children: <Widget>[
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(
                height: 49,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              thickness: 0.2,
            ),
          ],
        ),
      );
}
