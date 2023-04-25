import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class TripDialog extends StatefulWidget {
  const TripDialog({super.key});

  @override
  State<TripDialog> createState() => _TripDialogState();
}

class _TripDialogState extends State<TripDialog> {
  TextEditingController dateController = TextEditingController();
  FocusNode dateFocusNode = FocusNode();
  bool showCalendarPicker = false;

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
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1960),
                      lastDate: DateTime(2901),
                      onDateChanged: (DateTime selectedDate) {
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
                    const Expanded(
                      flex: 6,
                      child: TextField(
                        decoration: InputDecoration(
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
                    const Expanded(
                      flex: 3,
                      child: TextField(
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration: InputDecoration(
                            hintText: "Duration", suffixText: "hrs"),
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 3,
                      child: TextField(
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
