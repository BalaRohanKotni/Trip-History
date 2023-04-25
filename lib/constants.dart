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
