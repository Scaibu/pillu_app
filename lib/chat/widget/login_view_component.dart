import 'package:flutter_hooks/flutter_hooks.dart';
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
    // Simple email validation
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

  Future<void> signUpLogin({
    required final BuildContext context,
    required final TextEditingController lastNameController,
    required final TextEditingController emailController,
    required final TextEditingController firstNameController,
    required final TextEditingController password,
    required final TextEditingController confirmPassword,
    required final GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (confirmPassword.text != password.text) {
      toast(context, message: 'Password not matched');
      await alertDialog(context, 'Password not matched');
      return;
    }

    await _createChatUserAccount(
      emailController,
      password,
      firstNameController,
      lastNameController,
      context,
    );
  }

  Future<void> _createChatUserAccount(
    final TextEditingController emailController,
    final TextEditingController password,
    final TextEditingController firstNameController,
    final TextEditingController lastNameController,
    final BuildContext context,
  ) async {
    final UserCredential value = await authApi.registerUser(
      context: context,
      email: emailController.text,
      password: password.text,
    );

    if (context.mounted) {
      await ChatService(
        pilluUser: PilluUserModel(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          imageUrl: value.user?.photoURL ?? '',
          id: value.user?.uid ?? '',
        ),
      ).createChatUser(context);
    }

    if (context.mounted) {
      context.read<PilluAuthBloc>().add(AuthAuthenticated(user: value.user));
    }
  }

  @override
  Widget build(final BuildContext context) {
    final TextEditingController firstNameController =
        useTextEditingController();
    final TextEditingController lastNameController = useTextEditingController();
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController password = useTextEditingController();
    final TextEditingController confirmPassword = useTextEditingController();

    // Focus nodes with hooks
    final FocusNode firstNameFocusNode = useFocusNode();
    final FocusNode lastNameFocusNode = useFocusNode();
    final FocusNode emailFocusNode = useFocusNode();
    final FocusNode passwordFocusNode = useFocusNode();
    final FocusNode passwordConfirmFocusNode = useFocusNode();

    // Use hook for focus change management
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> submitForm() async {
      await signUpLogin(
        context: context,
        lastNameController: lastNameController,
        emailController: emailController,
        firstNameController: firstNameController,
        password: password,
        confirmPassword: confirmPassword,
        formKey: formKey,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
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
                  LuxuryTextField(
                    controller: firstNameController,
                    focusNode: firstNameFocusNode,
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    validator: _validateFirstName,
                    onFieldSubmitted: (final _) {
                      FocusScope.of(context).requestFocus(lastNameFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name Text Field
                  LuxuryTextField(
                    controller: lastNameController,
                    focusNode: lastNameFocusNode,
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    validator: _validateLastName,
                    onFieldSubmitted: (final _) {
                      FocusScope.of(context).requestFocus(emailFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Text Field
                  LuxuryTextField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: _validateEmail,
                    onFieldSubmitted: (final _) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
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
                        _confirmPasswordValidation(password, confirmPassword),
                    onFieldSubmitted: (final _) async {
                      await submitForm();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () async {
                  await signUpLogin(
                    context: context,
                    lastNameController: lastNameController,
                    emailController: emailController,
                    firstNameController: firstNameController,
                    password: password,
                    confirmPassword: confirmPassword,
                    formKey: formKey,
                  );
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(10),
                  // Subtle background color
                ),
                child: Text(
                  'Start Your Adventure!',
                  style: buildJostTextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16, // Larger text for better readability
                    fontWeight: FontWeight.w600, // Bold for emphasis
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
