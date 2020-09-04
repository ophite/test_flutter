import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter_1/models/user.dart';
import 'package:my_first_flutter_1/models/user_settings.dart';
import 'package:my_first_flutter_1/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel _userFromFirebaseUser(User user) {
    UserModel typedUser = user != null ? UserModel(uid: user.uid) : null;
    return typedUser;
  }

  Stream<UserModel> get user {
    // return _auth.authStateChanges().map( User => );
    return _auth
        .authStateChanges()
        .map((User user) => _userFromFirebaseUser(user));
  }

  Future signInAnon() async {
    try {
      var result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('signout error ${e.toString()}');
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      //create a new document with user uid
      UserSettings userSettings = UserSettings(name: name, uid: user.uid);
      await DatabaseService(uid: user.uid).updateUserSettings(userSettings);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
