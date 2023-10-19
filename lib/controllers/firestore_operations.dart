import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_history/constants.dart';

const String firestoreCollection = "User Trips";

Future firestoreCreateUserCollection(User user) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .set({
    "theme": "system",
    'units': "km",
    "vehiclesList": [],
    'newUser': "true",
    'currentVehicle': ''
  });
}

Future firestoreCreateNewVehicle(User user, String newVehicle) async {
  Set vehicles = {...await firestoreGetVehiclesList(user: user)};
  vehicles.add(newVehicle);
  print(vehicles);
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

Future firestoreAddTrip({
  required User user,
  required Map<String, dynamic> tripDetailsMap,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("Trips")
      .add(tripDetailsMap)
      .then((docRef) {
    FirebaseFirestore.instance
        .collection(firestoreCollection)
        .doc(user.uid)
        .collection("Trips")
        .doc(docRef.id)
        .update({"id": docRef.id});
  });
}

Future<Map<String, dynamic>> firestoreGetTrip({
  required User user,
  required String id,
}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("Trips")
      .doc(id)
      .get()
      .then((value) => value.data()!);
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
