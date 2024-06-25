import 'package:flutter/material.dart';
import 'package:app/widgets/logo.dart';
import 'package:app/widgets/text_field.dart';
import '../resources/auth_methods.dart';
import 'package:app/widgets/error_message.dart';



class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String res = await _authMethods.sendPasswordResetEmail(
      _emailTextController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      showErrorMessage(context, "Password reset email sent!");
      Navigator.pop(context);
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
              decoration: const BoxDecoration(
                color: Color(0xFFD0FCB3),
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
                    const SizedBox(height: 150),
                    const MainLogo(),
                    const SizedBox(height: 90.0),
                    BuildTextField(
                        hintText: 'Email Recover',
                        prefixIcon: Icons.email,
                        controller: _emailTextController),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 190.0),
                    _buildSendEmailButton(context),
                    const SizedBox(height: 16.0),
                    TextButton(
                      // Go to prevous screen
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Color(0xFF0A2E36)),
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

  Widget _buildSendEmailButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () {
          _sendPasswordResetEmail(context);
        },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A2E36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(308, 56),
      ),
      child: const Text(
        'Send Email',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
