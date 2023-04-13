import 'package:flutter/material.dart';

TextStyle semiBold18() {
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}

DistanceUnits distanceUnits = DistanceUnits.km;
MileageUnits mileageUnits = MileageUnits.kml;

enum DistanceUnits { km, mi }

enum MileageUnits { kml, mpg }
