import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_authentication_service/firebase_authentication_service.dart';

/// Thrown error if a failure occurs.
class FirebaseFailure implements Exception {}

/// Service for firebase user authentication
class FirebaseAuthenticationService {
  FirebaseAuthenticationService({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;

  /// Stream of [User] which will return current user when the authentication state changes.
  /// Return [User.empty] if the user is not authenticated.
  Stream<User> get user => _firebaseAuth
      .authStateChanges()
      .map((user) => user == null ? User.empty : user.toUser);

  /// Defaults to [User.empty] if the user is empty.
  User get currentUser => _firebaseAuth.currentUser?.toUser ?? User.empty;

  /// Creates a new user with the provided [email] and [password].
  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on Exception {
      throw FirebaseFailure();
    }
  }

  /// Signs in anonymously.
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on Exception {
      throw FirebaseFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on Exception {
      throw FirebaseFailure();
    }
  }

  /// Signs in with the provided [token].
  Future<void> signInWithCustomToken({required String token}) async {
    try {
      await _firebaseAuth.signInWithCustomToken(token);
    } on Exception {
      throw FirebaseFailure();
    }
  }

  /// Signs out the current user which will return
  /// [User.empty] from the [user] Stream.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on Exception {
      throw FirebaseFailure();
    }
  }

  /// Send password reset email with the provided [email].
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on Exception {
      throw FirebaseFailure();
    }
  }

  /// Password reset with the provided [code] and [newPassword].
  Future<void> confirmPasswordReset(
      {required String code, required String newPassword}) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
          code: code, newPassword: newPassword);
    } on Exception {
      throw FirebaseFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
