import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/model/user.dart';

// Create a Mock class for DocumentSnapshot
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('User.fromSnap', () {
    test('returns null when snapshot is null', () {
      var mockSnap = MockDocumentSnapshot();
      when(mockSnap.data()).thenReturn(null);

      var result = User.fromSnap(mockSnap);
      expect(result, isNull);
    });

    test('returns a valid user when snapshot has data', () {
      var mockSnap = MockDocumentSnapshot();
      when(mockSnap.data()).thenReturn({
        "username": "JohnDoe",
        "uid": "12345",
        "email": "johndoe@example.com",
        "followingEvents": ["event1", "event2"]
      });

      var result = User.fromSnap(mockSnap);
      expect(result, isA<User>());
      expect(result!.username, equals("JohnDoe"));
      expect(result.uid, equals("12345"));
      expect(result.email, equals("johndoe@example.com"));
      expect(result.followingEvents, containsAll(["event1", "event2"]));
    });

  });
}
