import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class TripDialog extends StatefulWidget {
  final TripDialogMode tripDialogMode;
  final String? initTripName;
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
  });

  @override
  State<TripDialog> createState() => _TripDialogState();
}

class _TripDialogState extends State<TripDialog> {
  late String pickedDate;
  FocusNode dateFocusNode = FocusNode();
  bool showCalendarPicker = false;
  TextEditingController tripNameController = TextEditingController(),
      distanceController = TextEditingController(),
      durationController = TextEditingController(),
      mileageController = TextEditingController();
  DateTime tripDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    pickedDate = "Date";
    dateFocusNode.addListener(() {
      if (dateFocusNode.hasFocus) {
        setState(() {
          showCalendarPicker = true;
        });
      } else {
        setState(() {
          showCalendarPicker = false;
        });
      }
    });
    if (widget.tripDialogMode == TripDialogMode.edit) {
      tripNameController.text = widget.initTripName!;
      distanceController.text = widget.initDist!.toString();
      durationController.text = widget.initDur!.toString();
      mileageController.text = widget.initMileage!.toString();
      tripDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.initDateInMilliSeconds!);
    }
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: tripNameController,
                        decoration: const InputDecoration(
                          hintText: "Trip Name",
                        ),
                        keyboardType: TextInputType.streetAddress,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 3,
                      child: TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  side: BorderSide(color: kPurpleDarkShade))),
                        ),
                        child: Text(
                          pickedDate,
                        ),
                        onPressed: () async {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(3000),
                          ).then((value) => pickedDate =
                              DateFormat("yMMMd").format(value!).toString());
                        },
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
                          suffixText:
                              (vehicleTripsData[0].distanceUnits == Units.km)
                                  ? 'km'
                                  : 'mi',
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
                        decoration: const InputDecoration(
                            hintText: "Duration", suffixText: "hrs"),
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
                          suffixText:
                              (vehicleTripsData[0].distanceUnits == Units.km)
                                  ? 'km/l'
                                  : 'mpg',
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
                          // TODO
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  side: BorderSide(color: kPurpleDarkShade))),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Expanded(
                        flex: 4,
                        child: TextButton(
                            onPressed: () {
                              // TODO
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
                              "Done",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))),
                  ],
                ),
                const SizedBox(
                  height: 48,
                ),
              ],
            ),
          );
        });
  }
}
