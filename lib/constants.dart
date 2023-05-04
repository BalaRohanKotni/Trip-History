import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

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

List vehicleTripsData = [];

const Color purpleDarkShade = Color(0xFF4f378b);
const Color purpleLightShade = Color.fromARGB(255, 246, 241, 255);

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
