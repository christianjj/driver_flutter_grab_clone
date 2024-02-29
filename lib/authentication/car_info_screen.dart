import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoSCreen extends StatefulWidget {
  const CarInfoSCreen({super.key});

  @override
  State<CarInfoSCreen> createState() => _CarInfoSCreenState();
}

class _CarInfoSCreenState extends State<CarInfoSCreen> {
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
  TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();
  List<String> carTypesList = ["uber-go", "uber-x", "bike"];
  String? selectedCartype;


  saveCarInfo() async {
    Map driverCarInfo = {
      "car_color": carColorTextEditingController.text.trim(),
      "car_number": carNumberTextEditingController.text.trim(),
      "car_model": carModelTextEditingController.text.trim(),
      "type": selectedCartype
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child(
        "drivers");
    driversRef.child(currentFirebaseUser!.uid).child("carDetails").set(
        driverCarInfo);

    Fluttertoast.showToast(msg: "Car Details has been saved. Congrats");
    Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("images/logo1.png"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Car Details",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                TextField(
                    controller: carModelTextEditingController,
                    style: const TextStyle(color: Colors.grey),
                    decoration: const InputDecoration(
                      labelText: "Car Model",
                      hintText: "Enter Car Model",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    )),
                TextField(
                    controller: carColorTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.grey),
                    decoration: const InputDecoration(
                      labelText: "Car Color",
                      hintText: "Enter Car Color",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    )),
                TextField(
                    controller: carNumberTextEditingController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.grey),
                    decoration: const InputDecoration(
                      labelText: "Car Number",
                      hintText: "Enter Car Number",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField(
                    dropdownColor: Colors.black,
                    hint: const Text(
                      "Please choose Car type",
                      style: TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),

                    value: selectedCartype,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCartype = newValue.toString();
                      });
                    },
                    items: carTypesList.map((car) {
                      return DropdownMenuItem(
                        value: car,
                        child: Text(
                          car,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: () {
                    if (carColorTextEditingController.text.isNotEmpty &&
                        carNumberTextEditingController.text.isNotEmpty &&
                        carModelTextEditingController.text.isNotEmpty &&
                        selectedCartype != null){
                      saveCarInfo();
                    }
                  },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreenAccent),
                      child: const Text("Save Now", style: TextStyle(
                          color: Colors.black,
                          fontSize: 18
                      ),)),
                )
              ],
            ),
          )),
    );
  }
}
