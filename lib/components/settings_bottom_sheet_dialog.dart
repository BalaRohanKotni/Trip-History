import 'package:flutter/material.dart';
import '../constants.dart';

class SettingsDialog extends StatefulWidget {
  final Function onChangeDistanceUnits,
      replaceVehicleInTrips,
      setSelectedVehicleInHomeScreen;
  final List vehicleTrips;
  const SettingsDialog({
    super.key,
    required this.onChangeDistanceUnits,
    required this.replaceVehicleInTrips,
    required this.setSelectedVehicleInHomeScreen,
    required this.vehicleTrips,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String _selectedVehicle = vehiclesList.elementAt(0);
  String _newVehicleReplacing = vehiclesList.elementAt(0);
  TextEditingController newVehicleController = TextEditingController();
  bool editMode = false;
  List<DropdownMenuItem> items = [];
  Widget vehiclesWidget = Container();
  @override
  Widget build(BuildContext context) {
    distanceUnits = vehicleTripsData.first.distanceUnits;
    if (editMode) {
      List<Widget> items = [];
      items.add(
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextField(
            controller: newVehicleController,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        newVehicleController.text = "";
                      });
                    },
                    icon: const Icon(Icons.clear)),
                hintText: "Add"),
            onSubmitted: (value) => setState(() {
              _selectedVehicle = value;
              vehiclesList.add(value);
              newVehicleController.text = "";
            }),
          ),
        ),
      );

      for (int index = 0; index < vehiclesList.length; index++) {
        items.add(ListTile(
          title: Text(vehiclesList.elementAt(index)),
          trailing: IconButton(
            onPressed: () {
              if (vehiclesList.length > 1) {
                showDialog(
                    context: context,
                    builder: (bContext) {
                      Set newVehiclesList = Set.from(vehiclesList);
                      newVehiclesList.remove(vehiclesList.elementAt(index));
                      _newVehicleReplacing = newVehiclesList.first;
                      var statefulBuilder = StatefulBuilder(
                        builder: (bc, setStateDialog) {
                          return AlertDialog(
                            title:
                                Text("Delete ${vehiclesList.elementAt(index)}"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(bContext);
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  "Done",
                                ),
                                onPressed: () {
                                  widget.replaceVehicleInTrips(
                                    vehiclesList.elementAt(index),
                                    _newVehicleReplacing,
                                  );
                                  Navigator.pop(bc);
                                  setState(() {
                                    widget.replaceVehicleInTrips(
                                        vehiclesList.elementAt(index),
                                        _newVehicleReplacing);
                                    currentVehicle = _newVehicleReplacing;
                                    _selectedVehicle = currentVehicle;
                                    vehiclesList
                                        .remove(vehiclesList.elementAt(index));
                                  });
                                },
                              ),
                            ],
                            content: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      "Select a vehicle to replace for trips made on ${vehiclesList.elementAt(index)}"),
                                ),
                                DropdownButton(
                                  value: _newVehicleReplacing,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      _newVehicleReplacing = value.toString();
                                    });
                                  },
                                  items: List.generate(
                                    newVehiclesList.length,
                                    (index) {
                                      return DropdownMenuItem(
                                        value: newVehiclesList.elementAt(index),
                                        child: Text(
                                          newVehiclesList.elementAt(index),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                      return statefulBuilder;
                    });
              } else {
                showDialog(
                    context: context,
                    builder: (bcontext) {
                      return AlertDialog(
                        title: const Text("Atleast one vehicle is needed"),
                        content: Text(
                            "Atleast one vehicle is required. If you wish to delete ${vehiclesList.elementAt(index)}, create a new vehicle and then delete ${vehiclesList.elementAt(index)}."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(bcontext);
                            },
                            child: const Text("Close"),
                          )
                        ],
                      );
                    });
              }
            },
            icon: const Icon(Icons.clear),
          ),
        ));
      }

      vehiclesWidget = Expanded(
          child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: items,
      ));
    } else {
      vehiclesWidget = DropdownButton(
        value: _selectedVehicle,
        onChanged: (value) {
          setState(() {
            _selectedVehicle = value.toString();
            widget.setSelectedVehicleInHomeScreen(_selectedVehicle);
          });
        },
        items: List.generate(
          vehiclesList.length,
          (index) {
            return DropdownMenuItem(
              value: vehiclesList.elementAt(index),
              child: Row(
                children: [
                  Text(
                    vehiclesList.elementAt(index),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return BottomSheet(
      builder: (bContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Container(
            margin: const EdgeInsets.all(28),
            child: Scrollbar(
              thumbVisibility: true,
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
                                      widget
                                          .onChangeDistanceUnits(distanceUnits);
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
                                      widget
                                          .onChangeDistanceUnits(distanceUnits);
                                    })),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 14),
                            child: const Text("Vehicle: ")),
                        vehiclesWidget,
                        TextButton(
                          onPressed: () {
                            setState(() {
                              (!editMode) ? editMode = true : editMode = false;
                            });
                          },
                          child: Text((!editMode) ? "Edit" : "Done"),
                        )
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ),
        );
      },
      onClosing: () {
        Navigator.pop(context);
      },
    );
  }
}
