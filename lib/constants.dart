import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trip_history/models/trip_details.dart';

TextStyle semiBold18() {
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}

//TODO Sync distanceUnits to firestore
DistanceUnits distanceUnits = DistanceUnits.km;

enum DistanceUnits { km, mi }

enum TripDialogMode { create, edit }

Set<String> vehicles = {};

//TODO Sync currentVehicle to firestore
String currentVehicle = "";

List<TripDetails> vehicleTripsData = [];

const Color kPurpleDarkShade = Color(0xFF4f378b);
const Color kPurpleLightShade = Color.fromARGB(255, 246, 241, 255);

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(const Duration(seconds: 5));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on TimeoutException {
    return false;
  } on SocketException catch (_) {
    return false;
  }
}

String firebaseExceptionHandler(e, networkStatus) {
  String error;
  switch (e.code) {
    case "invalid-email":
      error = "Email address is not valid";
      break;
    case "user-disabled":
      error = "Account is disabled";
      break;
    case "user-not-found":
      error = "Account not found, check email address or create a new account";
      break;
    case "wrong-password":
      error = "Incorrect password";
      break;
    default:
      if (!networkStatus) {
        error = "No internet connection";
      } else {
        error = e.message;
      }
    // error = e.code;
  }
  return error;
}
