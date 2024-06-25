import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eid;
  final String title;
  final String description;
  final DateTime time;
  final String duration;
  final GeoPoint location; // We will use with GoogleMaps
  final String locationName;
  final List<String> enrolledUsers;
  final String urlImage;

  const Event({
    required this.eid,
    required this.title,
    required this.description,
    required this.time,
    required this.duration,
    required this.location,
    required this.locationName,
    required this.enrolledUsers,
    required this.urlImage,
  });

  static Event? fromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    var snapshot = snap.data();
    if (snapshot == null) {
      return null;
    }

    // Default value if none provided
    GeoPoint location = const GeoPoint(0, 0);
    if (snapshot['location'] != null) {
      location = snapshot['location'] as GeoPoint;
    }

    return Event(
      eid: snapshot["eid"] ?? '',
      title: snapshot["title"] ?? '',
      description: snapshot["description"] ?? '',
      time: (snapshot['time'] as Timestamp).toDate(),
      duration: snapshot['duration'] ?? '',
      location: location,
      locationName: snapshot['locationName'] ?? '',
      enrolledUsers: List<String>.from(snapshot['enrolledUsers'] ?? []),
      urlImage: snapshot['urlImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "eid": eid,
        "title": title,
        "description": description,
        "time": Timestamp.fromDate(time),
        "duration": duration,
        "location": location,
        "locationName" : locationName,
        "enrolledUsers": enrolledUsers,
        "urlImage": urlImage,
      };

  @override
  String toString() {
    return 'Event(eid: $eid, title: $title, description: $description, time: $time, duration: $duration, location: ${location.latitude}, ${location.longitude}, locationName: $locationName, enrolledUsers: $enrolledUsers)';
  }


  Duration parseDuration() {
    List<String> parts = duration.split(':');
    return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2].split('.')[0]));
  }

}
