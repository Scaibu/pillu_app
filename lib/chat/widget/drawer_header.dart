import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/shared/text_styles.dart';

class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<PilluAuthBloc, AuthLocalState, User?>(
        selector: (final AuthLocalState state) => (state as AuthDataState).user,
        builder: (final BuildContext context, final User? state) {
          if (state == null) {
            return const Offstage();
          }

          return Container(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: (state.providerData.first.photoURL != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            imageUrl: state.providerData.first.photoURL ?? '',
                          ),
                        )
                      : const Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.displayName ?? '',
                      style: buildJostTextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      state.email ?? '',
                      style: buildJostTextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
}
