import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:trip_history/controllers/firestore_operations.dart';
import '../components/settings_bottom_sheet_dialog.dart';
import '../components/tripdialog_bottom_sheet.dart';
import '../constants.dart';
import '../controllers/graph_layout_delegate.dart';
import '../models/trip_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<TripDetails> data = [
  //   TripDetails(
  //     dateTime: DateTime(2016).millisecondsSinceEpoch,
  //     mileage: 29,
  //     distance: 900,
  //     duration: 13,
  //     id: "123jh4k1234",
  //     tripTitle: "Mangolore Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "Amaze",
  //   ),
  //   TripDetails(
  //     dateTime: DateTime(2017).millisecondsSinceEpoch,
  //     mileage: 30.5,
  //     distance: 758,
  //     duration: 11,
  //     id: "123jh4k1234",
  //     tripTitle: "Banglore Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "KTM",
  //   ),
  //   TripDetails(
  //     dateTime: DateTime(2018).millisecondsSinceEpoch,
  //     mileage: 31,
  //     distance: 700,
  //     duration: 10,
  //     id: "123jh4k1234",
  //     tripTitle: "Mysore Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "KTM",
  //   ),
  //   TripDetails(
  //     dateTime: DateTime(2019).millisecondsSinceEpoch,
  //     mileage: 33,
  //     distance: 800,
  //     duration: 12,
  //     id: "123jh4k1234",
  //     tripTitle: "Pondicherry Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "KTM",
  //   ),
  //   TripDetails(
  //     dateTime: DateTime(2020).millisecondsSinceEpoch,
  //     mileage: 32,
  //     distance: 1200,
  //     duration: 15,
  //     id: "123jh4k1234",
  //     tripTitle: "Lonovola Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "Amaze",
  //   ),
  //   TripDetails(
  //     dateTime: DateTime(2022).millisecondsSinceEpoch,
  //     mileage: 32,
  //     distance: 1200,
  //     duration: 15,
  //     id: "123jh4k1234",
  //     tripTitle: "Lonovola 2 Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "XL6",
  //   ),
  //   TripDetails(
  //     dateTime: DateTime(2021).millisecondsSinceEpoch,
  //     mileage: 34,
  //     distance: 1100,
  //     duration: 14,
  //     id: "123jh4k1234",
  //     tripTitle: "Goa Trip",
  //     distanceUnits: DistanceUnits.km,
  //     vehicleName: "Amaze",
  //   ),
  // ];

  final GlobalKey<_SelectedGraphTextWidgetState> _key = GlobalKey();

  List chartData = [];
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () async {
      Brightness systemTheme =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      await firestoreSetTheme(FirebaseAuth.instance.currentUser!,
          (systemTheme == Brightness.light) ? "light" : "dark");
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(firestoreCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
        if (!documentSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        currentVehicle = documentSnapshot.data!.get('currentVehicle');
        if (documentSnapshot.data!.get('theme') == "light") {
          kBrightness = Brightness.light;
          isLightThemeModeStreamController.add(true);
        } else if (documentSnapshot.data!.get('theme') == "dark") {
          kBrightness = Brightness.dark;
          isLightThemeModeStreamController.add(false);
        } else {
          {
            kBrightness = SchedulerBinding.instance.window.platformBrightness;
            isLightThemeModeStreamController
                .add((kBrightness == Brightness.light) ? true : false);
          }
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(firestoreCollection)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("Trips")
              .snapshots(),
          builder: (context, collectionSnapshot) {
            if (!collectionSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            vehicleTripsData = [];
            chartData = [];
            List<TripDetails> data = [];
            for (var element in collectionSnapshot.data!.docs) {
              data.add(
                TripDetails(
                  dateTime: element['dateTime'],
                  mileage: element['mileage'].toDouble(),
                  distance: element['distance'].toDouble(),
                  duration: element['duration'].toDouble(),
                  id: element['id'],
                  tripTitle: element['tripTitle'],
                  distanceUnits: (element['distanceUnits'] == "km")
                      ? DistanceUnits.km
                      : DistanceUnits.mi,
                  vehicleName: element['vehicleName'],
                ),
              );
            }
            vehiclesList = {};
            for (TripDetails trip in data) {
              vehiclesList.add(trip.vehicleName);
              if (currentVehicle == "") {
                currentVehicle = vehiclesList.first;
              }
              if (trip.vehicleName == currentVehicle) {
                vehicleTripsData.add(trip);
              }
            }

            vehicleTripsData.sort((a, b) => a.dateTime.compareTo(b.dateTime));
            for (var trip in vehicleTripsData) {
              chartData.add([
                DateTime.fromMillisecondsSinceEpoch(trip.dateTime),
                trip.mileage.floor()
              ]);
            }
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(currentVehicle),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu),
                    onSelected: (st) {},
                    itemBuilder: (BuildContext context) {
                      return {'Logout', 'Settings'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                          onTap: () {
                            Future.delayed(const Duration(seconds: 0), () {
                              if (choice == "Settings") {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (_) => SettingsDialog(
                                          vehicleTrips: vehicleTripsData,
                                          replaceVehicleInTrips:
                                              (vehicleToBeReplaced,
                                                  vehicleReplacing) {
                                            setState(() {
                                              for (var element
                                                  in vehicleTripsData) {
                                                if (element.vehicleName ==
                                                    vehicleToBeReplaced) {
                                                  element.vehicleName =
                                                      vehicleReplacing;
                                                }
                                              }
                                            });
                                          },
                                          setSelectedVehicleInHomeScreen:
                                              (String newVehicle) {
                                            setState(() {
                                              currentVehicle = newVehicle;
                                            });
                                          },
                                          onChangeDistanceUnits:
                                              (DistanceUnits distanceUnits) {
                                            setState(() {
                                              for (int index = 0;
                                                  index <
                                                      vehicleTripsData.length;
                                                  index++) {
                                                DistanceUnits
                                                    prevDistanceUnits =
                                                    vehicleTripsData[index]
                                                        .distanceUnits;
                                                vehicleTripsData[index]
                                                        .distanceUnits =
                                                    distanceUnits;

                                                if (distanceUnits ==
                                                        DistanceUnits.km &&
                                                    distanceUnits !=
                                                        prevDistanceUnits) {
                                                  vehicleTripsData[index]
                                                          .distanceUnits =
                                                      DistanceUnits.km;
                                                  vehicleTripsData[index]
                                                          .distance =
                                                      double.parse(
                                                          (vehicleTripsData[
                                                                          index]
                                                                      .distance *
                                                                  1.609)
                                                              .toStringAsFixed(
                                                                  2));
                                                  vehicleTripsData[index]
                                                          .mileage =
                                                      double.parse(
                                                          (vehicleTripsData[
                                                                          index]
                                                                      .mileage /
                                                                  2.352)
                                                              .toStringAsFixed(
                                                                  2));
                                                }

                                                if (distanceUnits ==
                                                        DistanceUnits.mi &&
                                                    distanceUnits !=
                                                        prevDistanceUnits) {
                                                  vehicleTripsData[index]
                                                          .distanceUnits =
                                                      DistanceUnits.mi;

                                                  vehicleTripsData[index]
                                                          .distance =
                                                      double.parse(
                                                          (vehicleTripsData[
                                                                          index]
                                                                      .distance /
                                                                  1.609)
                                                              .toStringAsFixed(
                                                                  2));
                                                  vehicleTripsData[index]
                                                          .mileage =
                                                      double.parse(
                                                          (vehicleTripsData[
                                                                          index]
                                                                      .mileage *
                                                                  2.352)
                                                              .toStringAsFixed(
                                                                  2));
                                                }
                                              }
                                            });
                                          },
                                        ));
                              } else if (choice == "Logout") {
                                FirebaseAuth.instance.signOut();
                              }
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(top: 18, left: 18, right: 18),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total distance travelled: ",
                                  style: semiBold18(),
                                ),
                                Text(
                                  (vehicleTripsData.isNotEmpty)
                                      ? "Average ${(vehicleTripsData[0].distanceUnits == DistanceUnits.km) ? 'km/l' : 'mpg'}:"
                                      : "Average km/l:",
                                  style: semiBold18(),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((vehicleTripsData.isNotEmpty)
                                    ? "${[
                                        for (TripDetails trip
                                            in vehicleTripsData)
                                          trip.distance
                                      ].fold(0, (p, c) => (p + c).toInt())}${(vehicleTripsData[0].distanceUnits == DistanceUnits.km) ? 'km' : 'mi'}"
                                    : "0km"),
                                Text((vehicleTripsData.isNotEmpty)
                                    ? "${([
                                          for (TripDetails trip
                                              in vehicleTripsData)
                                            trip.mileage
                                        ].fold(0, (p, c) => (p + c).toInt()) / vehicleTripsData.length).toStringAsFixed(2)}${(vehicleTripsData[0].distanceUnits == DistanceUnits.km) ? 'km/l' : 'mpg'}"
                                    : "0${(distanceUnits == DistanceUnits.km) ? 'km/l' : 'mpg'}"),
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: CustomMultiChildLayout(
                            delegate:
                                GraphLayoutDelegate(position: Offset.zero),
                            children: [
                              LayoutId(
                                id: 1,
                                child: SelectedGraphTextWidget(key: _key),
                              ),
                              LayoutId(
                                id: 2,
                                child: charts.TimeSeriesChart(
                                  [
                                    charts.Series(
                                      colorFn: (__, ___) =>
                                          charts.ColorUtil.fromDartColor(
                                              (kBrightness == Brightness.light)
                                                  ? kPurpleDarkShade
                                                  : kPurpleLightShade),
                                      id: "Mileage",
                                      data: chartData,
                                      domainFn: (dat, _) => dat[0],
                                      measureFn: (dat, _) => dat[1],
                                    )
                                  ],
                                  animate: true,
                                  defaultRenderer: charts.LineRendererConfig(
                                      includePoints: true),
                                  selectionModels: [
                                    charts.SelectionModelConfig(
                                        type: charts.SelectionModelType.info,
                                        changedListener: (model) {
                                          TripDetails selectedPoint =
                                              vehicleTripsData[
                                                  chartData.indexOf(model
                                                      .selectedDatum
                                                      .first
                                                      .datum)];

                                          String dateTime =
                                              "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))}";

                                          String mileage = selectedPoint.mileage
                                              .toDouble()
                                              .toString();

                                          _key.currentState!.setValues(
                                              mileage,
                                              dateTime,
                                              vehicleTripsData[0]
                                                  .distanceUnits);
                                          _key.currentState!.update();
                                        })
                                  ],
                                  behaviors: [
                                    charts.ChartTitle(
                                      "Trips",
                                      titleOutsideJustification:
                                          charts.OutsideJustification.start,
                                      titleStyleSpec: (kBrightness ==
                                              Brightness.light)
                                          ? const charts.TextStyleSpec(
                                              color:
                                                  charts.MaterialPalette.black)
                                          : const charts.TextStyleSpec(
                                              color:
                                                  charts.MaterialPalette.white),
                                      innerPadding: 24,
                                    ),
                                    charts.ChartTitle(
                                      (vehicleTripsData.isNotEmpty)
                                          ? (vehicleTripsData[0]
                                                      .distanceUnits ==
                                                  DistanceUnits.km)
                                              ? "km/l"
                                              : "mpg"
                                          : (distanceUnits == DistanceUnits.km)
                                              ? "km/l"
                                              : "mpg",
                                      behaviorPosition:
                                          charts.BehaviorPosition.start,
                                      titleStyleSpec: (kBrightness ==
                                              Brightness.light)
                                          ? const charts.TextStyleSpec(
                                              color:
                                                  charts.MaterialPalette.black)
                                          : const charts.TextStyleSpec(
                                              color:
                                                  charts.MaterialPalette.white),
                                    )
                                  ],
                                  primaryMeasureAxis: charts.NumericAxisSpec(
                                      renderSpec: charts.GridlineRendererSpec(
                                    labelStyle: charts.TextStyleSpec(
                                        fontSize: 10,
                                        color: (kBrightness == Brightness.light)
                                            ? charts.MaterialPalette.black
                                            : charts.MaterialPalette.white),
                                  )),
                                  domainAxis: charts.DateTimeAxisSpec(
                                    renderSpec: charts.GridlineRendererSpec(
                                      labelStyle: charts.TextStyleSpec(
                                          fontSize: 10,
                                          color: (kBrightness ==
                                                  Brightness.light)
                                              ? charts.MaterialPalette.black
                                              : charts.MaterialPalette.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recent trips",
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: (vehicleTripsData.isNotEmpty)
                                        ? vehicleTripsData.length
                                        : 0,
                                    itemBuilder: (bContext, position) {
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (buildContext) {
                                                    return TripDialog(
                                                      tripDialogMode:
                                                          TripDialogMode.edit,
                                                      initTripName:
                                                          vehicleTripsData[
                                                                  position]
                                                              .tripTitle,
                                                      initDist:
                                                          vehicleTripsData[
                                                                  position]
                                                              .distance,
                                                      initDur: vehicleTripsData[
                                                              position]
                                                          .duration,
                                                      initDateInMilliSeconds:
                                                          vehicleTripsData[
                                                                  position]
                                                              .dateTime,
                                                      initMileage:
                                                          vehicleTripsData[
                                                                  position]
                                                              .mileage,
                                                    );
                                                  });
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: (kBrightness ==
                                                          Brightness.light)
                                                      ? kPurpleLightShade
                                                      : kPurpleDarkShade,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(18),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            vehicleTripsData[
                                                                    position]
                                                                .tripTitle,
                                                          ),
                                                          Text(DateFormat
                                                                  .yMMMd()
                                                              .format(DateTime.fromMillisecondsSinceEpoch(
                                                                  vehicleTripsData[
                                                                          position]
                                                                      .dateTime)))
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "${vehicleTripsData[position].distance}${(vehicleTripsData[position].distanceUnits == DistanceUnits.km) ? 'km' : 'mi'}"),
                                                          Text(
                                                              "${vehicleTripsData[position].mileage} ${(vehicleTripsData[position].distanceUnits == DistanceUnits.km) ? 'km/l' : 'mpg'}"),
                                                          Text(
                                                              "${vehicleTripsData[position].duration}hrs"),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                          const SizedBox(
                                            height: 18,
                                          )
                                        ],
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text("Add"),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (buildContext) {
                        return const TripDialog(
                          tripDialogMode: TripDialogMode.create,
                        );
                      });
                },
                // backgroundColor: Colors.lightBlueAccent[50],
              ),
            );
          },
        );
      },
    );
  }
}

class SelectedGraphTextWidget extends StatefulWidget {
  const SelectedGraphTextWidget({
    super.key,
  });

  @override
  State<SelectedGraphTextWidget> createState() =>
      _SelectedGraphTextWidgetState();
}

class _SelectedGraphTextWidgetState extends State<SelectedGraphTextWidget> {
  String mileage = "", dateString = "";
  DistanceUnits distanceUnits = DistanceUnits.km;
  setValues(mil, date, setDistanceUnits) {
    mileage = mil;
    dateString = date;
    distanceUnits = setDistanceUnits;
  }

  update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      mileage != ""
          ? "$mileage ${(distanceUnits == DistanceUnits.km) ? 'km/l' : 'mpg'} on $dateString"
          : "",
      textAlign: TextAlign.end,
    );
  }
}
