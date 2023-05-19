import 'package:trip_history/constants.dart';

class TripDetails {
  final int dateTime;
  double mileage, distance, duration;
  final String name, id;
  DistanceUnits distanceUnits;
  String vehicleName;
  TripDetails({
    required this.dateTime,
    required this.mileage,
    required this.distance,
    required this.duration,
    required this.id,
    required this.name,
    required this.distanceUnits,
    required this.vehicleName,
  });

  toMap() {
    return {
      'dateTime': dateTime,
      'mileage': mileage,
      'distance': distance,
      'duration': duration,
      'id': id,
      'distanceUnits': distanceUnits,
      'vehicleName': vehicleName
    };
  }
}
