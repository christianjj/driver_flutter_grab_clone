import 'dart:async';

import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreen/main_screen.dart';
import 'package:flutter/material.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {

    Timer(const Duration(seconds: 3), () async {
      if(fAuth.currentUser != null){
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      }
      else{
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/logo1.png"),
            const SizedBox(height: 10),
            const Text(
              "Driver App",
              style: TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        )),
      ),
    );
  }
}
