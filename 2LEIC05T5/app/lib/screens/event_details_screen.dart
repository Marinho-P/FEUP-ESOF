import 'package:app/model/event.dart';
import 'package:app/resources/firestore_methods.dart';
import 'package:app/screens/chat_screen.dart';
import 'package:app/resources/notification_methods.dart';
import 'package:app/screens/evaluate_event_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/screens/others_profile_screen.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/confirm_action.dart';
import 'package:app/widgets/error_message.dart';
import 'package:app/widgets/event_card.dart';
import 'package:app/widgets/slide_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/user.dart' as model;
import 'create_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  Event event;

  EventDetailsScreen({super.key, required this.event});

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetailsScreen> {
  final SlideBarController _slideBarController = SlideBarController(true);
  final PageController _pageController = PageController();
  bool jank = false;
  // Use dataBase to initialize this button
  String type = "notJoined";
  List<model.User> participants = [];

  void handleNoEvent() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  function: () {
                    showErrorMessage(context, "Event not available anymore");
                  },
                )));
  }

  @override
  void initState() {
    super.initState();
    type = _getUserType();
    _loadParticipants();
  }

  void _loadParticipants() async {
    if (widget.event.enrolledUsers.isNotEmpty) {
      List<model.User> user = [];
      await FireStoreMethods().getParticipantInfo(widget.event.enrolledUsers, user);
      setState(() {
        participants = user;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _slideBarController.dispose();
    _pageController.dispose();
  }

  void _ToggleStates() {
    jank = true;

    if (_slideBarController.value) {
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  void navigateAndRefresh() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateEventScreen(
                  event: widget.event,
                  onEventUpdated: _refreshEvent,
                )));

    if (result == 'updated') {
      _refreshEvent();
    }
  }

  Future<void> _refreshEvent() async {
    try {
      Event? updatedEvent = await FireStoreMethods().getEventById(widget.event.eid);
      if (updatedEvent != null) {
        setState(() {
          widget.event =
              updatedEvent; // Assuming `widget.event` is mutable; otherwise, adjust accordingly.
        });
      }
    } catch (e) {
      print('Failed to refresh event: $e');
    }
  }

  String _getUserType() {
    List<String> enrolledUsers = widget.event.enrolledUsers;
    String userUid = FireStoreMethods().getUser()!.uid;

    if (enrolledUsers.elementAt(0) == userUid) {
      final now = DateTime.now();
      final difference = widget.event.time.add(widget.event.parseDuration()).difference(now);
      if (difference.isNegative) return "finished";
      return "owner";
    }

    if (widget.event.enrolledUsers.contains(userUid)) {
      return "joined";
    }

    return "notJoined";
  }

  void _showConfirmBox(VoidCallback leftTap) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ConfirmBox(
            leftTap: () {
              leftTap();
            },
          );
        });
  }

  Widget _getButtons() {
    final user = FireStoreMethods().getUser();
    return switch (type) {
      "notJoined" => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                widget.event.enrolledUsers.add(user!.uid);
                FireStoreMethods().joinEvent(widget.event);
                NotificationMethods().addUserToEventNotifications(widget.event.eid);
                _loadParticipants();
                type = "joined";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(308, 56),
            ),
            child: Text(
              'Join event',
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ),
      "owner" => _CreateDoubleButton("Cancel Event", () {
          // Delete from dataBase
          _showConfirmBox(() {
            FireStoreMethods().removeEvent(widget.event);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(
                          function: () {
                            showErrorMessage(context, "Event canceled!");
                          },
                        )));
          });
        }),
      "joined" => _CreateDoubleButton("Exit Event", () {
          _showConfirmBox(() {
            setState(() {
              widget.event.enrolledUsers.remove(user?.uid);
              FireStoreMethods().exitEvent(widget.event);
              NotificationMethods().removeUserFromEventNotifications(widget.event.eid);
              _loadParticipants();
              type = "notJoined";
            });
          });
        }),
      "finished" => _CreateDoubleButton("Finish Event", () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EvaluateEventScreen(
                      event: widget.event,
                    )),
          );
        }),
      _ => Container(),
    };
  }

  Widget _getGoogleMap(Event event) {
    var pos = LatLng(widget.event.location.latitude, widget.event.location.longitude);
    var initialCameraPosition = CameraPosition(
      target: LatLng(pos.latitude + 0.02, pos.longitude),
      zoom: 11.5,
    );

    GoogleMapController? googleMapController;
    @override
    void dispose() {
      googleMapController?.dispose();
      super.dispose();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          scrollGesturesEnabled: false,
          myLocationButtonEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },
          onTap: (initialCameraPosition) {
            print("teste");
          },
          markers: {
            Marker(
                markerId: const MarkerId('event'),
                position: pos,
                // TODO change snippet to street name
                infoWindow:
                    InfoWindow(title: widget.event.title, snippet: widget.event.description),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
          },
        ),
      ),
    );
  }

  Widget _CreateDoubleButton(String text, VoidCallback leftTap) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 170,
            height: 60,
            child: OutlinedButton(
              onPressed: leftTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                fixedSize: const Size(100, 50),
              ),
              child: Text(
                text,
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 170,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            event: widget.event,
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: const Size(100, 50),
              ),
              child: Text(
                'Chat',
                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showEvent() {
    return Column(
      children: [
        Expanded(
            child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                EventCard(
                  event: widget.event,
                  showDescription: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                _getGoogleMap(widget.event),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )),
        const SizedBox(height: 10),
        _getButtons(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget showParticipants() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OthersProfileScreen(user: participants[index])),
                  );
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (participants[index].urlProfileImage == "")
                              Icon(
                                Icons.account_circle,
                                size: 60,
                                color: Theme.of(context).colorScheme.secondary,
                              )
                            else
                              ClipOval(
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  participants[index].urlProfileImage,
                                  width: 60.0,
                                  height: 60.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (index == 0)
                              Positioned(
                                bottom: -2,
                                right: -20,
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 1.5),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary, // Color for the border
                                        width: 1, // Width of the border
                                      ),
                                    ),
                                    child: Text(
                                      'Owner',
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSecondary),
                                    )),
                              ),
                          ],
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.onPrimary, // Color for the border
                                width: 1, // Width of the border
                              ),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              participants[index].username,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                      ],
                    )),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FireStoreMethods().eventExists(widget.event),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildPage(context);
          } else if (!snapshot.data!) {
            // Event does not exist
            WidgetsBinding.instance.addPostFrameCallback((_) {
              handleNoEvent();
            });
          }
          return _buildPage(context);
        });
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
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
                          Navigator.pop(context);
                        },
                        rightIcon: type == "owner" ? Icons.edit : null,
                        rightAction: type == "owner" ? navigateAndRefresh : () {},
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SlideBar(
                          leftText: "Event",
                          rightText: "Participants",
                          controller: _slideBarController,
                          onChange: _ToggleStates,
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          onPageChanged: (page) {
                            if (!jank) {
                              _slideBarController.toggle();
                            }
                            jank = false;
                          },
                          controller: _pageController,
                          children: [
                            showEvent(),
                            showParticipants(),
                          ],
                        ),
                      )
                    ],
                  )))
        ]));
  }
}
