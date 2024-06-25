import 'package:app/model/event.dart' as model;
import 'package:app/model/user.dart' as model;
import 'package:app/resources/auth_methods.dart';
import 'package:app/resources/notification_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createEvent({
    required String title,
    required String description,
    required DateTime time,
    required Duration duration,
    required String location, // We will use with GoogleMaps
    required XFile? image,
  }) async {
    String res = "Some error Occurred";
    try {
      if (title.length < 4 && title.isNotEmpty) {
        res = "Title is too short";
      }  else if (title.isNotEmpty &&
          description.isNotEmpty &&
          duration.toString().isNotEmpty) {
        GeoPoint loc = await getLocationCoords(location);

        User? user = _auth.currentUser;

        DocumentReference newEventRef =
            await _firestore.collection('events').add({});
        List<String> enrolled = [user!.uid];
        String imageFinal = await uploadImage(image);

        model.Event event = model.Event(
          eid: newEventRef.id,
          title: title,
          description: description,
          time: time,
          duration: duration.toString(),
          enrolledUsers: enrolled,
          location: loc,
          locationName: location,
          urlImage: imageFinal,
        );

        await _firestore
            .collection('events')
            .doc(event.eid)
            .set(event.toJson());
        await _firestore.collection('users').doc(user.uid).update({
          'followingEvents': FieldValue.arrayUnion([event.eid])
        });

        res = "success";
        NotificationMethods().addUserToEventNotifications(event.eid);
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString(); // Consider more specific error handling
    }
    return res;
  }

  Future<String> editEvent(
      {required String eventId,
      required String title,
      required String description,
      required DateTime time,
      required Duration duration,
      required String location,
      required XFile? image,
      required String oldImageURL,
      required List<String> enrolled}) async {
    String res = "Some error Occurred";
    try {
      if (title.length < 4 && title.isNotEmpty) {
        res = "Title is too short";
      }  else if (title.isNotEmpty &&
          description.isNotEmpty &&
          duration.toString().isNotEmpty) {
        GeoPoint loc = await getLocationCoords(location);

        bool changeImage = true;
        if (oldImageURL != "") {
          XFile oldImage = XFile(oldImageURL);
          if (oldImage.path != image?.path) {
            StorageMethods().deleteFirestoreImages(oldImageURL);
          } else {
            // If they are the same there is no need to upload again
            changeImage = false;
          }
        }

        String imageFinal;
        if (image == null) {
          print("Image path is null");
          imageFinal = "";
        } else if (changeImage) {
          imageFinal = await uploadImage(image);
        } else {
          imageFinal = oldImageURL;
        }

        // Create the event object. If there's no new image uploaded, keep the old one.
        model.Event event = model.Event(
          eid: eventId,
          title: title,
          description: description,
          time: time,
          duration: duration.toString(),
          location: loc,
          locationName: location,
          urlImage: imageFinal,
          enrolledUsers: enrolled,
        );

        // Update the existing event document
        await _firestore
            .collection('events')
            .doc(event.eid)
            .update(event.toJson());
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString(); // Consider more specific error handling
    }
    return res;
  }

  Future<GeoPoint> getLocationCoords(String address) async {
    var location = await locationFromAddress(address);
    if (location.isEmpty) {
      throw Exception("Geocoding failed to get address coordinates");
    }
    return GeoPoint(location.first.latitude, location.first.longitude);
  }

  Future<String> uploadImage(XFile? imageFile) async {
    if (imageFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageReference.putFile(File(imageFile.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    }
    return "";
  }

  Future<void> deleteFirestoreImages(String imageUrl) async {
    String fileName = imageUrl.split('/').last.split('?').first.split('F').last;

    // Get a reference to the image in Firebase Storage
    final reference = FirebaseStorage.instance.ref().child('images/$fileName');

    // Delete the image
    await reference.delete();
  }

  Future<void> deleteProfileImage(String imageUrl) async {
    await deleteFirestoreImages(imageUrl);
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'urlProfileImage': ''});
  }



  Future<void> updateStatisticsAfterEvent(model.Event event,double trashCollected) async {
    bool isOwner = true;
    for (String userId in event.enrolledUsers) {
      model.User? user = await AuthMethods().getUserById(userId);
      if (user != null) {
        if(isOwner){
          user.eventsCreated+=1;
          isOwner = false;
        }
        user.eventsParticipated+=1;
        user.trashCollected+=trashCollected;
        await _firestore.collection('users').doc(userId).update({'trashCollected':user.trashCollected,'eventsCreated':user.eventsCreated,'eventsParticipated':user.eventsParticipated});
        print('User found: ${user.username}');
      } else {
        print('User not found for ID: $userId');
      }
    }
  }
}
