import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_history/constants.dart';

const String firestoreCollection = "User Trips";

Future firestoreCreateUserCollection(User user) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .set({
    "theme": "light",
    'units': "km",
    "vehiclesList": [],
    'newUser': true,
    'currentVehicle': '',
    'isSystemTheme': true,
    'defaultGraphTabIndex': 0,
    'pricePerUnitOfFuel': 0.0,
  });
}

Future firestoreSetPricePerUnitOfFuel(
    User user, double pricePerUnitOfFuel) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'pricePerUnitOfFuel': pricePerUnitOfFuel});
}

Future firestoreGetPricePerUnitOfFuel(User user) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!['pricePerUnitOfFuel']);
}

Future firestoreSetDefaultGraphTabIndex(
    User user, int defaultGraphTabIndex) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'defaultGraphTabIndex': defaultGraphTabIndex});
}

Future firestoreGetDefaultGraphTabIndex(
  User user,
) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!['defaultGraphTabIndex']);
}

Future firestoreUpdateNewUser(User user, bool newUser) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'newUser': newUser});
}

Future firestoreCreateNewVehicle(User user, String newVehicle) async {
  Set vehicles = {...await firestoreGetVehiclesList(user: user)};
  vehicles.add(newVehicle);
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'vehiclesList': []});
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'vehiclesList': vehicles.toList()});
}

Future firestoreDeleteVehicle(User user, String deletionVehicle) async {
  Set vehicles = {...await firestoreGetVehiclesList(user: user)};
  vehicles.remove(deletionVehicle);
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'vehiclesList': []});
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({'vehiclesList': vehicles.toList()});
}

Future firestoreSetIsSystemTheme(User user, bool isSystemTheme) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"isSystemTheme": isSystemTheme});
}

Future firestoreGetIsSystemTheme(User user) async {
  var doc = await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get();
  return doc['isSystemTheme'];
}

Future firestoreSetTheme(User user, String theme) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"theme": theme});
}

Future firestoreGetTheme(User user) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!['theme']);
}

Future firestoreSetUnits(User user, Units units) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"units": (units == Units.km) ? "km" : "mi"});
}

Future firestoreGetUnits(User user) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!['units']);
}

Future firestoreSetCurrentVehicle({
  required User user,
  required String currentVehicle,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"currentVehicle": currentVehicle});
}

Future firestoreGetCurrentVehicle({
  required User user,
}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then(
        (value) => value.data()!['currentVehicle'],
      );
}

Future firestoreUpdateVehiclesList({
  required User user,
  required List vehiclesList,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"vehiclesList": vehiclesList});
}

Future firestoreGetVehiclesList({required User user}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!['vehiclesList']);
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

Future firestoreCreateTrip({
  required User user,
  required Map<String, dynamic> tripDetailsMap,
}) async {
  String randId = generateRandomString(18);
  tripDetailsMap['id'] = randId;
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("Trips")
      .add(tripDetailsMap)
      .then((value) {
    tripDetailsMap['id'] = value.id;
    firestoreUpdateTrip(user: user, updatedData: tripDetailsMap, id: value.id);
  });
}

Future firestoreUpdateTrip({
  required User user,
  required Map<String, dynamic> updatedData,
  required String id,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("Trips")
      .doc(id)
      .update(updatedData);
}

Future firestoreDeleteTrip({
  required User user,
  required String id,
}) async {
  FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("Trips")
      .doc(id)
      .delete();
}
