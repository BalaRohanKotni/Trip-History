import 'package:flutter/material.dart';

import '../constants.dart';

class SettingsDialog extends StatefulWidget {
  final Function onChangeDistanceUnits;
  const SettingsDialog({super.key, required this.onChangeDistanceUnits});

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
                                    widget.onChangeDistanceUnits(distanceUnits);
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
                                    widget.onChangeDistanceUnits(distanceUnits);
                                  })),
                        ),
                      )
                    ],
                  ),
                ],
              )
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
