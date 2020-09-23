import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_flutter_1/requests/google_maps_requests.dart';
import 'package:my_first_flutter_1/services/log.service.dart';

class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;

  bool locationServiceActive = true;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapsServices get googleMapsServices => _googleMapsServices;

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;

  GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  //for autocomplete
  List<SuggestedPlaces> _autoComplete;
  String selectedPlace = "sm";
  bool autoCompleteContainer = false;

  AppState() {
    logger.i(">>>>>>> AppState.constructor");
    _getUserLocation();
    _loadingInitialPosition();
  }

  void increment() async {
    print(">>>>>>> AppState.increment");
// _autoComplete +=1;
    // _autoComplete += "blah " ;

    _autoComplete = await getCountries();

    notifyListeners();
  }

  void clearDestination() {
    _markers.clear();
    _polyLines.clear();
    destinationController.clear();
  }

  void visibilityAutoComplete(bool visibleAutoComplete) {
    autoCompleteContainer = visibleAutoComplete;
    notifyListeners();
  }

  Future<List<SuggestedPlaces>> getCountries() async {
    // final response = await http .get('https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=AIzaSyB8jxZ33qr3HXTSKgXqx0mXbzQWzLjnfLU&input=${destinationController.text}');
    // The location is filter for suggestion is restricted for 50km with center at olongapo city hall as LatLng
    final response = await http.get(
        'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=${apiKey}&location=14.842299, 120.287810&radius=1000&input=${destinationController.text}');

    if (response.statusCode == 200) {
      var parsedPlacesList = json.decode(response.body);

      List<SuggestedPlaces> suggestedPlaces = List<SuggestedPlaces>();

      parsedPlacesList["predictions"].forEach((suggestedPlace) {
        suggestedPlaces.add(SuggestedPlaces.fromJSON(suggestedPlace));
      });

      return suggestedPlaces;
    } else {
      throw Exception('Failed to load');
    }
  }

// ! TO GET THE USERS LOCATION
  void _getUserLocation() async {
    logger.i('_getUserLocation');
    LocationPermission permission = await checkPermission();

    bool _isLocationServiceEnabled = await isLocationServiceEnabled();
    if (!_isLocationServiceEnabled) {
      await openAppSettings();
      await openLocationSettings();
    }

    Position position = await getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    locationController.text = placemarks[0].name;

    _initialPosition = LatLng(position.latitude, position.longitude);

    notifyListeners();

    logger.i("initial position is : ${_initialPosition.toString()}");
  }

  // void _getUserLocation() async {
  //   logger.w('1>>>>>>>>>>>>>>>> position:');
  //   logger.i("_getUserLocation =========- ");
  //   GeolocationStatus geolocationStatus =
  //   await Geolocator().checkGeolocationPermissionStatus();
  //   if (geolocationStatus == GeolocationStatus.granted) {
  //     logger.i('>>>> geolocationStatus:', geolocationStatus);
  //   }
  //   Position position = await Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //
  //   logger.w('2>>>>>> position:', position);
  //
  //   List<Placemark> placemark = await Geolocator()
  //       .placemarkFromCoordinates(position.latitude, position.longitude);
  //   logger.i(">>>>placemark:", placemark.toString());
  //   _initialPosition = LatLng(position.latitude, position.longitude);
  //   print(
  //       "the latitude is: ${position.longitude} and th longitude is: ${position.longitude} ");
  //   print("initial position is : ${_initialPosition.toString()}");
  //   locationController.text = placemark[0].name;
  //   notifyListeners();
  // }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.black));
    notifyListeners();
  }

  // ! ADD A MARKER ON THE MAO
  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  // ! CREATE LAGLNG LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  // ! SEND REQUEST
  void sendRequest(String intendedLocation) async {
    List<Location> locations = await locationFromAddress(intendedLocation);
    // List<Placemark> placemarks = await placemarkFromCoordinates(
    //     locations[0].latitude, locations[0].longitude);
    LatLng destination = LatLng(locations[0].latitude, locations[0].longitude);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    _addMarker(destination, intendedLocation);
    createRoute(route);
    notifyListeners();
  }

  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

//  LOADING INITIAL POSITION
  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }
}

class SuggestedPlaces {
  String description;

  SuggestedPlaces({
    this.description,
  });

  factory SuggestedPlaces.fromJSON(Map<String, dynamic> json) {
    return SuggestedPlaces(
      description: json['description'],
    );
  }
}
