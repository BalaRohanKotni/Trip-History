import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:trip_history/controllers/firestore_operations.dart';
import '../constants.dart';

class SettingsDialog extends StatefulWidget {
  final Function onChangeUnits, onDeleteOfVehicle;
  const SettingsDialog({
    super.key,
    required this.onChangeUnits,
    required this.onDeleteOfVehicle,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String _selectedVehicle;
  String _newVehicleReplacing = vehiclesList.elementAt(0);
  AppTheme _theme = AppTheme.system;
  int _selectedDefaultGraphTabIndex = 0;
  List<DropdownMenuItem> items = [];
  Widget vehiclesWidget = Container();
  final ScrollController _scrollController = ScrollController();
  TextEditingController pricePerUnitOfFuel = TextEditingController();

  @override
  void initState() {
    super.initState();
    pricePerUnitOfFuel.text = kPricePerUnitOfFuel.toString();
  }

  @override
  Widget build(BuildContext context) {
    Future<Map> fetchDataForSettingsFromFirestore() async {
      return {
        'units': await firestoreGetUnits(FirebaseAuth.instance.currentUser!),
        'currentVehicle': await firestoreGetCurrentVehicle(
            user: FirebaseAuth.instance.currentUser!),
        'defaultGraphTabIndex': await firestoreGetDefaultGraphTabIndex(
            FirebaseAuth.instance.currentUser!),
        'vehiclesList': await firestoreGetVehiclesList(
            user: FirebaseAuth.instance.currentUser!),
        'theme': await firestoreGetTheme(FirebaseAuth.instance.currentUser!),
        'isSystemTheme':
            await firestoreGetIsSystemTheme(FirebaseAuth.instance.currentUser!),
      };
    }

    return BottomSheet(
      builder: (bContext) {
        return FutureBuilder(
          future: fetchDataForSettingsFromFirestore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              kUnits = (snapshot.data!['units'] == "km") ? Units.km : Units.mi;
              if (snapshot.data!['theme'] == "light" &&
                  snapshot.data!['isSystemTheme'] == false) {
                _theme = AppTheme.light;
              } else if (snapshot.data!['theme'] == "dark") {
                _theme = AppTheme.dark;
              } else {
                _theme = AppTheme.system;
              }
              _selectedDefaultGraphTabIndex =
                  snapshot.data!['defaultGraphTabIndex'];

              _selectedVehicle = snapshot.data!['currentVehicle'];
              vehiclesWidget = DropdownButton(
                value: _selectedVehicle,
                onChanged: (value) {
                  setState(() {
                    _selectedVehicle = value.toString();
                    firestoreSetCurrentVehicle(
                        user: FirebaseAuth.instance.currentUser!,
                        currentVehicle: _selectedVehicle);
                  });
                },
                items: List.generate(
                  snapshot.data!['vehiclesList'].length,
                  (index) {
                    return DropdownMenuItem(
                      value: snapshot.data!['vehiclesList'].elementAt(index),
                      child: Row(
                        children: [
                          Text(
                            snapshot.data!['vehiclesList'].elementAt(index),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );

              return SizedBox(
                height: (MediaQuery.of(context).size.height >=
                        MediaQuery.of(context).size.width)
                    ? MediaQuery.of(context).size.height / 2
                    : MediaQuery.of(context).size.width / 2,
                child: StatefulBuilder(builder: (context, sheetSetState) {
                  return Container(
                    margin: const EdgeInsets.all(28),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView(controller: _scrollController, children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Units"),
                            SizedBox(
                              width: double.maxFinite,
                              child: Wrap(
                                alignment: WrapAlignment.spaceAround,
                                children: [
                                  IntrinsicWidth(
                                    child: ListTile(
                                        title: const Text("Km"),
                                        leading: Radio(
                                            value: Units.km,
                                            groupValue: kUnits,
                                            onChanged: (units) {
                                              sheetSetState(
                                                  (() => kUnits = units!));
                                              setState(() {
                                                widget.onChangeUnits(kUnits);
                                                firestoreSetUnits(
                                                    FirebaseAuth
                                                        .instance.currentUser!,
                                                    kUnits);
                                              });
                                            })),
                                  ),
                                  IntrinsicWidth(
                                    child: ListTile(
                                        title: const Text("Mi"),
                                        leading: Radio(
                                            value: Units.mi,
                                            groupValue: kUnits,
                                            onChanged: (units) {
                                              sheetSetState(
                                                  (() => kUnits = units!));
                                              setState(() {
                                                widget.onChangeUnits(kUnits);
                                                firestoreSetUnits(
                                                    FirebaseAuth
                                                        .instance.currentUser!,
                                                    kUnits);
                                              });
                                            })),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text("Theme"),
                            SizedBox(
                              width: double.maxFinite,
                              child: Wrap(
                                alignment: WrapAlignment.spaceAround,
                                children: [
                                  IntrinsicWidth(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      horizontalTitleGap: 14,
                                      title: const Text("System"),
                                      leading: Radio(
                                          visualDensity: const VisualDensity(
                                              horizontal:
                                                  VisualDensity.minimumDensity,
                                              vertical:
                                                  VisualDensity.minimumDensity),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: AppTheme.system,
                                          groupValue: _theme,
                                          onChanged: (theme) {
                                            sheetSetState(
                                                (() => _theme = theme!));
                                            setState(() {
                                              firestoreSetIsSystemTheme(
                                                  FirebaseAuth
                                                      .instance.currentUser!,
                                                  true);
                                              Brightness brightness =
                                                  SchedulerBinding
                                                      .instance
                                                      .platformDispatcher
                                                      .platformBrightness;
                                              firestoreSetTheme(
                                                  FirebaseAuth
                                                      .instance.currentUser!,
                                                  (brightness ==
                                                          Brightness.light)
                                                      ? "light"
                                                      : "dark");
                                            });
                                          }),
                                    ),
                                  ),
                                  IntrinsicWidth(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      horizontalTitleGap: 14,
                                      title: const Text("Light"),
                                      leading: Radio(
                                          visualDensity: const VisualDensity(
                                              horizontal:
                                                  VisualDensity.minimumDensity,
                                              vertical:
                                                  VisualDensity.minimumDensity),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: AppTheme.light,
                                          groupValue: _theme,
                                          onChanged: (theme) {
                                            sheetSetState(
                                                (() => _theme = theme!));
                                            setState(() {
                                              firestoreSetIsSystemTheme(
                                                  FirebaseAuth
                                                      .instance.currentUser!,
                                                  false);
                                              firestoreSetTheme(
                                                  FirebaseAuth
                                                      .instance.currentUser!,
                                                  "light");
                                            });
                                          }),
                                    ),
                                  ),
                                  IntrinsicWidth(
                                    child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        horizontalTitleGap: 14,
                                        leading: Radio(
                                            visualDensity: const VisualDensity(
                                                horizontal: VisualDensity
                                                    .minimumDensity,
                                                vertical: VisualDensity
                                                    .minimumDensity),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            value: AppTheme.dark,
                                            groupValue: _theme,
                                            onChanged: (theme) {
                                              sheetSetState(
                                                  (() => _theme = theme!));
                                              setState(() {
                                                firestoreSetIsSystemTheme(
                                                    FirebaseAuth
                                                        .instance.currentUser!,
                                                    false);
                                                firestoreSetTheme(
                                                    FirebaseAuth
                                                        .instance.currentUser!,
                                                    "dark");
                                              });
                                            }),
                                        title: const Text("Dark")),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              width: double.maxFinite,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 14),
                                      child: const Text("Vehicle: ")),
                                  vehiclesWidget,
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (editVehiclesContext) {
                                            return StatefulBuilder(
                                              builder:
                                                  (statefulEditVehiclesContext,
                                                      editDialogSetState) {
                                                List<Widget> items = [];

                                                for (int index = 0;
                                                    index < vehiclesList.length;
                                                    index++) {
                                                  items.add(ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(vehiclesList
                                                        .elementAt(index)),
                                                    trailing: IconButton(
                                                      onPressed: () {
                                                        if (vehiclesList
                                                                .length >
                                                            1) {
                                                          showDialog(
                                                              context:
                                                                  editVehiclesContext,
                                                              builder:
                                                                  (bContext) {
                                                                Set newVehiclesList =
                                                                    Set.from(
                                                                        vehiclesList);
                                                                newVehiclesList.remove(
                                                                    vehiclesList
                                                                        .elementAt(
                                                                            index));
                                                                _newVehicleReplacing =
                                                                    newVehiclesList
                                                                        .first;
                                                                var statefulBuilder =
                                                                    StatefulBuilder(
                                                                  builder: (bc,
                                                                      setStateDialog) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          "Delete ${vehiclesList.elementAt(index)}"),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              const Text("Cancel"),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(bContext);
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text(
                                                                            "Done",
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(bc);
                                                                            editDialogSetState(() {
                                                                              setState(() {
                                                                                firestoreDeleteVehicle(FirebaseAuth.instance.currentUser!, vehiclesList.elementAt(index));
                                                                                widget.onDeleteOfVehicle(vehiclesList.elementAt(index), _newVehicleReplacing);
                                                                                firestoreSetCurrentVehicle(user: FirebaseAuth.instance.currentUser!, currentVehicle: _newVehicleReplacing);
                                                                                _selectedVehicle = currentVehicle;
                                                                                vehiclesList.remove(vehiclesList.elementAt(index));
                                                                              });
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                      content:
                                                                          Wrap(
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        spacing:
                                                                            4,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text("Select a vehicle to replace for trips made on ${vehiclesList.elementAt(index)}"),
                                                                          ),
                                                                          DropdownButton(
                                                                            value:
                                                                                _newVehicleReplacing,
                                                                            onChanged:
                                                                                (value) {
                                                                              editDialogSetState(
                                                                                () {
                                                                                  setStateDialog(() {
                                                                                    _newVehicleReplacing = value.toString();
                                                                                  });
                                                                                },
                                                                              );
                                                                            },
                                                                            items:
                                                                                List.generate(
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
                                                              context:
                                                                  editVehiclesContext,
                                                              builder:
                                                                  (bcontext) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      "Atleast one vehicle is needed"),
                                                                  content: Text(
                                                                      "Atleast one vehicle is required. If you wish to delete ${vehiclesList.elementAt(index)}, create a new vehicle and then delete ${vehiclesList.elementAt(index)}."),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            bcontext);
                                                                      },
                                                                      child: const Text(
                                                                          "Close"),
                                                                    )
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.delete),
                                                    ),
                                                  ));
                                                }
                                                TextEditingController
                                                    newVehicleController =
                                                    TextEditingController();
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Edit Vehicles List"),
                                                  content: Scrollbar(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            controller:
                                                                newVehicleController,
                                                            decoration: InputDecoration(
                                                                suffixIcon: IconButton(
                                                                    onPressed: () {
                                                                      currentVehicle =
                                                                          newVehicleController
                                                                              .text;
                                                                      firestoreCreateNewVehicle(
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser!,
                                                                          newVehicleController
                                                                              .text);
                                                                      firestoreSetCurrentVehicle(
                                                                          user: FirebaseAuth
                                                                              .instance
                                                                              .currentUser!,
                                                                          currentVehicle:
                                                                              newVehicleController.text);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    icon: const Icon(Icons.done)),
                                                                hintText: "New Vehicle"),
                                                            onSubmitted: (value) =>
                                                                editDialogSetState(
                                                                    () {
                                                              setState(() {
                                                                firestoreCreateNewVehicle(
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!,
                                                                    newVehicleController
                                                                        .text);
                                                                firestoreSetCurrentVehicle(
                                                                    user: FirebaseAuth
                                                                        .instance
                                                                        .currentUser!,
                                                                    currentVehicle:
                                                                        newVehicleController
                                                                            .text);
                                                                currentVehicle =
                                                                    newVehicleController
                                                                        .text;
                                                              });
                                                            }),
                                                          ),
                                                          ...items
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            statefulEditVehiclesContext);
                                                      },
                                                      child: const Text("Done"),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                    },
                                    child: const Text("Edit"),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              width: double.maxFinite,
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 14),
                                      child: const Text("Default Graph Tab: ")),
                                  DropdownButton(
                                    value: _selectedDefaultGraphTabIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDefaultGraphTabIndex = value!;
                                        firestoreSetDefaultGraphTabIndex(
                                            FirebaseAuth.instance.currentUser!,
                                            _selectedDefaultGraphTabIndex);
                                      });
                                    },
                                    items: List.generate(
                                      [
                                        "Mileage",
                                        "Distance",
                                        "Duration",
                                        "Average Speed",
                                        "Fuel Consumption",
                                        "Fuel Expenditure",
                                      ].length,
                                      (index) {
                                        return DropdownMenuItem(
                                          value: index,
                                          child: Row(
                                            children: [
                                              Text(
                                                [
                                                  "Mileage",
                                                  "Distance",
                                                  "Duration",
                                                  "Average Speed",
                                                  "Fuel Consumption",
                                                  "Fuel Expenditure",
                                                ].elementAt(index),
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                      "Price per ${kUnits == Units.km ? "litre" : "gallon"} of fuel:"),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Text(kPricePerUnitOfFuel.toString()),
                                  IconButton(
                                    onPressed: () {
                                      void saveFuelPrice(
                                          editPricePerUnitOfFuel) {
                                        kPricePerUnitOfFuel = double.parse(
                                            pricePerUnitOfFuel.text.toString());
                                        firestoreSetPricePerUnitOfFuel(
                                          FirebaseAuth.instance.currentUser!,
                                          kPricePerUnitOfFuel,
                                        );
                                        Navigator.pop(editPricePerUnitOfFuel);
                                      }

                                      showDialog(
                                          context: context,
                                          builder: (editPricePerUnitOfFuel) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Edit Price Per Unit Of Fuel"),
                                              content: TextField(
                                                controller: pricePerUnitOfFuel,
                                                onSubmitted: (_) {
                                                  saveFuelPrice(
                                                      editPricePerUnitOfFuel);
                                                },
                                                decoration: InputDecoration(
                                                  suffix: IconButton(
                                                      onPressed: () {
                                                        saveFuelPrice(
                                                            editPricePerUnitOfFuel);
                                                      },
                                                      icon: const Icon(
                                                        Icons.check,
                                                        color: kPurpleDarkShade,
                                                      )),
                                                ),
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(),
                                              ),
                                            );
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: kPurpleDarkShade,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  );
                }),
              );
            } else {
              return SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: const Center(child: CircularProgressIndicator()));
            }
          },
        );
      },
      onClosing: () {
        Navigator.pop(context);
      },
    );
  }
}
