import 'package:flutter/material.dart';

import '../constants.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      builder: (bContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Container(
            margin: const EdgeInsets.all(28),
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Distance Units"),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("Km"),
                          leading: Radio(
                              value: DistanceUnits.km,
                              groupValue: distanceUnits,
                              onChanged: (units) => setState(() {
                                    distanceUnits = units!;
                                  })),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("Mi"),
                          leading: Radio(
                              value: DistanceUnits.mi,
                              groupValue: distanceUnits,
                              onChanged: (units) => setState(() {
                                    distanceUnits = units!;
                                  })),
                        ),
                      )
                    ],
                  ),
                  const Text("Economy/Mileage Units"),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("km/l"),
                          leading: Radio(
                              value: MileageUnits.kml,
                              groupValue: mileageUnits,
                              onChanged: (units) => setState(() {
                                    mileageUnits = units!;
                                  })),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("Mi"),
                          leading: Radio(
                              value: MileageUnits.mpg,
                              groupValue: mileageUnits,
                              onChanged: (units) => setState(() {
                                    mileageUnits = units!;
                                  })),
                        ),
                      )
                    ],
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Ok"))
                ],
              ),
            ]),
          ),
        );
      },
      onClosing: () {
        Navigator.pop(context);
      },
    );
  }
}
