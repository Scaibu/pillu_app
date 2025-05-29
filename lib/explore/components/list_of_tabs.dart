import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/bloc/explore_bloc.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/model/appTab/app_tab.dart';

class ListOfTabs extends StatelessWidget {
  const ListOfTabs({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<ExploreBloc, ExploreState>(
        builder: (
          final BuildContext context,
          final ExploreState? state,
        ) =>
            SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: state!.tabs.map((final AppTab tab) {
              final bool isSelected = tab.id == state.selectedTabId;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () {
                    context.read<ExploreBloc>().add(SelectTabEvent(tab.id));
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.15),
                    foregroundColor: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium!.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    tab.title,
                    style: buildJostTextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).canvasColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
}
