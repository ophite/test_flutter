import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_1/models/user.dart';
import 'package:my_first_flutter_1/screens/wrapper.dart';
import 'package:my_first_flutter_1/services/auth.dart';
import 'package:my_first_flutter_1/state/app_state.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: new AppState(),
      ),
      StreamProvider<UserModel>.value(
          value: AuthService().user,
          child: MaterialApp(
            home: Wrapper(),
          )),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Wrapper());
  }
}
