import 'package:drivers_app/assistant/request_assistant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/users_model.dart';


class AssistantMethods {
  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";
    var response = await RequestAssistant.receiveRequest(apiUrl);

    if (response != "Error Occured, Failed. No Response") {
      humanReadableAddress = response["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationLatidtude = position.latitude;
      userPickupAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUplocationAddress(userPickupAddress);
    }
    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print("name = " + userModelCurrentInfo!.name.toString());
        print("email = " + userModelCurrentInfo!.email.toString());
        print("phone = " + userModelCurrentInfo!.phone.toString());
      }
    });
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    print(urlOriginToDestinationDirectionDetails);
    var responseDirection = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if (responseDirection == "Error Occurred, Failed. No Response") {
     return null;
    }
    else{

      DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

      directionDetailsInfo.e_points = responseDirection["routes"][0]["overview_polyline"]["points"];
      directionDetailsInfo.distance_text = responseDirection["routes"][0]["legs"][0]["distance"]["text"];
      directionDetailsInfo.distance_value = responseDirection["routes"][0]["legs"][0]["distance"]["value"];

      directionDetailsInfo.duration_text = responseDirection["routes"][0]["legs"][0]["duration"]["text"];
      directionDetailsInfo.duration_value = responseDirection["routes"][0]["legs"][0]["duration"]["value"];


      return directionDetailsInfo;
    }


  }
}
