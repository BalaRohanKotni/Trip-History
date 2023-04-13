import 'package:flutter/material.dart';

class TripDetails {
  final int dateTime;
  final double mileage, dist, dur;
  final String name, id;
  TripDetails({
    required this.dateTime,
    required this.mileage,
    required this.dist,
    required this.dur,
    required this.id,
    required this.name,
  });
}
