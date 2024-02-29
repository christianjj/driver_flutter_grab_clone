import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_data.dart';
import '../models/users_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;

User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

StreamSubscription<Position>?  streamSubscriptionPosition;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

Position? driverCurrentPosition;

DriverData? onlineDriverData = DriverData();