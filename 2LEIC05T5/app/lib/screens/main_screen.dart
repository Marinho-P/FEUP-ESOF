import 'dart:math';

import 'package:app/resources/notification_methods.dart';
import 'package:app/screens/create_event_screen.dart';
import 'package:app/screens/others_profile_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:app/widgets/filter_menu.dart';

import 'package:app/widgets/switch_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/screens/sign_in_screen.dart';
import 'package:app/resources/firestore_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/auth_methods.dart';
import 'package:app/model/event.dart';
import 'package:app/widgets/event_card.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:location/location.dart';

class MainScreen extends StatefulWidget {
  final Function? function;
  const MainScreen({
    super.key,
    this.function,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late bool notificationsEnabled;
  bool isLightMode = false;
  List<Event> events = [];
  bool isLoading = true;
  bool showingAllEvents = true;
  String searchText = '';
  String selectedFilter = 'None';
  GeoPoint userLocation = const GeoPoint(0, 0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLightMode = Provider.of<ThemeProvider>(context, listen: false).seeMode() == 'light';
      // UI-related code here
      loadEvents();
      getNotificationStatus().then((value) => setState(() {
        notificationsEnabled = value;
      }));
      if (widget.function != null){
        widget.function!();
      }
    });
  }
  Future<bool> getNotificationStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("Notifications") ?? false;
  }

  Future<void> loadEvents() async {
    try {
      List<Event> fetchedEvents;
      if (showingAllEvents) {
        fetchedEvents = await FireStoreMethods().getFirstTenEvents();
      } else {
        fetchedEvents = await FireStoreMethods().getFollowingEvents();
      }

      if (searchText.isNotEmpty) {
        fetchedEvents = fetchedEvents.where((event) {
          // Adjust the condition based on how your Event class is structured
          return event.title.toLowerCase().contains(searchText.toLowerCase()) ||
              event.description
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
        }).toList();
      }

      setState(() {
        events = fetchedEvents;
        isLoading = false;
      });
      sortEvents();
    } catch (e) {
      print("An error occurred while loading events: $e");
    }
  }

  double calculateDistance(GeoPoint start, GeoPoint end) {
    print("Start Location: ${start.latitude}, ${start.longitude}");
    print("End Location: ${end.latitude}, ${end.longitude}");

    var p = 0.017453292519943295;
    var a = 0.5 - cos((end.latitude - start.latitude) * p)/2 +
        cos(start.latitude * p) * cos(end.latitude * p) *
            (1 - cos((end.longitude - start.longitude) * p))/2;
    var distance = 12742 * asin(sqrt(a));
    print("Distance Calculated: $distance km");
    return distance;
  }


  void sortEvents() {
    List<Event> sortedEvents = List.from(events);  // Make a copy if mutation is not desired directly

    if (selectedFilter == 'Nearest') {
      sortedEvents.sort((a, b) => calculateDistance(userLocation, a.location).compareTo(calculateDistance(userLocation, b.location)));
    } else if (selectedFilter == 'Upcoming') {
      sortedEvents.sort((a, b) => a.time.compareTo(b.time));
    }

    setState(() {
      events = sortedEvents;  // Update the events list with the sorted list
    });
  }

  Future<GeoPoint> getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return const GeoPoint(0, 0); // Default location
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return const GeoPoint(0, 0); // Default location
      }
    }

    locationData = await location.getLocation();
    return GeoPoint(locationData.latitude!, locationData.longitude!);
  }

  Future<void> _refreshEvents() async {
    await loadEvents();
  }

  Future _displayBottomSheet(){
    return showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.primary,
        builder: (BuildContext context) {
          return customEllipsesMenu(context);
        });
  }

  Widget customEllipsesMenu(BuildContext context) {

    Color originalColor = Theme.of(context).colorScheme.primary;

    // Darken the color by 20%
    Color darkerColor = Color.fromRGBO(
      (originalColor.red * 0.8).round(),
      (originalColor.green * 0.8).round(),
      (originalColor.blue * 0.8).round(),
      1,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 22.0),
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(20.0),topLeft: Radius.circular(20.0)),color: Theme.of(context).colorScheme.primary),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                       Icon(
                        Icons.account_circle,
                        size: 58,
                        color: Theme.of(context).colorScheme.secondary,
                      ), // Your icon
                      const SizedBox(width: 50.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 80.0),
                          decoration: BoxDecoration(
                            color: darkerColor,
                            border: Border.all(
                              color: Colors.black, // Choose your border color here
                              width: 1.0, // Choose the border width here
                            ),
                            borderRadius:
                            BorderRadius.circular(30.0), // Choose border radius
                          ),
                          child: const Text(
                            'Profile', // Your text
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ), // Distance between icon and text
                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      SwitchButton(
                        initialValue: isLightMode,
                        distance: 100.0,
                        text: "Theme",
                        onChanged: (value) {
                          Provider.of<ThemeProvider>(context,listen:false).toggleTheme();
                          setState(() {
                            isLightMode = !isLightMode;
                          });
                        },
                        buildIcon: (isOn) {
                          return isOn
                              ?  Icon(
                            Icons.wb_sunny, // Sun icon
                            size: 58,
                            color: Theme.of(context).colorScheme.secondary,
                          )
                              :  Icon(
                            Icons.nightlight_round, // Moon icon
                            size: 58,
                            color: Theme.of(context).colorScheme.secondary,
                          );
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Icon(Icons.notifications,size: 58,color: Theme.of(context).colorScheme.secondary,), // Your icon
                      SizedBox(width: 40.0),
                      Text(
                        'Notifications', // Your text
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                      SwitchButton(initialValue: notificationsEnabled,distance: 50.0,text: "", onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                        NotificationMethods().setNotifications(value);
                        if(value && !(NotificationMethods().areNotificationsInit())){
                          NotificationMethods().initNotifications();
                        }
                      },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0,),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                       Icon(
                        Icons.logout,
                        size: 58,
                        color: Theme.of(context).colorScheme.secondary,
                      ), // Your icon
                      const SizedBox(width: 50.0),
                      GestureDetector(
                        onTap: () async {
                            await AuthMethods().signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (route) => false,
                            );
                        },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 80.0),
                            decoration: BoxDecoration(
                              color: darkerColor,
                              border: Border.all(
                                color: Colors.black, // Choose your border color here
                                width: 1.0, // Choose the border width here
                              ),
                              borderRadius:
                              BorderRadius.circular(30.0), // Choose border radius
                            ),
                            child: const Text(
                              'Logout', // Your text
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
          ),
          ),
        ],
      ),
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomAppBar(
                      title: 'CleanCity',
                      leftIcon: CupertinoIcons.plus,
                      leftAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateEventScreen(event: null)),
                        );
                      },
                      rightIcon: CupertinoIcons.ellipsis,
                      rightAction: () async {
                        _displayBottomSheet();
                      }),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AnimatedToggleSwitch<int>.size(
                      textDirection: TextDirection.rtl,
                      current: showingAllEvents ? 1 : 0,
                      values: const [0, 1],
                      indicatorSize: const Size.fromWidth(200),
                      borderWidth: 1.0,
                      iconOpacity: 0.9,
                      selectedIconScale: 1.0,
                      height: 50,
                      iconAnimationType: AnimationType.onHover,
                      styleAnimationType: AnimationType.onHover,
                      style: ToggleStyle(
                        borderColor: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20.0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        indicatorColor: Theme.of(context).colorScheme.secondary,
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      ),
                      customIconBuilder: (context, local, global) {
                        final labels = ['Following', 'All events'];
                        final text = labels[local.index];
                        return Center(
                            child: Text(text,
                                style: TextStyle(
                                    color: Color.lerp(Theme.of(context).colorScheme.onPrimary,
                                        Theme.of(context).colorScheme.onSecondary, local.animationValue))));
                      },
                      onChanged: (i) {
                        setState(() {
                          showingAllEvents = i == 1;
                        });
                        _refreshEvents();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search events',

                                fillColor: Theme.of(context).colorScheme.primary,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                searchText = value;
                                _refreshEvents();
                              },
                              style: const TextStyle(height: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                            decoration: BoxDecoration(

                              color: Theme.of(context).colorScheme.primary,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 0.7,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: FilterMenu(
                              onChangedFilter: (value) async {
                                if (value == 'Nearest') {
                                  GeoPoint currentLocation = await getCurrentLocation();
                                  setState(() {
                                    userLocation = currentLocation;
                                    selectedFilter = value;
                                  });
                                } else {
                                  setState(() {
                                    selectedFilter = value;
                                  });
                                }
                                sortEvents();
                              },
                            )

                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshEvents,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return EventCard(
                            event: events[index],
                            showDescription: false,
                            refreshEvents: _refreshEvents,
                          );
                        },
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
