import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_first_flutter_1/state/app_state.dart';
import 'package:provider/provider.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;
  static const _initialPosition = LatLng(12.97, 77.58);
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // final appState = Provider.of<AppState>(context);
    return SafeArea(
      child: appState.initialPosition == null
          ? Container(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitRotatingCircle(
                      color: Colors.black,
                      size: 50.0,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: appState.locationServiceActive == false,
                  child: Text(
                    "Please enable location services!",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
              ],
            ))
          : Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      // target: LatLng(12.6567, -4.7676), zoom: 10.0),
                      target: appState.initialPosition,
                      zoom: 10.0),
                  onMapCreated: appState.onCreated,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  markers: appState.markers,
                  onCameraMove: appState.onCameraMove,
                  polylines: appState.polyLines,
                ),

                Visibility(
                  visible: appState.autoCompleteContainer == true,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 180, 15, 0),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: FutureBuilder(
                      future: appState.getCountries(),
                      initialData: [],
                      builder: (context, snapshot) {
                        return createCountriesListView(context, snapshot);
                      },
                    ),
                  ),
                ),

                Positioned(
                  top: 50.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: appState.locationController,
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, top: 5),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.black,
                          ),
                        ),
                        hintText: "pick up",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 105.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: appState.destinationController,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) {
                        // appState.autoCompleteContainer = false;
                        // appState.autoCompleteContainer = false;
                        appState.visibilityAutoComplete(false);
                        appState.sendRequest(value);
                        // appState.autoCompleteContainer = false;
                      },
                      onChanged: (value) {
                        appState.increment();
                        // appState.autoCompleteContainer = true;
                        if (appState.destinationController.text != null) {
                          appState.autoCompleteContainer = true;
                        } else {
                          appState.autoCompleteContainer = false;
                        }
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // appState.destinationControler.text="";
                            appState.clearDestination();
                            // GoogleMap
                          },
                        ),
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, top: 5),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.local_taxi,
                            color: Colors.black,
                          ),
                        ),
                        hintText: "destination?",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),

//        Positioned(
//          top: 40,
//          right: 10,
//          child: FloatingActionButton(onPressed: _onAddMarkerPressed,
//          tooltip: "aadd marker",
//          backgroundColor: black,
//          child: Icon(Icons.add_location, color: white,),
//          ),
//        )
              ],
            ),
    );
  }

  void onCreate(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void _onAddMarkerPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastPosition.toString()),
          position: _lastPosition,
          infoWindow: InfoWindow(title: "Remember here", snippet: "good place"),
          icon: BitmapDescriptor.defaultMarker));
    });
  }
}

Widget createCountriesListView(BuildContext context, AsyncSnapshot snapshot) {
  var values = snapshot.data;
  return ListView.builder(
    shrinkWrap: true,
    itemCount: values == null ? 0 : values.length,
    itemBuilder: (BuildContext context, int index) {
      final appState = Provider.of<AppState>(context);

      return GestureDetector(
        onTap: () {
          // setState(() {
          // selectedCountry = values[index].code;
          appState.selectedPlace = values[index].description;
          appState.sendRequest(values[index].description);
          appState.visibilityAutoComplete(false);
          // });

          appState.destinationController.text =
              appState.selectedPlace.toString();
          appState.sendRequest(appState.toString());
          //  appState.sendRequest(value);
          // print(values[index].code);
          print(appState.selectedPlace);
        },
        child: Column(
          children: <Widget>[
            new ListTile(
              title: Text(values[index].description),
            ),
            Divider(
              height: 2.0,
            ),
          ],
        ),
      );
    },
  );
}
