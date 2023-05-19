import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String firestoreCollection = "User Trips";

Future firestoreCreateUserCollection(User user) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .set({});
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

Future firestoreEditVehiclesList({
  required User user,
  required Set<String> vehiclesList,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"vehiclesList": vehiclesList});
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
