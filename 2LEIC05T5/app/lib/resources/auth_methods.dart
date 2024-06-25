import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/model/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.User?> getUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await _firestore.collection('users').doc(currentUser.uid).get();

    if (!documentSnapshot.exists) {
      return null;
    }

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "success";
    } catch (err) {
      if (err is FirebaseAuthException) {
        return _getFirebaseAuthErrorMessage(err.code);
      } else {
        return err.toString();
      }
    }
  }

  Future<model.User?> getUserById(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        return model.User.fromSnap(snapshot);
      } else {
        return null; // User not found
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String confpassword,
    required String username,
  }) async {
    String res = "Some error occurred";
    try {
      if (password != confpassword) {
        return "Passwords don't match";
      }
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return "Please enter all the fields";
      }
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.sendEmailVerification();
      return "verification_required"; // Indicate that verification is needed
    } catch (err) {
      if (err is FirebaseAuthException) {
        return _getFirebaseAuthErrorMessage(err.code);
      }
      return err.toString();
    }
  }


  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (!userCredential.user!.emailVerified){
          res = "Please verify your email address";
        }else{
          res = "success";
        }
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        res = _getFirebaseAuthErrorMessage(err.code);
      } else {
        res = err.toString();
      }
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getFirebaseAuthErrorMessage(String errorCode) {
    // Add more error handling as needed
    switch (errorCode) {
      case 'invalid-email':
        return "Invalid email format.";
      case 'invalid-credential':
        return "Wrong password or email";
      case 'email-already-in-use':
        return "The email address is already in use by another account.";
      case 'weak-password':
        return "Password too weak.";
      case 'user-not-found':
        return 'User not found';
      default:
        return errorCode;
    }
  }
}