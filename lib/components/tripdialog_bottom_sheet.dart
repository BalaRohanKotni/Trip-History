import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_history/controllers/firestore_operations.dart';

import '../constants.dart';

class TripDialog extends StatefulWidget {
  final TripDialogMode tripDialogMode;
  final String? initTripName, id;
  final double? initDist, initDur, initMileage;
  final int? initDateInMilliSeconds;
  const TripDialog({
    super.key,
    required this.tripDialogMode,
    this.initTripName,
    this.initDist,
    this.initDur,
    this.initMileage,
    this.initDateInMilliSeconds,
    this.id,
  });

  @override
  State<TripDialog> createState() => _TripDialogState();
}

class _TripDialogState extends State<TripDialog> {
  TextEditingController tripNameController = TextEditingController(),
      distanceController = TextEditingController(),
      durationController = TextEditingController(),
      tripDateTimeController = TextEditingController(),
      mileageController = TextEditingController();
  DateTime tripDateTime = DateTime.now();
  bool anyFieldEmpty = true;
  FocusNode tripDateTimeFocusNode = FocusNode();

  final _scrollController = ScrollController();

  String dateFormat = "MMM d, y\nhh:mm a";

  void checkFeildsAreEmpty() {
    setState(() {
      if (tripNameController.text.isEmpty ||
          distanceController.text.isEmpty ||
          durationController.text.isEmpty) {
        anyFieldEmpty = true;
      } else {
        anyFieldEmpty = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    tripDateTimeController.text =
        DateFormat(dateFormat).format(tripDateTime).toString();
    mileageController.text = "0";

    if (widget.tripDialogMode == TripDialogMode.edit) {
      tripNameController.text = widget.initTripName!;
      distanceController.text = widget.initDist!.toString();
      durationController.text = widget.initDur!.toString();
      mileageController.text = widget.initMileage!.toString();
      tripDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.initDateInMilliSeconds!);
      tripDateTimeController.text =
          DateFormat(dateFormat).format(tripDateTime).toString();
    }

    tripNameController.addListener(() {
      checkFeildsAreEmpty();
    });
    distanceController.addListener(() {
      checkFeildsAreEmpty();
    });
    durationController.addListener(() {
      checkFeildsAreEmpty();
    });
    mileageController.addListener(() {
      checkFeildsAreEmpty();
    });
    tripDateTimeFocusNode.addListener(() async {
      if (tripDateTimeFocusNode.hasFocus) {
        DateTime? pickedDateTime;
        if (widget.tripDialogMode == TripDialogMode.create) {
          pickedDateTime = await showDateTimePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(3000),
          );
        } else {
          pickedDateTime = await showDateTimePicker(
            context: context,
            initialDate: tripDateTime,
            firstDate: DateTime(1900),
            lastDate: DateTime(3000),
          );
        }
        if (pickedDateTime != null) {
          setState(() {
            tripDateTime = pickedDateTime!;
            tripDateTimeController.text =
                DateFormat(dateFormat).format(tripDateTime).toString();
          });
        }

        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (dialogContext) {
          return Container(
            padding: MediaQuery.of(context).viewInsets,
            margin: const EdgeInsets.all(16),
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextField(
                            controller: tripNameController,
                            decoration: InputDecoration(
                              hintText: "Trip Name",
                              errorText: (anyFieldEmpty &&
                                      tripNameController.text.isEmpty)
                                  ? "Required"
                                  : null,
                            ),
                            keyboardType: TextInputType.streetAddress,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: tripDateTimeController,
                            focusNode: tripDateTimeFocusNode,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: distanceController,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.next,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              hintText: "Distance",
                              errorText: (anyFieldEmpty &&
                                      distanceController.text.isEmpty)
                                  ? "Required"
                                  : null,
                              suffixText: (kUnits == Units.km) ? 'km' : 'mi',
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: durationController,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.next,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              hintText: "Duration",
                              errorText: (anyFieldEmpty &&
                                      durationController.text.isEmpty)
                                  ? "Required"
                                  : null,
                              suffixText: "hrs",
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: mileageController,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.next,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              hintText: "Average",
                              suffixText: (kUnits == Units.km) ? 'km/l' : 'mpg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextButton(
                            onPressed: () {
                              if (tripNameController.text == "" &&
                                  durationController.text == "" &&
                                  distanceController.text == "") {
                                Navigator.pop(context);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (cancelDialogContext) {
                                      return AlertDialog(
                                        title: const Text("Delete"),
                                        content: const Text(
                                            "Are you sure to delete this trip?"),
                                        actions: [
                                          TextButton(
                                            onPressed: (() => Navigator.pop(
                                                cancelDialogContext)),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            child: const Text("Delete"),
                                            onPressed: () async {
                                              if (widget.tripDialogMode ==
                                                  TripDialogMode.create) {
                                                Navigator.pop(
                                                    cancelDialogContext);
                                                Navigator.pop(dialogContext);
                                              } else if (widget
                                                      .tripDialogMode ==
                                                  TripDialogMode.edit) {
                                                Navigator.pop(
                                                    cancelDialogContext);
                                                Navigator.pop(dialogContext);
                                                await firestoreDeleteTrip(
                                                    user: FirebaseAuth
                                                        .instance.currentUser!,
                                                    id: widget.id!);
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      side:
                                          BorderSide(color: kPurpleDarkShade))),
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        Expanded(
                            flex: 4,
                            child: TextButton(
                                onPressed: () async {
                                  if (mileageController.text == "") {
                                    mileageController.text = "0";
                                  }
                                  if (!anyFieldEmpty) {
                                    Navigator.pop(dialogContext);
                                    if (widget.tripDialogMode ==
                                        TripDialogMode.create) {
                                      firestoreCreateTrip(
                                        user:
                                            FirebaseAuth.instance.currentUser!,
                                        tripDetailsMap: {
                                          'dateTime': tripDateTime
                                              .millisecondsSinceEpoch,
                                          'mileage': double.parse(
                                              mileageController.text),
                                          'distance': double.parse(
                                              distanceController.text),
                                          'duration': double.parse(
                                              durationController.text),
                                          'tripTitle': tripNameController.text,
                                          'units': (await firestoreGetUnits(
                                                      FirebaseAuth.instance
                                                          .currentUser!) ==
                                                  "km")
                                              ? "km"
                                              : "mi",
                                          'vehicleName': currentVehicle,
                                        },
                                      );
                                    } else {
                                      firestoreUpdateTrip(
                                        user:
                                            FirebaseAuth.instance.currentUser!,
                                        id: widget.id!,
                                        updatedData: {
                                          'dateTime': tripDateTime
                                              .millisecondsSinceEpoch,
                                          'mileage': double.parse(
                                              mileageController.text),
                                          'distance': double.parse(
                                              distanceController.text),
                                          'duration': double.parse(
                                              durationController.text),
                                          'tripTitle': tripNameController.text,
                                          'units': (await firestoreGetUnits(
                                                      FirebaseAuth.instance
                                                          .currentUser!) ==
                                                  "km")
                                              ? "km"
                                              : "mi",
                                          'vehicleName': currentVehicle,
                                        },
                                      );
                                    }
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (doneDialog) {
                                          return AlertDialog(
                                            title: const Text("Unable to Save"),
                                            content: const Text(
                                                "Required fields should be filled."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(doneDialog);
                                                  },
                                                  child: const Text("Ok"))
                                            ],
                                          );
                                        });
                                  }
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          side: BorderSide(
                                              color: kPurpleDarkShade))),
                                ),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))),
                      ],
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
