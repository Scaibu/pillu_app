import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginViewComponent extends HookWidget {
  const LoginViewComponent({super.key});

  String? _validateFirstName(final String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? _validateLastName(final String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your last name';
    }
    return null;
  }

  String? _validateEmail(final String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your email';
    }

    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegExp.hasMatch(value ?? '')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _confirmPasswordValidation(
    final TextEditingController password,
    final TextEditingController confirmPassword,
  ) {
    if (password.text != confirmPassword.text) {
      return 'Password and confirm password do not match.';
    }
    return null;
  }

  String? _passwordValidation(final TextEditingController password) {
    if (password.text.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> _callSignUpLogin({
    required final BuildContext context,
    required final TextEditingController email,
    required final TextEditingController password,
    required final GlobalKey<FormState> formKey,
    required final TextEditingController confirmPassword,
    required final TextEditingController lastName,
    required final TextEditingController firstName,
  }) async {
    if (password.text.isEmpty) {
      if (context.mounted) {
        toast(context, message: 'Password is empty');
        await alertDialog(context, 'Password is empty');
      }

      return;
    }

    if (email.text.isEmpty) {
      if (context.mounted) {
        toast(context, message: 'Email is empty');
        await alertDialog(context, 'Email is empty');
      }

      return;
    }

    if (confirmPassword.text.isEmpty) {
      await _createChatUserAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        context: context,
        isUploadPicture: false,
      );
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }
    if (confirmPassword.text != password.text) {
      if (context.mounted) {
        toast(context, message: 'Password not matched');
        await alertDialog(context, 'Password not matched');
      }

      return;
    }

    if (context.mounted) {
      await _createChatUserAccount(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        context: context,
        isUploadPicture: true,
      );
    }
  }

  Future<void> _createChatUserAccount({
    required final TextEditingController email,
    required final TextEditingController password,
    required final TextEditingController? firstName,
    required final TextEditingController? lastName,
    required final BuildContext context,
    required final bool isUploadPicture,
  }) async {
    final PilluAuthBloc bloc = context.read<PilluAuthBloc>();

    if (context.mounted) {
      bloc.add(AuthLoadingEvent(isLoading: true));

      try {
        final UserCredential value = await AuthApi.registerUser(
          context: context,
          email: email.text,
          password: password.text,
        );

        if (context.mounted) {
          final String? imageUrl;
          if (isUploadPicture) {
            imageUrl = await uploadUserProfilePicture(
              context: context,
              id: value.user?.uid ?? '',
            );
          } else {
            imageUrl = '';
          }

          final types.User user = types.User(
            imageUrl:
                isUploadPicture ? '' : imageUrl ?? value.user?.photoURL ?? '',
            firstName: firstName?.text ?? '',
            lastName: lastName?.text ?? '',
            id: value.user?.uid ?? '',
          );

          await FirebaseChatCore.instance.createUserInFirestore(user);

          if (context.mounted) {
            bloc.add(AuthLoadingEvent(isLoading: false));
            toast(
              context,
              message: 'Welcome back, ${user.firstName} ${user.lastName}!',
            );

            context
                .read<PilluAuthBloc>()
                .add(AuthAuthenticated(user: value.user));
          }
        }
      } catch (e) {
        if (context.mounted) {
          context.read<PilluAuthBloc>().add(UserLogOutEvent());
          toast(context, message: e.toString());
          await alertDialog(context, e.toString());
          bloc.add(AuthLoadingEvent(isLoading: false));
        }
      }
    }
  }

  Future<void> _signInSignUp({
    required final BuildContext context,
    required final TextEditingController emailController,
    required final TextEditingController password,
    required final GlobalKey<FormState> formKey,
    required final bool isExecute,
    required final TextEditingController firstNameController,
    required final TextEditingController lastNameController,
    required final TextEditingController confirmPassword,
  }) async {
    final AuthDataState currState = context.read<PilluAuthBloc>().state;

    final bool isRestart = currState.isRestartEvent;

    if (isExecute) {
      await _callSignUpLogin(
        context: context,
        email: emailController,
        password: password,
        formKey: formKey,
        firstName: firstNameController,
        lastName: lastNameController,
        confirmPassword: confirmPassword,
      );

      if (!context.mounted) {
        return;
      }

      return;
    }

    context.read<PilluAuthBloc>().add(
          isRestart ? StartCurrentEvent() : IsRestartEvent(),
        );
  }

  @override
  Widget build(final BuildContext context) {
    final TextEditingController firstName = useTextEditingController();
    final TextEditingController lastName = useTextEditingController();
    final TextEditingController email = useTextEditingController();
    final TextEditingController password = useTextEditingController();
    final TextEditingController confirmPassword = useTextEditingController();

    final FocusNode firstNameFocusNode = useFocusNode();
    final FocusNode lastNameFocusNode = useFocusNode();
    final FocusNode emailFocusNode = useFocusNode();
    final FocusNode passwordFocusNode = useFocusNode();
    final FocusNode passwordConfirmFocusNode = useFocusNode();

    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> submitForm() async {
      await _callSignUpLogin(
        context: context,
        lastName: lastName,
        email: email,
        firstName: firstName,
        password: password,
        confirmPassword: confirmPassword,
        formKey: formKey,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: BlocBuilder<PilluAuthBloc, AuthDataState>(
          builder: (final BuildContext context, final AuthDataState state) {
            final AuthDataState currState = state;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16),
                Text(
                  'Let’s Get to Know You!',
                  style: buildJostTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enter your details to create your account',
                  style: buildJostTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      if (currState.isRestartEvent)
                        Column(
                          children: <Widget>[
                            LuxuryTextField(
                              controller: firstName,
                              focusNode: firstNameFocusNode,
                              labelText: 'First Name',
                              hintText: 'Enter your first name',
                              validator: _validateFirstName,
                              onFieldSubmitted: (final _) {
                                FocusScope.of(context)
                                    .requestFocus(lastNameFocusNode);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Last Name Text Field
                            LuxuryTextField(
                              controller: lastName,
                              focusNode: lastNameFocusNode,
                              labelText: 'Last Name',
                              hintText: 'Enter your last name',
                              validator: _validateLastName,
                              onFieldSubmitted: (final _) {
                                FocusScope.of(context)
                                    .requestFocus(emailFocusNode);
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Email Text Field
                      LuxuryTextField(
                        controller: email,
                        focusNode: emailFocusNode,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateEmail,
                        onFieldSubmitted: (final _) {
                          FocusScope.of(context)
                              .requestFocus(passwordFocusNode);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Text Field
                      LuxuryTextField(
                        controller: password,
                        focusNode: passwordFocusNode,
                        labelText: 'Password',
                        hintText: 'Enter your Password',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        validator: (final String? p0) =>
                            _passwordValidation(password),
                        onFieldSubmitted: (final _) {
                          FocusScope.of(context)
                              .requestFocus(passwordConfirmFocusNode);
                        },
                      ),
                      if (currState.isRestartEvent)
                        Column(
                          children: <Widget>[
                            const SizedBox(height: 16),

                            // Password Text Field
                            LuxuryTextField(
                              controller: confirmPassword,
                              focusNode: passwordConfirmFocusNode,
                              labelText: 'Confirm Password',
                              hintText: 'Enter your Confirm Password',
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.done,
                              validator: (final String? p0) =>
                                  _confirmPasswordValidation(
                                password,
                                confirmPassword,
                              ),
                              onFieldSubmitted: (final _) async {
                                await submitForm();
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: BlocBuilder<PilluAuthBloc, AuthDataState>(
                    builder: (
                      final BuildContext context,
                      final AuthDataState currState,
                    ) {
                      final bool isLoading = currState.isLoading;
                      final ThemeData theme = Theme.of(context);

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 1,
                          end: isLoading ? 0.95 : 1.0,
                        ),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        builder: (
                          final BuildContext context,
                          final double scale,
                          final Widget? child,
                        ) =>
                            Transform.scale(
                          scale: scale,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              borderRadius: BorderRadius.circular(32),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                splashColor: theme.splashColor,
                                hoverColor: theme.hoverColor,
                                highlightColor:
                                    theme.highlightColor.withOpacity(0.1),
                                onTap: () async {
                                  await _signInSignUp(
                                    context: context,
                                    emailController: email,
                                    confirmPassword: confirmPassword,
                                    firstNameController: firstName,
                                    lastNameController: lastName,
                                    password: password,
                                    formKey: formKey,
                                    isExecute: true,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (
                                      final Widget child,
                                      final Animation<double> animation,
                                    ) =>
                                        FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                    child: isLoading
                                        ? Row(
                                            key: const ValueKey<String>(
                                              'loading',
                                            ),
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 15,
                                                height: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    theme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Shifting gears, wait up...',
                                                style: buildJostTextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            currState.isRestartEvent
                                                ? 'Start Your Adventure!'
                                                : 'Restart Your Adventure!',
                                            key: const ValueKey<String>('text'),
                                            style: buildJostTextStyle(
                                              color: theme.primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Theme.of(context).primaryColor,
                  thickness: 0.2,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 1,
                      end: 1,
                    ),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    builder: (final BuildContext context, final double scale,
                            final Widget? child) =>
                        Transform.scale(
                      scale: scale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(32),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(32),
                            splashColor: Theme.of(context).splashColor,
                            hoverColor: Theme.of(context).hoverColor,
                            highlightColor: Theme.of(context)
                                .highlightColor
                                .withOpacity(0.1),
                            onTap: () async {
                              if (currState.isRestartEvent) {
                                await _signInSignUp(
                                  context: context,
                                  lastNameController: lastName,
                                  emailController: email,
                                  firstNameController: firstName,
                                  password: password,
                                  confirmPassword: confirmPassword,
                                  formKey: formKey,
                                  isExecute: false,
                                );
                                return;
                              }
                              if (context.mounted) {
                                context
                                    .read<PilluAuthBloc>()
                                    .add(IsRestartEvent());
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (final Widget child,
                                        final Animation<double> animation) =>
                                    FadeTransition(
                                        opacity: animation, child: child),
                                child: Text(
                                  currState.isRestartEvent
                                      ? 'Start Your Adventure!'
                                      : 'Restart Your Adventure!',
                                  key: const ValueKey<String>('text'),
                                  style: buildJostTextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
