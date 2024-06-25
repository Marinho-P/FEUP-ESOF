import 'package:cloud_firestore/cloud_firestore.dart';


class User {
  final String email;
  final String uid;
  final String username;
  final List<String> followingEvents;
  final String bio;

  int eventsParticipated;
  int eventsCreated;
  double trashCollected;
  final String urlProfileImage;



   User({
    required this.username,
    required this.uid,
    required this.email,
    required this.followingEvents,
    required this.bio,
    required this.eventsParticipated,
    required this.eventsCreated,
    required this.trashCollected,
    required this.urlProfileImage,
  });

  static User? fromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    var snapshot = snap.data();
    if (snapshot == null) {
      return null;
    }

    List<String> followingEvents = (snapshot["followingEvents"] as List<dynamic>)

      .map((event) => event.toString())
      .toList();


    return User(
      username: snapshot["username"] ?? 'Unknown', // Provide default value or handle null
      uid: snapshot["uid"] ?? '',
      email: snapshot["email"] ?? '',
      followingEvents: followingEvents,
      bio : snapshot["bio"] ?? '',
      eventsParticipated: snapshot["eventsParticipated"] ?? 0,
      eventsCreated: snapshot["eventsCreated"] ?? 0,
      trashCollected: snapshot["trashCollected"] ?? 0,
      urlProfileImage: snapshot["urlProfileImage"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "followingEvents": followingEvents,
    "bio": bio,
    "eventsParticipated" : eventsParticipated,
    "eventsCreated" : eventsCreated,
    "trashCollected" : trashCollected,
    "urlProfileImage" : urlProfileImage,
  };
}
