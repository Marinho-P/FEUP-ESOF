import 'package:app/model/event.dart';
import 'package:app/main.dart';
import 'package:app/resources/auth_methods.dart';
import 'package:app/screens/chat_screen.dart';
import 'package:app/screens/event_details_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationMethods {
  final _messaging = FirebaseMessaging.instance;
  bool sendNotifications = true;
  bool init = false;
  bool areNotificationsInit() {
    return init;
  }

  bool areNotificationsEnabled() {
    return sendNotifications;
  }

  void setNotifications(bool) async {
    sendNotifications = bool;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Notifications', bool);
    print(sendNotifications);
  }

  static Future<void> showNotification({
    required final String title,
    required final String channelKey,
    required final String body,
    final String? summary,
    final String? img,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
  }) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1,
            channelKey: channelKey,
            title: title,
            body: body,
            actionType: actionType,
            notificationLayout: notificationLayout,
            summary: summary,
            category: category,
            largeIcon: img,
            payload: payload));
  }

  Future initNotifications() async {
    await _messaging.requestPermission();
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'event',
        channelName: 'Event Notifications',
        channelDescription: 'Notifies user of upcoming events',
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'chat',
        channelName: 'Event chat notifications',
        channelDescription: 'Notifies user of chat messages for events',
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ]);
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    await AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    init = true;
  }

  void addUserToEventNotifications(String eventId) async {
    await _messaging
        .subscribeToTopic("event_$eventId")
        .then((value) => print('Subscribed to event topic successfully'))
        .catchError((error) {
      print('Subscription to event topic failed: $error');
    });
  }

  Future<void> removeUserFromEventNotifications(String eventId) async {
    await _messaging
        .unsubscribeFromTopic("event_$eventId")
        .then((value) => print('Subscribed to event topic successfully'))
        .catchError((error) {
      print('Subscription to event topic failed: $error');
    });
  }
}

void handleMessage(RemoteMessage? message) {
  print("handling message");
  if (message == null || !NotificationMethods().areNotificationsEnabled())
    return;
  if (message.data["type"] == "event") {
    Map<String, String>? payload =
        message.data.map((key, value) => MapEntry(key, value.toString()));
    NotificationMethods.showNotification(
        title: "Upcoming Event",
        channelKey: "event",
        body: "${message.data["title"]} is about to start",
        img: message.data["urlImage"],
        payload: payload);
    return;
  }
  if (message.data["type"] == "chat" &&
      !(message.data["sent_by"] == FirebaseAuth.instance.currentUser?.uid)) {
    Map<String, String>? payload =
        message.data.map((key, value) => MapEntry(key, value.toString()));
    var notImg = (message.data['urlProfileImage'] == "") ? message.data['urlProfileImage'] : 'https://firebasestorage.googleapis.com/v0/b/esof2324-6e8a4.appspot.com/o/images%2FScreenshot_20240513_024543%20(1).png?alt=media&token=ad59237f-641c-4568-8272-5b7af78dde85';
    NotificationMethods.showNotification(
        title: message.data["username"],
        channelKey: 'chat',
        body: message.data["message"],
        img: notImg,
        payload: payload);
    return;
  }
}

Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  print("handling background message");
  if (message == null || !NotificationMethods().areNotificationsEnabled())
    return;
  if (message.data["type"] == "event") {
    Map<String, String>? payload =
    message.data.map((key, value) => MapEntry(key, value.toString()));
    NotificationMethods.showNotification(
        title: "Upcoming Event",
        channelKey: "event",
        body: "${message.data["title"]} is about to start",
        img: message.data["urlImage"],
        payload: payload);
    return;
  }
  if (message.data["type"] == "chat" &&
      !(message.data["sent_by"] == FirebaseAuth.instance.currentUser?.uid)) {
    Map<String, String>? payload =
    message.data.map((key, value) => MapEntry(key, value.toString()));
    var notImg = (message.data['urlProfileImage'] == "") ? message.data['urlProfileImage'] : 'https://firebasestorage.googleapis.com/v0/b/esof2324-6e8a4.appspot.com/o/images%2FScreenshot_20240513_024543%20(1).png?alt=media&token=ad59237f-641c-4568-8272-5b7af78dde85';
    NotificationMethods.showNotification(
        title: message.data["username"],
        channelKey: 'chat',
        body: message.data["message"],
        img: notImg,
        payload: payload);
    return;
  }
}

Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  print("on click");
  final payload = receivedAction.payload ?? {};
  if (payload["type"] == "event") {
    final location = payload['location']?.split(",");
    final loc = GeoPoint(double.parse(location![0]), double.parse(location[1]));
    final event = Event(
        eid: (payload["eid"]) ?? "error",
        title: payload['title'] ?? "error",
        description: payload['description'] ?? "",
        time: DateTime.parse(payload['time'] ?? "1974-03-20 00:00:00.000"),
        duration: payload['duration'] ?? "error",
        location: loc,
        locationName: payload['locationName'] ?? "error",
        enrolledUsers: payload['enrolledUsers']!.split(","),
        urlImage: payload["urlImage"] ?? "");
    MyApp.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (BuildContext context) => EventDetailsScreen(event: event)));
  }
  if(payload["type"] == "chat"){
    final location = payload['location']?.split(",");
    final loc = GeoPoint(double.parse(location![0]), double.parse(location[1]));
    final event = Event(
        eid: (payload["eid"]) ?? "error",
        title: payload['title'] ?? "error",
        description: payload['description'] ?? "",
        time: DateTime.parse(payload['time'] ?? "1974-03-20 00:00:00.000"),
        duration: payload['duration'] ?? "error",
        location: loc,
        locationName: payload['locationName'] ?? "error",
        enrolledUsers: payload['enrolledUsers']!.split(","),
        urlImage: payload["urlImage"] ?? "");
    MyApp.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (BuildContext context) => EventDetailsScreen(event: event)));
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (BuildContext context) => ChatScreen(event: event)));
  }
}
