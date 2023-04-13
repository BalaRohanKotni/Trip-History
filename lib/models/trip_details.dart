import 'package:trip_history/constants.dart';

class TripDetails {
  final int dateTime;
  double mileage, dist, dur;
  final String name, id;
  DistanceUnits distanceUnits;
  TripDetails({
    required this.dateTime,
    required this.mileage,
    required this.dist,
    required this.dur,
    required this.id,
    required this.name,
    required this.distanceUnits,
  });
}
