import 'package:flutter/material.dart';
import 'package:app/widgets/logo.dart';
import 'package:app/screens/sign_in_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/screens/verify_email_screen.dart';
import 'package:app/widgets/text_field.dart';
import '../resources/auth_methods.dart';
import 'package:app/widgets/error_message.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<RegisterScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _confPasswordTextController =
      TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  void createUser() async {
    String res = await AuthMethods().signUpUser(
      email: _emailTextController.text.trim(),
      password: _passwordTextController.text,
      confpassword: _confPasswordTextController.text,
      username: _userNameTextController.text.trim(),
    );
    String enterUsername = _userNameTextController.text.trim();
    if (res == "verification_required") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerifyEmailScreen(
            username: enterUsername
        )),
      );
    } else {
      showErrorMessage(context, res);
    }
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

              decoration: BoxDecoration(
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
                    const SizedBox(height: 90.0),
                    BuildTextField(
                        hintText: 'Username',
                        prefixIcon: Icons.person,
                        controller: _userNameTextController),
                    const SizedBox(height: 16.0),
                    BuildTextField(
                        hintText: 'Email',
                        prefixIcon: Icons.email,
                        controller: _emailTextController),
                    const SizedBox(height: 16.0),
                    BuildTextField(
                        hintText: 'Password',
                        prefixIcon: Icons.lock,
                        controller: _passwordTextController,
                        isObscure: true),
                    const SizedBox(height: 16.0),
                    BuildTextField(
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.lock,
                        controller: _confPasswordTextController,
                        isObscure: true),
                    const SizedBox(height: 120.0),
                    _buildRegisterButton(context),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        createUser();
      },
      style: ElevatedButton.styleFrom(

        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(308, 56),
      ),
      child:  Text(
        'Register',
        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}
