import 'package:care_now/components/input_text_fields.dart';
import 'package:care_now/constants/routes.dart';
import 'package:care_now/services/auth/auth_exception.dart';
import 'package:care_now/services/auth/auth_service.dart';
import 'package:care_now/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        // Image.asset('assets/images/Authentication-cuate.png'),
        const Text('Welcome to',
            style: TextStyle(
                fontStyle: FontStyle.normal, fontSize: 20, color: Colors.grey)),
        const Text('CareNow',
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.deepPurple)),
        const Text('Create Account',
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 35,
                color: Colors.black)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Already registered?',
              style: TextStyle(
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text(
                'Login here!',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),

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
                  await AuthService.firebase().createUser(
                  //await needed cause createUser is a Future thing
                  email: email,
                  password: password,
                );
                // devtools.log(userCredential.toString());
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);//use puahNamed instead of pushNameAndRemoveUntill cuz we do not need to replace the reggister view for this verify email view/ and oso this can help when user realise they use the wrong email so they can return to the register page
              } on WeakPasswordAuthException {
                await showErrorDialog(
                    context,
                    'Weak-password',
                  );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                    context,
                    'Email already in use',
                  );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                    context,
                    'Invalid email',
                  );
              } on GenericAuthException {
                await showErrorDialog(
                    context,
                    'Failed to register',
                  );
              }
          },
          child: const Text('Register'),
        ),
        const SizedBox(
          height: 20,
        ),
      ]),
    ));
  }
}
