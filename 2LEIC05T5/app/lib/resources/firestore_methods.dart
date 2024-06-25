import 'package:app/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:app/model/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/model/user.dart' as model;

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<List<Event>> getFirstTenEvents() async {
    final now = DateTime.now();
    QuerySnapshot querySnapshot =
        await _firestore.collection('events').where('time',isGreaterThan: now).limit(10).get();

    List<Event> events = querySnapshot.docs
        .map((doc) {
          return Event.fromSnap(doc as DocumentSnapshot<Map<String, dynamic>>);
        })
        .where((event) => event != null)
        .cast<Event>()
        .toList();

    return events;
  }

  Future<Event?> getEventById(String eventId) async {
    var doc = await _firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return Event.fromSnap(doc);
    }
    return null;
  }

  Future<List<Event>> getFollowingEvents() async {
    auth.User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("No current user found.");
      return [];
    }

    DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    List<dynamic> followingEventsDynamic =
        userDocSnapshot.data()?['followingEvents'] as List<dynamic>? ?? [];
    List<String> followingEvents =
        followingEventsDynamic.whereType<String>().toList();

    if (followingEvents.isEmpty) {
      print(
          "No following events found or the user is not following any events.");
      print(currentUser.uid);
      return [];
    }

    List<Event> events = [];
    for (String eventId in followingEvents) {
      try {

        DocumentSnapshot<Map<String, dynamic>> eventDocSnapshot =
            await _firestore.collection('events').doc(eventId).get();

        Event? event = Event.fromSnap(eventDocSnapshot);
        if (event != null) {
          events.add(event);
        } else {
          print("Failed to load event for ID: $eventId");
        }
      } catch (e) {
        print("Error fetching event $eventId: $e");
      }
    }

    return events;
  }

  Future<void> joinEvent(Event event) async {
    auth.User? user = _auth.currentUser;

    // Add User to event
    _firestore.collection('events').doc(event.eid).update({
      'enrolledUsers': FieldValue.arrayUnion([user?.uid])
    }).then((_) {
      print('New value added to enrolledUsers successfully.');
    }).catchError((error) {
      print('Failed to add new value to enrolledUsers: $error');
    });

    // Add event to user

    _firestore.collection('users').doc(user?.uid).update({
      'followingEvents': FieldValue.arrayUnion([event.eid])
    }).then((_) {
      print('New value added to followingEvents successfully.');
    }).catchError((error) {
      print('Failed to add new value to followingEvents: $error');
    });
  }

  Future<model.User?> getUserData(String userId) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot<Object?> snapshot = await userRef.get();

    if (snapshot.exists) {
      DocumentSnapshot<Map<String, dynamic>> mapSnapshot =
          snapshot as DocumentSnapshot<Map<String, dynamic>>;
      return model.User.fromSnap(mapSnapshot);
    } else {
      return null;
    }
  }

  auth.User? getUser() {
    return _auth.currentUser;
  }


    Future<void> getParticipantInfo(List<String> userIds,
        List<model.User> users) async {
      for (String userId in userIds) {
        try {
          DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
              await _firestore.collection('users').doc(userId).get();

          model.User? user = model.User.fromSnap(userDocSnapshot);

          if (user != null) {
            users.add(user);
          } else {
            print("Failed to load user for ID: $userId");
          }
        } catch (e) {
          print("Error fetching user $userId: $e");
        }
    }
  }

  Future<void> removeEvent(Event event) async {
    try {
      StorageMethods().deleteFirestoreImages(event.urlImage);

      final eventRef = _firestore.collection('events').doc(event.eid);

      final eventDoc = await eventRef.get(); // Retrieve the event document

      if (eventDoc.exists) {
        final eventDetails = eventDoc.data();

        if (eventDetails!.containsKey('enrolledUsers')) {
          final List<String> eventIds =
              List<String>.from(eventDetails['enrolledUsers']);

          await _firestore.runTransaction((transaction) async {
            for (final eventId in eventIds) {
              final participantRef = _firestore.collection('users').doc(
                  eventId); // Assuming 'users' is the collection containing user documents

              final participantDoc = await participantRef.get();
              if (participantDoc.exists) {
                final participantData = participantDoc.data();

                final List<String> followingEvents =
                    List<String>.from(participantData?['followingEvents']);
                followingEvents.remove(event.eid);

                transaction.update(
                    participantRef, {'followingEvents': followingEvents});
              }
            }
            transaction.delete(eventRef);
          });

          print('Participants updated and event deleted successfully');
        } else {
          print('No enrolled users found for the event.');
        }
      } else {
        print('Event with ID ${event.eid} does not exist.');
      }
    } catch (e) {
      print('Error updating participants and deleting event: $e');
    }
  }

  void exitEvent(Event event) async {
    final user = getUser();

    // Eliminate Event from User list
    final userRef = _firestore.collection('users').doc(user?.uid);
    final userDoc = await userRef.get();
    final List<String> followingEvents =
        List<String>.from(userDoc.data()?['followingEvents']);
    followingEvents.remove(event.eid);

    userRef.update({'followingEvents': followingEvents});

    // Eliminate User from Event list

    final eventRef = _firestore.collection('events').doc(event.eid);
    final eventDoc = await eventRef.get();
    final List<String> enrolledUsers =
        List<String>.from(eventDoc.data()?['enrolledUsers']);
    enrolledUsers.remove(user?.uid);

    eventRef.update({'enrolledUsers': enrolledUsers});
  }

  Future<bool> eventExists(Event event) async {
    final eventDoc = await _firestore.collection('events').doc(event.eid).get();
    return (eventDoc.exists);
  }

  Future<void> addMessageToChat(Event event, String messageContent) async {
    final messageData = {
      'message': messageContent,
      'sent_by': FirebaseAuth.instance.currentUser!.uid,
      'datetime': Timestamp.now(),
    };
    FirebaseFirestore.instance
        .collection('events')
        .doc(event.eid)
        .collection('messages')
        .add(messageData);
  }

  Stream<QuerySnapshot> getEventMessages(Event event) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(event.eid)
        .collection('messages')
        .orderBy('datetime', descending: true)
        .snapshots();
  }
}
