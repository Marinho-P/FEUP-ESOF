import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/widgets/logo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/widgets/error_message.dart';
import 'package:app/model/user.dart' as model;

class VerifyEmailScreen extends StatefulWidget {

  final String username;
  const VerifyEmailScreen({Key? key, required this.username}) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      // Now create Firestore document since email is verified
      model.User newUser = model.User(
        username: widget.username, // pass these as arguments or manage globally
        uid: user.uid,
        email: user.email!,
        followingEvents: [],
        bio: 'Empty Bio...',
        eventsParticipated: 0,
        eventsCreated: 0,
        trashCollected: 0,
        urlProfileImage: '',
      );
      await _firestore.collection("users").doc(user.uid).set(newUser.toJson());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
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
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0, 70),
                    child: SvgPicture.asset(
                      'lib/assets/get_started_background.svg',
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 60),
                      const MainLogo(),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => {
                            _auth.currentUser!.sendEmailVerification(),
                            showErrorMessage(context, "Verify your email.")
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A2E36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(308, 56),
                          ),
                          child: const Text('Resend Verification Email',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
