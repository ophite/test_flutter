import 'package:flutter/material.dart';
import 'package:my_first_flutter_1/screens/placePicker/models/pick_result.dart';
import 'package:my_first_flutter_1/services/auth.dart';

import 'others/place_picker.dart';

class PlacePickerPage extends StatefulWidget {
  @override
  _PlacePickerPageState createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<PlacePickerPage> {
  // Completer<GoogleMapController> _controller = Completer();
  final _auth = AuthService();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Place picker'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('logout'))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: RaisedButton(
          child: PlacePicker(
            apiKey:
                "AIzaSyAGhEKlK0bWjqfDvPHE19uyd2kObvgXsyU", // Put YOUR OWN KEY here.
            onPlacePicked: (PickResult result) {
              print(result.adrAddress);
              Navigator.of(context).pop();
            },
            // initialPosition: HomePage.kInitialPosition,
            useCurrentLocation: true,
          ),
        ),
      ),
    );
  }
}
