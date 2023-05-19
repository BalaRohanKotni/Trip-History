import 'package:trip_history/constants.dart';

class TripDetails {
  final int dateTime;
  double mileage, distance, dur;
  final String name, id;
  DistanceUnits distanceUnits;
  String vehicleName;
  TripDetails({
    required this.dateTime,
    required this.mileage,
    required this.distance,
    required this.dur,
    required this.id,
    required this.name,
    required this.distanceUnits,
    required this.vehicleName,
  });
}
