import 'package:bloc/bloc.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState().init()) {
    on<InitEvent>(_init);
  }

  void _init(final InitEvent event, final Emitter<ProfileState> emit) async {
    emit(state.clone());
  }
}
