import 'dart:async';

import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/push_notification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistant/assistant_methods.dart';
import '../assistant/black_theme_google_map.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;

  final Completer<GoogleMapController> _controllers = Completer();

  @override
  void dispose() {
    newGoogleMapController?.dispose();
    super.dispose();
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
    // else {
    //   SystemNavigator.pop();
    // }
  }

  locateDriverPosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = currentPosition;
    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            driverCurrentPosition!, context);
    print("this is your address = ${humanReadableAddress}");
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;
  double bottomPaddingofMap = 0;

  readCurrentDriverInformation() async {
    currentFirebaseUser = fAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap) {
      if(snap.snapshot.value != null) {
        onlineDriverData?.id =
        (snap.snapshot.value as Map)["id"];
        onlineDriverData?.name =
        (snap.snapshot.value as Map)["name"];
        onlineDriverData?.phone =
        (snap.snapshot.value as Map)["phone"];
        onlineDriverData?.email =
        (snap.snapshot.value as Map)["email"];
        onlineDriverData?.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData?.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData?.car_model = (snap.snapshot.value as Map)["car_details"]["car_number"];
      }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializedCloudMessaging(context);
    pushNotificationSystem.generatingAnToken();
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllers.complete(controller);
              newGoogleMapController = controller;
              blackGoogleMapTheme(newGoogleMapController);
              locateDriverPosition();
            },
          ),
          statusText != "Now Online"
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black87,
                )
              : Container(),
          Positioned(
            top: statusText != "Now Online"
                ? MediaQuery.of(context).size.height * 0.46
                : 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (isDriverActive != true) {
                        driverIsOnlineNow();
                        updateDriverLocationAtRealTime();

                        setState(() {
                          statusText = "Now Online";
                          isDriverActive = true;
                          buttonColor = Colors.transparent;
                        });

                        Fluttertoast.showToast(msg: "you are Online Now");
                      } else {
                        driverIsOfflineNow();

                        setState(() {
                          statusText = "Now Offline";
                          isDriverActive = false;
                          buttonColor = Colors.grey;
                        });

                        //display Toast
                        Fluttertoast.showToast(msg: "you are Offline Now");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26))),
                    child: statusText != "Now Online"
                        ? Text(
                            statusText,
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : const Icon(
                            Icons.phonelink_ring,
                            color: Colors.white,
                            size: 26,
                          ))
              ],
            ),
          )
        ],
      ),
    );
  }

  driverIsOnlineNow() async {
    Position poss = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = poss;
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.set("idle");
    ref.onValue.listen((event) {});
  }

  updateDriverLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive == true) {
        Geofire.setLocation(currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), () {
      (context as Element).reassemble();
    });
  }
}
