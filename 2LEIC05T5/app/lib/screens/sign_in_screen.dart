import 'package:flutter/material.dart';
import 'package:app/widgets/logo.dart';
import 'package:app/widgets/error_message.dart';
import 'package:app/screens/sign_up_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/screens/restore_password_screen.dart';
import 'package:app/widgets/text_field.dart';
import 'package:app/resources/auth_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  Future<String> loginUser() async {
    String res = await AuthMethods().loginUser(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text);
    if (res == "success") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, res);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(56),
                  topRight: Radius.circular(56),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 60),
                    const MainLogo(),
                    const SizedBox(height: 150.0),
                    BuildTextField(
                        key: const ValueKey('EmailTextField'),
                        hintText: 'Email', prefixIcon: Icons.email, controller: _emailTextController),
                    const SizedBox(height: 16.0),
                    BuildTextField(
                        key: const ValueKey('PasswordTextField'),
                        hintText: 'Password', prefixIcon: Icons.lock, controller: _passwordTextController, isObscure : true),
                    const SizedBox(height: 180.0),
                    _buildLoginButton(context),
                    const SizedBox(height: 16.0),
                    _buildRegisterRow(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        loginUser();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(308, 56),
      ),
      child:  Text(
        'Sign In',
        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }

  Widget _buildRegisterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()));
          },
          child:  Text(
            "Sign Up",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        const SizedBox(
          width: 32,
        ),
        SizedBox(
          child: TextButton(
            child:  Text(
              "Reset Password",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.right,
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ResetPasswordScreen())),
          ),
        )
      ],
    );
  }
}

