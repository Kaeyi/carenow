import 'package:care_now/components/input_text_fields.dart';
import 'package:care_now/extensions/buildcontext/loc.dart';
import 'package:care_now/services/auth/auth_exception.dart';
import 'package:care_now/services/auth/bloc/auth_bloc.dart';
import 'package:care_now/services/auth/bloc/auth_event.dart';
import 'package:care_now/services/auth/bloc/auth_state.dart';
import 'package:care_now/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_auth_error,
            );
          }
        }
      },
    
    child: Scaffold(
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
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(
                          AuthEventLogIn(
                            email,
                            password,
                          ),
                        );
                  },
          child: Text(context.loc.login),
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
          child: const Text('Create Account',style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(),
                        );
                  },
          child: const Text('Forgot Password',style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),),
        ),
      ]),
    )));
  }
}
