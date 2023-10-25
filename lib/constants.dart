import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trip_history/models/trip_details.dart';

TextStyle semiBold18() {
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}

Brightness kBrightness = Brightness.light;

Units kUnits = Units.km;

StreamController<bool> isLightThemeModeStreamController = StreamController();

enum Units { km, mi }

enum TripDialogMode { create, edit }

enum GraphMode { mileage, distance, duration, averageSpeed }

enum AppTheme { light, dark, system }

Set<dynamic> vehiclesList = {};

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

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}
