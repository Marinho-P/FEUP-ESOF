import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/model/event.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('Event.fromSnap', () {
    test('returns null when snapshot is null', () {
      var mockSnap = MockDocumentSnapshot();
      when(mockSnap.data()).thenReturn(null);

      var result = Event.fromSnap(mockSnap);
      expect(result, isNull);
    });

    test('creates a valid event when snapshot has all data', () {
      var mockSnap = MockDocumentSnapshot();
      when(mockSnap.data()).thenReturn({
        "title": "Concert",
        "description": "A great night out",
        "time": Timestamp.fromDate(DateTime(2021, 9, 1)),
        "location": const GeoPoint(41.178, 8.598),
        "enrolledUsers": ["user1", "user2"]
      });

      var result = Event.fromSnap(mockSnap);
      expect(result, isA<Event>());
      expect(result!.title, "Concert");
      expect(result.description, "A great night out");
      expect(result.time, DateTime(2021, 9, 1));
      expect(result.location.latitude, 41.178);
      expect(result.location.longitude, 8.598);
      expect(result.enrolledUsers, containsAll(["user1", "user2"]));
    });

    test('handles missing fields with defaults or errors', () {
      var mockSnap = MockDocumentSnapshot();
      when(mockSnap.data()).thenReturn({
        "title": "Incomplete Event",
        "time": Timestamp.fromDate(DateTime(2024, 4, 14)),
      });

      var result = Event.fromSnap(mockSnap);
      expect(result, isA<Event>());
      expect(result!.title, "Incomplete Event");
      expect(result.description, ''); // Default value
      // Testing default or error for missing required fields like `location` can be complex
      expect(result.enrolledUsers, isEmpty); // Default to empty list
    });
  });
}
