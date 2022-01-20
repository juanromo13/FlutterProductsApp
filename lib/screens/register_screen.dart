import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productos_app/providers/login_form_provider.dart';
import 'package:productos_app/services/auth_service.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: AuthBackground(
            child: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.25),
          CardContainer(
              child: Column(
            children: [
              Text('Register', style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 20),
              ChangeNotifierProvider(
                  create: (_) => LoginFormProvider(), child: _LoginForm()),
            ],
          )),
          SizedBox(height: 40.0),
          TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
              child: Text('Already have an account?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black))),
          SizedBox(height: 40.0)
        ],
      ),
    )));
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
          key: loginForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'email@email.com',
                    labelText: 'Email',
                    prefixIcon: Icons.alternate_email),
                onChanged: (value) => loginForm.email = value,
                validator: (value) {
                  String pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regExp = new RegExp(pattern);

                  return regExp.hasMatch(value ?? '') ? null : 'must be a mail';
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                autocorrect: false,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecorations.authInputDecoration(
                    hintText: '',
                    labelText: 'Password',
                    prefixIcon: Icons.lock_outline),
                onChanged: (value) => loginForm.password = value,
                validator: (value) {
                  return (value != null && value.length >= 6)
                      ? null
                      : 'must have at least 6 characters';
                },
              ),
              SizedBox(height: 20),
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minWidth: 200.0,
                  disabledColor: Colors.grey,
                  color: Colors.deepPurple,
                  child: Text(loginForm.isLoading ? '...' : 'Sign up',
                      style: TextStyle(color: Colors.white)),
                  onPressed: loginForm.isLoading
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();

                          if (!loginForm.isValidForm()) return;

                          loginForm.isLoading = true;

                          final authService = Provider.of<AuthService>(context, listen: false);
                          
                          final String? errorMessage = await authService.createUser(loginForm.email, loginForm.password);

                          loginForm.isLoading = false;
                          if (errorMessage == null) {
                            Navigator.pushReplacementNamed(context, 'home');
                          } else {
                            NotificationsService.showSnack(errorMessage);
                          }

                        })
            ],
          )),
    );
  }
}
