import 'dart:async';

import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_Information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../assistant/assistant_methods.dart';
import '../assistant/black_theme_google_map.dart';
import '../infoHandler/app_info.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;

  NewTripScreen({this.userRideRequestInformation});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;

  final Completer<GoogleMapController> _controllers = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();

  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;

  Future<void> drawPolyLineFromSourceToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("points = ");

    print(directionDetailsInfo?.e_points);

    polyLinePositionCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPPointsResultList =
        polylinePoints.decodePolyline(directionDetailsInfo!.e_points!);

    if (decodedPPointsResultList.isNotEmpty) {
      decodedPPointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });

      setOfPolyline.clear();

      setState(() {
        Polyline polyline = Polyline(
          color: Colors.blue,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polyLinePositionCoordinates,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        setOfPolyline.add(polyline);
      });

      LatLngBounds boundsLatLng;
      if (originLatLng.latitude > destinationLatLng.latitude &&
          originLatLng.longitude > destinationLatLng.longitude) {
        boundsLatLng =
            LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
      } else if (originLatLng.longitude > destinationLatLng.longitude) {
        boundsLatLng = LatLngBounds(
            southwest:
                LatLng(originLatLng.latitude, destinationLatLng.longitude),
            northeast:
                LatLng(destinationLatLng.latitude, originLatLng.longitude));
      } else if (destinationLatLng.latitude > destinationLatLng.latitude) {
        boundsLatLng = LatLngBounds(
            southwest:
                LatLng(destinationLatLng.latitude, originLatLng.longitude),
            northeast:
                LatLng(originLatLng.latitude, destinationLatLng.longitude));
      } else {
        boundsLatLng =
            LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
      }
      newTripGoogleMapController!
          .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
      Marker originMarker = Marker(
        markerId: MarkerId("originID"),
        position: originLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId("destinationID"),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      setState(() {
        setOfMarkers.add(originMarker);
        setOfMarkers.add(destinationMarker);
      });

      Circle originCircle = Circle(
        circleId: CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeColor: Colors.white,
        strokeWidth: 3,
        center: originLatLng,
      );

      Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.red,
        radius: 12,
        strokeColor: Colors.white,
        strokeWidth: 3,
        center: destinationLatLng,
      );

      setState(() {
        setOfCircle.add(originCircle);
        setOfCircle.add(destinationCircle);
      });
    }
  }

  @override
  void initState() {
    saveAssignedDriverDetailsToUserRideRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllers.complete(controller);
              newTripGoogleMapController = controller;
              blackGoogleMapTheme(newTripGoogleMapController);

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var userCurrentLatlng =
                  widget.userRideRequestInformation!.originLatLng;

              drawPolyLineFromSourceToDestination(
                  driverCurrentLatLng, userCurrentLatlng!);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white30,
                        blurRadius: 18,
                        spreadRadius: .5,
                        offset: Offset(0.6, 0.6))
                  ]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      "18 mins",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightGreenAccent),
                    ),
                    Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        Text(
                          widget.userRideRequestInformation!.userName!,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreenAccent),
                        ),
                        const Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(
                        width: 22,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestInformation!.originAddress!,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ]),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(
                        width: 22,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestInformation!
                                .destinationAddress!,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ]),
                    const SizedBox(
                      height: 18,
                    ),
                    Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      icon: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(buttonTitle!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Request")
        .child(widget.userRideRequestInformation!.rideRequestId!);

    Map driverLocationMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longtitude": driverCurrentPosition!.longitude.toString()
    };

    databaseReference.child("driverLocation").set(driverLocationMap);
    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlineDriverData!.id);
    databaseReference.child("driverName").set(onlineDriverData!.name);
    databaseReference.child("driverPhone").set(onlineDriverData!.phone);
    databaseReference.child("car_details").set(
        onlineDriverData!.car_color.toString() +
            onlineDriverData!.car_model.toString());
    saveRideRequestIdToDriverHistory();
  }

  void saveRideRequestIdToDriverHistory() {
DatabaseReference tripHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripsHistory");

      tripHistoryRef.child(widget.userRideRequestInformation!.rideRequestId!).set(true);
  }
}


