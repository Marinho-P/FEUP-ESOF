import 'package:app/model/user.dart' as model;
import 'package:app/resources/firestore_methods.dart';
import 'package:app/resources/storage_methods.dart';
import 'package:app/widgets/profile_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/widgets/text_box.dart';
import 'package:app/widgets/error_message.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfileScreen> {

  XFile? _profileimage;
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _bioTextController = TextEditingController();
  final TextEditingController _oldpasswordTextController = TextEditingController();
  final TextEditingController _newpasswordTextController = TextEditingController();
  model.User? currentUserData;
  User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    fetchUserData();
  }


  Future<void> fetchUserData() async {

    model.User? fetchedUserData = await FireStoreMethods().getUserData(currentUser!.uid);


    setState(() {
        currentUserData = fetchedUserData;
      });
}

Future<void> storeProfileImage() async {
  if(currentUserData!.urlProfileImage != ''){
    await StorageMethods().deleteProfileImage(currentUserData!.urlProfileImage);
  }
  String imageFinal = await StorageMethods().uploadImage(_profileimage);
  await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'urlProfileImage': imageFinal});
}


  Future<void> editUsername() async {
    String newUsername = "";
    _usernameTextController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Edit Username"),
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w600),
        content: TextField(
          controller: _usernameTextController,
          autofocus: true,
          decoration:  InputDecoration(
            hintText: "Enter new Username",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontFamily: 'Comfortaa',
              fontSize: 16,
            ),
          ),
        ),
        contentTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        actions: [
          TextButton(
              child: Text(
                'Save',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                newUsername = _usernameTextController.text;
                Navigator.of(context).pop();
              }),
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    if (newUsername.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'username': newUsername});
      fetchUserData();
    }
  }

  Future<void> editBio() async {
    String newBio = "";
    _bioTextController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Edit Bio"),
        titleTextStyle:  TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w600),
        content: TextField(
          controller: _bioTextController,
          maxLength: 120,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new Bio",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontFamily: 'Comfortaa',
              fontSize: 16,
            ),
          ),
        ),
        contentTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        actions: [
          TextButton(
              child: Text(
                'Save',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                newBio = _bioTextController.text;
                Navigator.of(context).pop();
              }),
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    if (newBio.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'bio': newBio});
      fetchUserData();
    }
  }

  Future<void> changePassword() async {
    String oldPassword = "", newPassword = "";
    _oldpasswordTextController.clear();
    _newpasswordTextController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Change Password"),
        titleTextStyle:  TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w600),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldpasswordTextController,
              autofocus: true,
              decoration:  InputDecoration(
                hintText: "Old Password",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                ),
              ),
            ),
            TextField(
              controller: _newpasswordTextController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "New Password",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        contentTextStyle:  TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        actions: [
          TextButton(
              child:  Text(
                'Save',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                oldPassword = _oldpasswordTextController.text;
                newPassword = _newpasswordTextController.text;
                Navigator.of(context).pop();
              }),
          TextButton(
            child:  Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
      if (oldPassword.trim().isNotEmpty && newPassword.trim().isNotEmpty ) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUserData!.email, 
          password: oldPassword,
          );

          try {
              await currentUser!.reauthenticateWithCredential(credential);
              await currentUser!.updatePassword(newPassword);
              showErrorMessage(context, "Password Updated!");

            } 
          catch (e) {
            showErrorMessage(context, e.toString());
            }   
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: currentUserData == null ? 
      Column(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomAppBar(
                      title: 'CleanCity',
                      leftIcon: Icons.arrow_back_ios_rounded,
                      leftAction: () {

                      },
                      rightAction: () {
                      }),
                ],
              ),
            ),
          ),
        ],
      ) :
      
      Column(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomAppBar(
                      title: 'CleanCity',
                      leftIcon: Icons.arrow_back_ios_rounded,
                      leftAction: () {
                        if(_profileimage != null){
                          storeProfileImage();
                        }
                        Navigator.pop(
                          context,
                        );
                      },
                      rightAction: () {}),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile",
                            style:  TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Comfortaa',
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          ProfilePhoto(
                            othersprofile: false,
                            onChanged: (value) {
                              setState(() {
                                _profileimage = value;
                              });
                            },
                            urlothersimage: '',
                          ),
                          const SizedBox(height: 5),
                           Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Info",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Comfortaa',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextBox(
                              text: currentUserData!.username,
                              section: 'Username',
                              onPressed: () => editUsername(),
                              othersprofile: false,),
                          TextBox(
                              text: currentUserData!.bio,
                              section: 'Bio',
                              onPressed: () => editBio(),
                              othersprofile: false,),
                          TextBox(
                              text: '******',
                              section: 'Password',
                              onPressed: () => changePassword(),
                              othersprofile: false,),
                           Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Statistics",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Comfortaa',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.only(
                                left: 15.0, right: 15.0, bottom: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                     Text('Events Participated',
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),

                                            Text(
                                              currentUserData!.eventsParticipated.toString(),
                                              style:  TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                                fontFamily: 'Comfortaa',
                                                fontSize: 16,
                                              ),
                                            )

                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                     Text('Events Created',
                                        style: TextStyle(
                                            color:Theme.of(context).colorScheme.onPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      currentUserData!.eventsCreated.toString(),
                                      style:  TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontFamily: 'Comfortaa',
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                     Text(
                                      'Trash Collected',
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      currentUserData!.trashCollected.toString(),
                                      style:  TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontFamily: 'Comfortaa',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                 Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Center(
                                    child: Text(
                                      'Thank you for your contribution!',
                                      style: TextStyle(
                                          color:Theme.of(context).colorScheme.onPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

