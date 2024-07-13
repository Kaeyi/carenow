import 'package:care_now/components/input_text_fields.dart';
import 'package:care_now/extensions/buildcontext/loc.dart';
import 'package:care_now/services/auth/auth_exception.dart';
import 'package:care_now/services/auth/bloc/auth_bloc.dart';
import 'package:care_now/services/auth/bloc/auth_event.dart';
import 'package:care_now/services/auth/bloc/auth_state.dart';
import 'package:care_now/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final TextEditingController _username;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _username = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateRegistering) {
            if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_weak_password,
              );
            } else if (state.exception is EmailAlreadyInUseAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_email_already_in_use,
              );
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_generic,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_invalid_email,
              );
            }
          }
        },
        child: Scaffold(
            body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Image.asset('assets/images/Authentication-cuate.png'),
            const Text('Welcome to',
                style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Colors.grey)),
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
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
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

            const SizedBox(height: 20),
          
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

                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                      AuthEventRegister(
                        email: email,
                        password: password,
                      ),
                    );
              },
              child: const Text('Register'),
            ),
            const SizedBox(
              height: 20,
            ),
          ]),
        )));
  }
}
