import 'package:firebase_authentication_service/firebase_authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const _mockFirebaseUserUid = 'id';
const _mockFirebaseUserEmail = 'email';

mixin LegacyEquality {
  @override
  bool operator ==(dynamic other) => false;

  @override
  int get hashCode => 0;
}

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock
    with LegacyEquality
    implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFacebookAuth extends Mock implements FacebookAuth {}

class MockFacebookLoginResult extends Mock implements LoginResult {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp();

  const email = 'test@gmail.com';
  const password = '12345';
  const code = 'code';
  const newPassword = 'newPassword';
  const token = 'token';
  const accessToken = 'access-token';
  const idToken = 'id-token';
  const user = User(
    id: _mockFirebaseUserUid,
    email: _mockFirebaseUserEmail,
    name: null,
    photo: null,
  );

  group('FirebaseAuthenticationService', () {
    late firebase_auth.FirebaseAuth firebaseAuth;
    late FirebaseAuthenticationService authenticationService;
    late GoogleSignIn googleSignIn;
    late FacebookAuth facebookAuth;

    setUpAll(() {
      registerFallbackValue<firebase_auth.AuthCredential>(FakeAuthCredential());
    });

    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      googleSignIn = MockGoogleSignIn();
      facebookAuth = MockFacebookAuth();
      authenticationService = FirebaseAuthenticationService(
        firebaseAuth: firebaseAuth,
        googleSignIn: googleSignIn,
        facebookAuth: facebookAuth,
      );
    });

    test('creates FirebaseAuth instance internally when not injected', () {
      expect(() => FirebaseAuthenticationService(), isNot(throwsException));
    });

    group('user', () {
      test('emits User.empty when firebase user is null', () async {
        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));
        await expectLater(
          authenticationService.user,
          emitsInOrder(const <User>[User.empty]),
        );
      });

      test('emits User when firebase user is not null', () async {
        final firebaseUser = MockFirebaseUser();
        when(() => firebaseUser.uid).thenReturn(_mockFirebaseUserUid);
        when(() => firebaseUser.email).thenReturn(_mockFirebaseUserEmail);
        when(() => firebaseUser.photoURL).thenReturn(null);
        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(firebaseUser));
        await expectLater(
          authenticationService.user,
          emitsInOrder(const <User>[user]),
        );
      });
    });

    group('currentUser', () {
      test('emits User.empty when current user is null', () async {
        when(() => firebaseAuth.currentUser).thenAnswer((_) => null);
        await expectLater(authenticationService.currentUser,
            emitsInOrder(const <User>[User.empty]));
      });

      test('emits User when current user is not null', () async {
        final firebaseUser = MockFirebaseUser();
        when(() => firebaseAuth.currentUser!.uid)
            .thenReturn(_mockFirebaseUserUid);
        when(() => firebaseAuth.currentUser!.email)
            .thenReturn(_mockFirebaseUserEmail);
        when(() => firebaseAuth.currentUser!.photoURL).thenReturn(null);
        when(() => firebaseAuth.currentUser).thenAnswer((_) => firebaseUser);
        await expectLater(authenticationService.currentUser,
            emitsInOrder(const <User>[user]));
      });
    });

    group('createUserWithEmailAndPassword', () {
      setUp(() {
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: 'email',
            password: 'password',
          ),
        ).thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls createUserWithEmailAndPassword', () async {
        await authenticationService.createUserWithEmailAndPassword(
            email: email, password: password);
        verify(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test('succeeds when createUserWithEmailAndPassword succeeds', () async {
        expect(
          authenticationService.createUserWithEmailAndPassword(
              email: email, password: password),
          completes,
        );
      });

      test('throws SignUpFailure when createUserWithEmailAndPassword throws',
          () async {
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception());
        expect(
          authenticationService.createUserWithEmailAndPassword(
              email: email, password: password),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('signInAnonymously', () {
      setUp(() {
        when(() => firebaseAuth.signInAnonymously())
            .thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signInAnonymously', () async {
        await authenticationService.signInAnonymously();
        verify(
          () => firebaseAuth.signInAnonymously(),
        ).called(1);
      });

      test('succeeds when signInAnonymously succeeds', () async {
        expect(
          authenticationService.signInAnonymously(),
          completes,
        );
      });

      test(
          'throws FirebaseFailure '
          'when signInAnonymously throws', () async {
        when(
          () => firebaseAuth.signInAnonymously(),
        ).thenThrow(Exception());
        expect(
          authenticationService.signInAnonymously(),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('signInWithEmailAndPassword', () {
      setUp(() {
        when(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: 'email',
            password: 'password',
          ),
        ).thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signInWithEmailAndPassword', () async {
        await authenticationService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        verify(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test('succeeds when signInWithEmailAndPassword succeeds', () async {
        expect(
          authenticationService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          completes,
        );
      });

      test(
          'throws FirebaseFailure '
          'when signInWithEmailAndPassword throws', () async {
        when(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception());
        expect(
          authenticationService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('signInWithCustomToken', () {
      setUp(() {
        when(
          () => firebaseAuth.signInWithCustomToken('token'),
        ).thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signInWithCustomToken', () async {
        await authenticationService.signInWithCustomToken(token: token);
        verify(
          () => firebaseAuth.signInWithCustomToken(token),
        ).called(1);
      });

      test('succeeds when signInWithCustomToken succeeds', () async {
        expect(
          authenticationService.signInWithCustomToken(token: token),
          completes,
        );
      });

      test(
          'throws FirebaseFailure '
          'when signInWithCustomToken throws', () async {
        when(
          () => firebaseAuth.signInWithCustomToken(any(named: 'token')),
        ).thenThrow(Exception());
        expect(
          authenticationService.signInWithCustomToken(token: token),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('signInWithGoogle', () {
      setUp(() {
        final googleSignInAuthentication = MockGoogleSignInAuthentication();
        final googleSignInAccount = MockGoogleSignInAccount();
        when(() => googleSignInAuthentication.accessToken)
            .thenReturn(accessToken);
        when(() => googleSignInAuthentication.idToken).thenReturn(idToken);
        when(() => googleSignInAccount.authentication)
            .thenAnswer((_) async => googleSignInAuthentication);
        when(() => googleSignIn.signIn())
            .thenAnswer((_) async => googleSignInAccount);
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signIn authentication, and signInWithCredential', () async {
        await authenticationService.signInWithGoogle();
        verify(() => googleSignIn.signIn()).called(1);
        verify(() => firebaseAuth.signInWithCredential(any())).called(1);
      });

      test('succeeds when signIn succeeds', () {
        expect(authenticationService.signInWithGoogle(), completes);
      });

      test('throws LogInWithGoogleFailure when exception occurs', () async {
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenThrow(Exception());
        expect(
          authenticationService.signInWithGoogle(),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('signInWithFacebook', () {
      setUp(() {
        final facebookAccessToken = MockFacebookLoginResult();
        when(() => facebookAuth.login())
            .thenAnswer((_) async => facebookAccessToken);
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signIn authentication, and signInWithCredential', () async {
        await authenticationService.signInWithFacebook();
        verify(() => facebookAuth.login()).called(1);
        verify(() => firebaseAuth.signInWithCredential(any())).called(1);
      });

      test('succeeds when signIn succeeds', () {
        expect(authenticationService.signInWithFacebook(), completes);
      });

      test('throws LogInWithGoogleFailure when exception occurs', () async {
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenThrow(Exception());
        expect(
          authenticationService.signInWithFacebook(),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('signOut', () {
      test('calls signOut', () async {
        when(() => firebaseAuth.signOut()).thenAnswer((_) async => null);
        await authenticationService.signOut();
        verify(() => firebaseAuth.signOut()).called(1);
      });

      test('throws FirebaseFailure when signOut throws', () async {
        when(() => firebaseAuth.signOut()).thenThrow(Exception());
        expect(
          authenticationService.signOut(),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      setUp(() {
        when(
          () => firebaseAuth.sendPasswordResetEmail(
            email: 'email',
          ),
        ).thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls sendPasswordResetEmail', () async {
        await authenticationService.sendPasswordResetEmail(email: email);
        verify(
          () => firebaseAuth.sendPasswordResetEmail(
            email: email,
          ),
        ).called(1);
      });

      test('succeeds when sendPasswordResetEmail succeeds', () async {
        expect(
          authenticationService.sendPasswordResetEmail(email: email),
          completes,
        );
      });

      test(
          'throws FirebaseFailure '
          'when sendPasswordResetEmail throws', () async {
        when(
          () => firebaseAuth.sendPasswordResetEmail(
            email: any(named: 'email'),
          ),
        ).thenThrow(Exception());
        expect(
          authenticationService.sendPasswordResetEmail(
            email: email,
          ),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });

    group('confirmPasswordReset', () {
      setUp(() {
        when(
          () => firebaseAuth.confirmPasswordReset(
            code: 'code',
            newPassword: 'newPassword',
          ),
        ).thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls confirmPasswordReset', () async {
        await authenticationService.confirmPasswordReset(
          code: code,
          newPassword: newPassword,
        );
        verify(
          () => firebaseAuth.confirmPasswordReset(
            code: code,
            newPassword: newPassword,
          ),
        ).called(1);
      });

      test('succeeds when confirmPasswordReset succeeds', () async {
        expect(
          authenticationService.confirmPasswordReset(
            code: code,
            newPassword: newPassword,
          ),
          completes,
        );
      });

      test(
          'throws FirebaseFailure '
          'when confirmPasswordReset throws', () async {
        when(
          () => firebaseAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenThrow(Exception());
        expect(
          authenticationService.confirmPasswordReset(
            code: code,
            newPassword: newPassword,
          ),
          throwsA(isA<FirebaseFailure>()),
        );
      });
    });
  });
}
