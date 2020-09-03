import 'package:flutter/material.dart';
import 'package:my_first_flutter_1/models/user.dart';
import 'package:my_first_flutter_1/screens/home/home.dart';
import 'package:my_first_flutter_1/screens/login/login.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    if (user == null) {
      return Login();
    } else {
      return Home();
    }
  }
}
