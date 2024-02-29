import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreen/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_Information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;

  NotificationDialogBox({this.userRideRequestInformation});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.grey),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
            ),
            Image.asset(
              "images/logo.png",
              width: 160,
            ),
            const SizedBox(
              height: 2,
            ),
            const Divider(
              height: 3,
              thickness: 3,
            ),
            const Text(
              "New Ride Request",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
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
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ]),
                  const SizedBox(height: 12.0),
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
                          widget
                              .userRideRequestInformation!.destinationAddress!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ]),
                  const SizedBox(height: 10,),
                  const Divider(
                    height: 3,
                    thickness: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              audioPlayer.pause();
                              audioPlayer.stop();
                              audioPlayer = AssetsAudioPlayer();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel".toUpperCase(),
                              style: const TextStyle(fontSize: 14.0),
                            )),
                        const SizedBox(
                          width: 20.0,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () {
                              audioPlayer.pause();
                              audioPlayer.stop();
                              audioPlayer = AssetsAudioPlayer();
                              // Navigator.pop(context);
                              acceptRiderRequest(context);
                            },
                            child: Text(
                              "Accept".toUpperCase(),
                              style: const TextStyle(fontSize: 14.0),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  acceptRiderRequest(BuildContext context) {
    String getRideRequestId = "";
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        getRideRequestId = snap.snapshot.value.toString();
      } else {
        Fluttertoast.showToast(msg: "This ride Request don not exists");
      }
      Fluttertoast.showToast(msg: "getRideRequestId = " + getRideRequestId);

      if (getRideRequestId ==
          widget.userRideRequestInformation!.rideRequestId) {
        //send driver to newRideScreen
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("accepted");
        Navigator.push(context, MaterialPageRoute(builder: (c) =>
            NewTripScreen(
                userRideRequestInformation: widget.userRideRequestInformation)));
      } else {
        Fluttertoast.showToast(msg: "This Ride Request do not exist.");
      }
    });
  }
}
