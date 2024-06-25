import 'package:app/model/user.dart' as model;
import 'package:app/widgets/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/text_box.dart';

class OthersProfileScreen extends StatefulWidget {
  final model.User user;
  OthersProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  OthersProfileState createState() => OthersProfileState();
}

class OthersProfileState extends State<OthersProfileScreen> {


  void doesnothing() async {}

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
                      borderRadius: const BorderRadius.only(
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
                                  othersprofile: true,
                                  onChanged: (value) {},
                                  urlothersimage: widget.user.urlProfileImage,
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
                                  text: widget.user.username,
                                  section: 'Username',
                                  onPressed: () => doesnothing(),
                                  othersprofile: true,
                                ),
                                TextBox(
                                  text: widget.user.bio,
                                  section: 'Bio',
                                  onPressed: () => doesnothing(),
                                  othersprofile: true,
                                ),
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
                                      color:  Theme.of(context).colorScheme.secondary,
                                      width: 2,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.only(
                                      left: 15.0, right: 15.0, bottom: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            widget.user.eventsParticipated
                                                .toString(),
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
                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            widget.user.eventsCreated
                                                .toString(),
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
                                            widget.user.trashCollected
                                                .toString(),
                                            style:  TextStyle(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              fontFamily: 'Comfortaa',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
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
