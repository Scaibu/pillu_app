import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/profile/bloc/profile_bloc.dart';
import 'package:pillu_app/profile/bloc/profile_event.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  Future<void> _updateUserProfile(
    final BuildContext context,
    final User? state,
    final TextEditingController firstNameController,
    final TextEditingController lastNameController,
  ) async {
    await FirebaseChatCore.instance.updateUserInFirestore(
      context: context,
      user: types.User(
        id: state?.uid ?? '',
        firstName: firstNameController.text,
        lastName: lastNameController.text,
      ),
    );
  }

  Future<void> _updateProfilePicture(
    final BuildContext context,
    final types.User? state,
  ) async {
    if (state == null || state.id.isEmpty || !context.mounted) {
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return;
      }

      final File imageFile = File(pickedFile.path);
      final FirebaseStorage storage = FirebaseStorage.instance;

      // Delete existing image if available
      if (state.imageUrl != null && state.imageUrl!.isNotEmpty) {
        try {
          final Uri uri = Uri.parse(state.imageUrl!);
          final List<String> segments = uri.pathSegments;
          final int index = segments.indexOf('o');
          if (index != -1 && index + 1 < segments.length) {
            final String encodedPath = segments[index + 1];
            final String filePath = Uri.decodeComponent(encodedPath);
            await storage.ref(filePath).delete();
          }
        } catch (e) {
          debugPrint('Failed to delete previous image: $e');
        }
      }

      // Upload new image
      final String uniqueName = '${const Uuid().v4()}.jpg';
      final String filePath = 'user/${state.id}/posts/images/$uniqueName';
      final UploadTask uploadTask = storage.ref(filePath).putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();

      if (context.mounted) {
        await FirebaseChatCore.instance.updateUserInFirestore(
          user: types.User(
            id: state.id,
            imageUrl: imageUrl,
          ),
          context: context,
        );
      }
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      if (context.mounted) {
        toast(context, message: 'Failed to update profile picture.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final TextEditingController firstNameController =
        useTextEditingController();
    final TextEditingController lastNameController = useTextEditingController();

    final FocusNode firstNameFocusNode = useFocusNode();
    final FocusNode lastNameFocusNode = useFocusNode();
    final FocusNode emailFocusNode = useFocusNode();

    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocProvider<ProfileBloc>(
      create: (final BuildContext context) => ProfileBloc()..add(InitEvent()),
      child: Builder(
        builder: (final BuildContext context) =>
            CustomBlocBuilder<PilluAuthBloc>(
          create: (final BuildContext context) =>
              PilluAuthBloc(PilluAuthRepository()),
          builder: (final BuildContext context, final PilluAuthBloc bloc) =>
              ThemeWrapper(
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: buildAppBar(context, title: 'Profile'),
                body: SingleChildScrollView(
                  child: BlocSelector<PilluAuthBloc, AuthDataState, User?>(
                    selector: (final AuthDataState state) =>
                        state.user,
                    builder: (final BuildContext context, final User? state) =>
                        StreamBuilder<types.User?>(
                      stream: FirebaseChatCore.instance
                          .currentUser()
                          .map((final types.User? user) => user),
                      builder: (
                        final BuildContext context,
                        final AsyncSnapshot<types.User?> snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(height: 250),
                                const Icon(Icons.error_outline, size: 100),
                                const SizedBox(height: 16),
                                Text(
                                  'Code sequence \nis corrupted',
                                  style: buildJostTextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 32,
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(10),
                                    // Subtle background color
                                  ),
                                  child: Text(
                                    'Start Over',
                                    style: buildJostTextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final types.User? data = snapshot.data;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                await _updateProfilePicture(context, data);
                              },
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 550,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      if (data?.imageUrl != null)
                                        CachedNetworkImage(
                                          imageUrl: data?.imageUrl ?? '',
                                          fit: BoxFit.fill,
                                          placeholder: (
                                            final BuildContext context,
                                            final String url,
                                          ) =>
                                              const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            maxRadius: 70,
                                            child: Icon(Icons.person, size: 40),
                                          ),
                                        )
                                      else
                                        const CircleAvatar(
                                          backgroundColor: Colors.white,
                                          maxRadius: 70,
                                          child: Icon(Icons.person, size: 40),
                                        ),
                                      Positioned(
                                        bottom: 16,
                                        right: 16,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).canvasColor,
                                          maxRadius: 18,
                                          child: IconButton(
                                            onPressed: () async {
                                              await _updateProfilePicture(
                                                context,
                                                data,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              size: 21,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Form(
                                    key: formKey,
                                    child: Column(
                                      children: <Widget>[
                                        LuxuryTextField(
                                          controller: firstNameController
                                            ..text = data?.firstName ?? '',
                                          focusNode: firstNameFocusNode,
                                          labelText: 'First Name',
                                          hintText: 'Enter your first name',
                                          validator: (final String? p0) => null,
                                          onFieldSubmitted: (final _) {
                                            FocusScope.of(context).requestFocus(
                                              lastNameFocusNode,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Last Name Text Field
                                        LuxuryTextField(
                                          controller: lastNameController
                                            ..text = data?.lastName ?? '',
                                          focusNode: lastNameFocusNode,
                                          labelText: 'Last Name',
                                          hintText: 'Enter your last name',
                                          validator: (final String? p0) => null,
                                          onFieldSubmitted: (final _) {
                                            FocusScope.of(context)
                                                .requestFocus(emailFocusNode);
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () async {
                                                  await _updateUserProfile(
                                                    context,
                                                    state,
                                                    firstNameController,
                                                    lastNameController,
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 14,
                                                    horizontal: 32,
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withAlpha(10),
                                                  // Subtle background color
                                                ),
                                                child: Text(
                                                  'Seal the Deal',
                                                  style: buildJostTextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
