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
  TextEditingController dateController = TextEditingController();
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
      dateController.text = DateFormat.yMMMd().format(
          DateTime.fromMillisecondsSinceEpoch(widget.initDateInMilliSeconds!));
      tripDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.initDateInMilliSeconds!);
    }
  }

  _funcShowCalendarPicker(
      {required BuildContext dialogContext, required bool duringBuild}) {
    Future.delayed(
      Duration.zero,
      () {
        showDialog(
          context: dialogContext,
          builder: (datepickerContext) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CalendarDatePicker(
                      initialDate: tripDateTime,
                      firstDate: DateTime(1960),
                      lastDate: DateTime(2901),
                      onDateChanged: (DateTime selectedDate) {
                        tripDateTime = selectedDate;
                        String formattedDate =
                            DateFormat("yMMMd").format(selectedDate);
                        dateController.text = formattedDate;
                        Navigator.pop<DateTime>(dialogContext, selectedDate);
                        dateFocusNode.nextFocus();
                        showCalendarPicker = false;
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showCalendarPicker) {
      _funcShowCalendarPicker(dialogContext: context, duringBuild: true);
    }
    return BottomSheet(
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
                      child: TextField(
                        focusNode: dateFocusNode,
                        controller: dateController,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: "Date",
                        ),
                        onTap: () {
                          showCalendarPicker = true;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
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
                          suffixText: (vehicleTripsData[0].distanceUnits ==
                                  DistanceUnits.km)
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
                          suffixText: (vehicleTripsData[0].distanceUnits ==
                                  DistanceUnits.km)
                              ? 'km/l'
                              : 'mpg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 48,
                )
              ],
            ),
          );
        });
  }
}
