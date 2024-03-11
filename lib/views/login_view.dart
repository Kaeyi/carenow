import 'package:care_now/components/input_text_fields.dart';
import 'package:care_now/services/auth/auth_exception.dart';
import 'package:care_now/services/auth/auth_service.dart';
import 'package:care_now/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:care_now/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  


  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Welcome to',
            style: TextStyle(
                fontStyle: FontStyle.normal, fontSize: 20, color: Colors.grey)),
        const Text('CareNow',
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Colors.deepPurple)),
        const SizedBox(
          height: 30,
        ),
        ObscuredTextField(
          controller: _email,
          obsecureText: false,
          labelText: 'Email',
        ),
        const SizedBox(
          height: 20,
        ),
        ObscuredTextField(
          controller: _password,
          obsecureText: true,
          labelText: 'Password',
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
          ),
          onPressed: () async {
            final email = _email.text; //mean we go to _email and grab their text tats why .text
              final password = _password.text;
              try {
                // final userCredential =
                await AuthService.firebase().login(
                  //await needed cause createUser is a Future thing
                  email: email,
                  password: password,
                );
                // devtools.log(userCredential.toString());
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  //user email is verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    homeRoute,
                    (route) => false,
                  );
                } else {
                  //user email is not verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                    context,
                    'User not found',
                  );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                    context,
                    'Wrong credentials',
                  );
              } on GenericAuthException {
                await showErrorDialog(
                    context,
                    'Authentication error.',
                  );
              }
          },
          child: const Text('Login'),
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false);
          },
          child: const Text('Create Account',style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () {
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //   registerRoute,
            //   (route) => false,
            // );
          },
          child: const Text('Forgot Password',style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),),
        ),
      ]),
    ));
  }
}
