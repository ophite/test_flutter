import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter_1/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel _userFromFirebaseUser(User user) {
    UserModel typedUser = user != null ? UserModel(uid: user.uid) : null;
    return typedUser;
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
}
