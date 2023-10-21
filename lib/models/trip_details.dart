import 'package:trip_history/constants.dart';

class TripDetails {
  final int dateTime;
  double? mileage;
  double distance, duration;
  final String tripTitle, id;
  Units distanceUnits;
  String vehicleName;
  TripDetails({
    required this.dateTime,
    this.mileage,
    required this.distance,
    required this.duration,
    required this.id,
    required this.tripTitle,
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
      'tripTitle': tripTitle,
      'distanceUnits': (distanceUnits == Units.km) ? "km" : "mi",
      'vehicleName': vehicleName
    };
  }
}
