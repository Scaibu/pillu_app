import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginViewComponent extends HookWidget {
  const LoginViewComponent({
    super.key,
    this.pilluUser,
    this.isGoogleLogicAllowed = false,
  });

  final PilluUserModel? pilluUser;
  final bool isGoogleLogicAllowed;

  Future<void> _login(
    final BuildContext context, {
    final TextEditingController? firstNameController,
    final TextEditingController? lastNameController,
  }) async {
    await handleAuthProcess(
      context: context,
      bloc: BlocProvider.of<PilluAuthBloc>(context),
      authOperation: () async =>
          createUser(firstNameController, lastNameController, context),
      onSuccess: () {
        showToast(context, message: 'Done');
      },
      onFailure: () => BlocProvider.of<PilluAuthBloc>(context)
          .add(UpdateAuthStateEvent(loggingIn: false)),
    );
  }

  Future<void> createUser(
    final TextEditingController? firstNameController,
    final TextEditingController? lastNameController,
    final BuildContext context,
  ) {
    if (isGoogleLogicAllowed) {
      return BlocProvider.of<PilluAuthBloc>(context).login(
        authApi,
        pilluUser: pilluUser,
      );
    } else {
      PilluUserModel? userModel = PilluUserModel(
        imageUrl: pilluUser?.imageUrl ?? '',
        firstName: pilluUser?.firstName ?? '',
        lastName: pilluUser?.lastName ?? '',
        id: pilluUser?.id ?? FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      if (pilluUser == null) {
        userModel = userModel.copyWith(
          firstName: _firstName(firstNameController, userModel),
          lastName: _lastName(lastNameController, userModel),
        );
      }

      return BlocProvider.of<PilluAuthBloc>(context).login(
        authApi,
        pilluUser: userModel,
      );
    }
  }

  String _lastName(
    final TextEditingController? lastNameController,
    final PilluUserModel userModel,
  ) =>
      (pilluUser?.lastName ?? '').isEmpty
          ? lastNameController?.text ?? ''
          : userModel.lastName;

  String _firstName(
    final TextEditingController? firstNameController,
    final PilluUserModel userModel,
  ) =>
      (pilluUser?.firstName ?? '').isEmpty
          ? firstNameController?.text ?? ''
          : userModel.firstName;

  Future<void> _goToLoginPage(
    final BuildContext context, {
    final TextEditingController? firstNameController,
    final TextEditingController? lastNameController,
  }) async {
    await _login(
      context,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
    );
  }

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

  @override
  Widget build(final BuildContext context) {
    final TextEditingController firstNameController =
        useTextEditingController();
    final TextEditingController lastNameController = useTextEditingController();
    final TextEditingController emailController = useTextEditingController();

    // Focus nodes with hooks
    final FocusNode firstNameFocusNode = useFocusNode();
    final FocusNode lastNameFocusNode = useFocusNode();
    final FocusNode emailFocusNode = useFocusNode();

    // Use hook for focus change management
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);

    void submitForm() {
      if (formKey.currentState?.validate() ?? false) {
        // Handle successful form submission
      } else {
        // Handle form validation failure
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
          Column(
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
                  submitForm();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () async {
                await _goToLoginPage(
                  context,
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
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
    );
  }
}
