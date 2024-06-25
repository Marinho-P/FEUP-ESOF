import 'dart:async';

import 'package:app/model/event.dart';
import 'package:app/model/user.dart' as model;
import 'package:app/resources/firestore_methods.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/screens/others_profile_screen.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/error_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../resources/storage_methods.dart';

class ChatScreen extends StatefulWidget {
  final Event event;
  const ChatScreen({Key? key, required this.event}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatScreen> {
  final firestore = FirebaseFirestore.instance;
  final FireStoreMethods _firestoreService = FireStoreMethods();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
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
                          Navigator.pop(context);
                        },
                        rightIcon: null,
                        rightAction: () {},
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.event.title}",
                            style:  TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Comfortaa',
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FireStoreMethods().getEventMessages(widget.event),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                              if (snap.hasData) {
                                if (snap.data!.docs.isNotEmpty) {
                                  QueryDocumentSnapshot? data = snap.data!.docs.toList().first;
                                  return StreamBuilder(
                                      stream: FireStoreMethods().getEventMessages(widget.event),
                                      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                                        return !snap.hasData
                                            ? Container()
                                            : ListView.builder(
                                                itemCount: snap.data!.docs.length,
                                                reverse: true,
                                                itemBuilder: (context, i) {
                                                  if (snap.data!.docs[i]['sent_by'] ==
                                                      FirebaseAuth.instance.currentUser!.uid) {
                                                    return _MessageOwnTile(
                                                        message: snap.data!.docs[i]['message'],
                                                        messageDate: snap.data!.docs[i]['datetime']
                                                            .toDate());
                                                  } else {
                                                    return _MessageTile(
                                                        message: snap.data!.docs[i]['message'],
                                                        messageDate:
                                                            snap.data!.docs[i]['datetime'].toDate(),
                                                        uid: snap.data!.docs[i]['sent_by']);
                                                  }
                                                },
                                              );
                                      });
                                } else {
                                  return const Center(
                                    child: Text(
                                      'No conversion found',
                                    ),
                                  );
                                }
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blueGrey,
                                  ),
                                );
                              }
                            }),
                      ),
                      _MessageBar(
                        eid: widget.event,
                      ),
                    ],
                  )))
        ]));
  }
}

String timePassed(DateTime messageDate) {
  final now = DateTime.now();
  final difference = now.difference(messageDate);
  String time = '';

  if (difference.inDays > 0) {
    time = '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inHours > 0) {
    time = '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inMinutes > 0) {
    time = '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else {
    time = 'Just now';
  }

  return time;
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.message,
    required this.messageDate,
    required this.uid,
  }) : super(key: key);

  final String message;
  final DateTime messageDate;
  final String uid;

  Future<model.User?> loadUser() async {
    return (await FireStoreMethods().getUserData(uid));
  }

  Future<String> getAuthorName(String uid) async {
    return (await FireStoreMethods().getUserData(uid))!.username;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<model.User?>(
            future: loadUser(),
            builder: (BuildContext context, AsyncSnapshot<model.User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OthersProfileScreen(
                            user: snapshot.data!,
                              )),
                    );
                  },

                  child: snapshot.data?.urlProfileImage == ""
                      ?  Icon(
                          Icons.account_circle,
                          size: 40,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!.urlProfileImage),
                          radius: 20.0,
                        ),
                );
              } else {
                return  Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Theme.of(context).colorScheme.secondary,
                );
              }
            },
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: FutureBuilder<String>(
              future: getAuthorName(uid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration:  BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                        child: Text(
                          message,
                          style:  TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${snapshot.hasData ? snapshot.data! : "Unknown"}:  ${timePassed(messageDate)}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 112, 136, 96),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);

  final String message;
  final DateTime messageDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration:  BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    message,
                    style:  TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  timePassed(messageDate),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 112, 136, 96),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _MessageBar extends StatefulWidget {
  var eid;
  _MessageBar({Key? key, required this.eid}) : super(key: key);

  @override
  __MessageBarState createState() => __MessageBarState();
}

class __MessageBarState extends State<_MessageBar> {
  final TextEditingController controller_ = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  Future<void> _sendMessage() async {
    var eid = widget.eid;
    if (controller_.text.toString() != '') {
      await FireStoreMethods().addMessageToChat(eid, controller_.text.toString());
    }
    controller_.clear();
  }

  @override
  void dispose() {
    controller_.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final singleLineHeight = Theme.of(context).textTheme.bodyText2?.fontSize ?? 14;
    return Container(
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: const Border(
          top: BorderSide(
            color: Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: LimitedBox(
                      maxHeight: 10 * singleLineHeight,
                      child: TextField(
                        key: const ValueKey('SendTextField'),
                        controller: controller_,
                        maxLines: null,
                        style:   TextStyle(fontSize: 16, color:Theme.of(context).colorScheme.onPrimary),
                        onSubmitted: (_) => _sendMessage(),
                        decoration:  InputDecoration(
                          hintText: "Send Message",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color:Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: ClipOval(
                child: Material(
                  color: Theme.of(context).colorScheme.secondary,
                  child: InkWell(
                    splashColor: Colors.grey,
                    onTap: _sendMessage,
                    child:  SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        key: ValueKey("SendIconButton"),
                        Icons.send,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
