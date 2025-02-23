import 'package:firebase_auth/firebase_auth.dart';

class PilluAuthRepository {
  PilluAuthRepository({final FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  final FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
