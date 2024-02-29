import 'dart:ffi';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_Information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'notification_dialog_box.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializedCloudMessaging(BuildContext context) async{
    //1. Terminated - when app is closed
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){
        if (remoteMessage != null){
          //display  ride request information
          print("This is remote message :: ");
          print(remoteMessage.data["rideRequestId"]);
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);

        }
    });

    //2. ForeGround - when app is open and received push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      //display ride  request information

      print(remoteMessage?.data);
      readUserRideRequestInformation(remoteMessage?.data["rideRequestId"], context);

    });

    //3. background - when the app is in the back ground and opened directly from the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      print("This is remote message :: ");
      print(remoteMessage?.data);
      readUserRideRequestInformation(remoteMessage?.data["rideRequestId"], context);
    });
  }

  readUserRideRequestInformation(String? userRideRequestId, BuildContext context){
    if (userRideRequestId != null) {
      audioPlayer.open(Audio("music/music_notification.mp3"));
      audioPlayer.play();
      FirebaseDatabase.instance.ref().child("All Ride Request").child(
          userRideRequestId).once().then((snapData){
            if(snapData.snapshot.value != null){
               double originLatitude = double.parse((snapData.snapshot.value! as Map) ["origin"]["latitude"]);
               double originLongtitude = double.parse((snapData.snapshot.value! as Map) ["origin"]["longtitude"]);
               String originAddress = (snapData.snapshot.value! as Map) ["originAddress"];

               double destinationLatitude = double.parse((snapData.snapshot.value! as Map) ["destination"]["latitude"]);
               double destinationLongtitude = double.parse((snapData.snapshot.value! as Map) ["destination"]["longtitude"]);
               String destinationAddress = (snapData.snapshot.value! as Map) ["destinationAddress"];

               String userName = (snapData.snapshot.value! as Map) ["userName"];
               String userPhone = (snapData.snapshot.value! as Map) ["userPhone"];

               String? rideRequestId = snapData.snapshot.key;

               UserRideRequestInformation userRideRequestInformation = UserRideRequestInformation();
               userRideRequestInformation.originLatLng = LatLng(originLatitude, originLongtitude);
               userRideRequestInformation.originAddress = originAddress;
               userRideRequestInformation.destinationLatLng = LatLng(destinationLatitude, destinationLongtitude);
               userRideRequestInformation.destinationAddress = destinationAddress;

               userRideRequestInformation.userName = userName;
               userRideRequestInformation.userPhone = userPhone;

               userRideRequestInformation.rideRequestId= rideRequestId;


               showDialog(context: context, builder: (BuildContext context) => NotificationDialogBox(userRideRequestInformation: userRideRequestInformation,),);
               //print("user Ride Request information ::");
               //print(userRideRequestInformation.userName);
            }
          else{
            Fluttertoast.showToast(msg: "This Ride Request Id did not exists.");
            }
      });


    }
  }

  Future generatingAnToken() async {

   String? registrationToken = await messaging.getToken();
   print("FCM Registration Token: ");
   print(registrationToken);
   FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("token").set(registrationToken);
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}