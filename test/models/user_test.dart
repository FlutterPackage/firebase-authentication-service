import 'package:firebase_authentication_service/firebase_authentication_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    const id = 'id';
    const email = 'email';

    test('uses value equality', () {
      expect(
        User(email: email, id: id, name: null, photo: null),
        User(email: email, id: id, name: null, photo: null),
      );
    });

    test('isEmpty returns true for empty user', () {
      expect(User.empty.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty user', () {
      final user = User(email: email, id: id, name: null, photo: null);
      expect(user.isEmpty, isFalse);
    });

    test('isNotEmpty returns false for empty user', () {
      expect(User.empty.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty user', () {
      final user = User(email: email, id: id, name: null, photo: null);
      expect(user.isNotEmpty, isTrue);
    });
  });
}
