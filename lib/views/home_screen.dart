import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
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
  List<TripDetails> data = [
    TripDetails(
      dateTime: DateTime(2016).millisecondsSinceEpoch,
      mileage: 29,
      dist: 900,
      dur: 13,
      id: "123jh4k1234",
      name: "Mangolore Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "Amaze",
    ),
    TripDetails(
      dateTime: DateTime(2017).millisecondsSinceEpoch,
      mileage: 30.5,
      dist: 758,
      dur: 11,
      id: "123jh4k1234",
      name: "Banglore Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "KTM",
    ),
    TripDetails(
      dateTime: DateTime(2018).millisecondsSinceEpoch,
      mileage: 31,
      dist: 700,
      dur: 10,
      id: "123jh4k1234",
      name: "Mysore Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "KTM",
    ),
    TripDetails(
      dateTime: DateTime(2019).millisecondsSinceEpoch,
      mileage: 33,
      dist: 800,
      dur: 12,
      id: "123jh4k1234",
      name: "Pondicherry Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "KTM",
    ),
    TripDetails(
      dateTime: DateTime(2020).millisecondsSinceEpoch,
      mileage: 32,
      dist: 1200,
      dur: 15,
      id: "123jh4k1234",
      name: "Lonovola Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "Amaze",
    ),
    TripDetails(
      dateTime: DateTime(2022).millisecondsSinceEpoch,
      mileage: 32,
      dist: 1200,
      dur: 15,
      id: "123jh4k1234",
      name: "Lonovola 2 Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "XL6",
    ),
    TripDetails(
      dateTime: DateTime(2021).millisecondsSinceEpoch,
      mileage: 34,
      dist: 1100,
      dur: 14,
      id: "123jh4k1234",
      name: "Goa Trip",
      distanceUnits: DistanceUnits.km,
      vehicleName: "Amaze",
    ),
  ];

  final GlobalKey<_SelectedGraphTextWidgetState> _key = GlobalKey();

  List chartData = [];
  @override
  void initState() {
    super.initState();
    final window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    vehicleTripsData = [];
    chartData = [];
    for (TripDetails trip in data) {
      vehicles.add(trip.vehicleName);
      if (currentVehicle == "") {
        currentVehicle = vehicles.first;
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
                                      (vehicleToBeReplaced, vehicleReplacing) {
                                    setState(() {
                                      for (var element in vehicleTripsData) {
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
                                          index < vehicleTripsData.length;
                                          index++) {
                                        DistanceUnits prevDistanceUnits =
                                            vehicleTripsData[index]
                                                .distanceUnits;
                                        vehicleTripsData[index].distanceUnits =
                                            distanceUnits;

                                        if (distanceUnits == DistanceUnits.km &&
                                            distanceUnits !=
                                                prevDistanceUnits) {
                                          vehicleTripsData[index]
                                              .distanceUnits = DistanceUnits.km;
                                          vehicleTripsData[index].dist =
                                              double.parse(
                                                  (vehicleTripsData[index]
                                                              .dist *
                                                          1.609)
                                                      .toStringAsFixed(2));
                                          vehicleTripsData[index].mileage =
                                              double.parse(
                                                  (vehicleTripsData[index]
                                                              .mileage /
                                                          2.352)
                                                      .toStringAsFixed(2));
                                        }

                                        if (distanceUnits == DistanceUnits.mi &&
                                            distanceUnits !=
                                                prevDistanceUnits) {
                                          vehicleTripsData[index]
                                              .distanceUnits = DistanceUnits.mi;

                                          vehicleTripsData[index].dist =
                                              double.parse(
                                                  (vehicleTripsData[index]
                                                              .dist /
                                                          1.609)
                                                      .toStringAsFixed(2));
                                          vehicleTripsData[index].mileage =
                                              double.parse(
                                                  (vehicleTripsData[index]
                                                              .mileage *
                                                          2.352)
                                                      .toStringAsFixed(2));
                                        }
                                      }
                                    });
                                  },
                                ));
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
                                for (TripDetails trip in vehicleTripsData)
                                  trip.dist
                              ].fold(0, (p, c) => (p + c).toInt())}${(vehicleTripsData[0].distanceUnits == DistanceUnits.km) ? 'km' : 'mi'}"
                            : "0km"),
                        Text((vehicleTripsData.isNotEmpty)
                            ? "${([
                                  for (TripDetails trip in vehicleTripsData)
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
                    delegate: GraphLayoutDelegate(position: Offset.zero),
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
                                      (SchedulerBinding.instance.window
                                                  .platformBrightness ==
                                              Brightness.light)
                                          ? purpleDarkShade
                                          : purpleLightShade),
                              id: "Mileage",
                              data: chartData,
                              domainFn: (dat, _) => dat[0],
                              measureFn: (dat, _) => dat[1],
                            )
                          ],
                          animate: true,
                          defaultRenderer:
                              charts.LineRendererConfig(includePoints: true),
                          selectionModels: [
                            charts.SelectionModelConfig(
                                type: charts.SelectionModelType.info,
                                changedListener: (model) {
                                  TripDetails selectedPoint = vehicleTripsData[
                                      chartData.indexOf(
                                          model.selectedDatum.first.datum)];

                                  String dateTime =
                                      "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))}";

                                  String mileage = selectedPoint.mileage
                                      .toDouble()
                                      .toString();

                                  _key.currentState!.setValues(
                                      mileage,
                                      dateTime,
                                      vehicleTripsData[0].distanceUnits);
                                  _key.currentState!.update();
                                })
                          ],
                          behaviors: [
                            charts.ChartTitle(
                              "Trips",
                              titleOutsideJustification:
                                  charts.OutsideJustification.start,
                              titleStyleSpec: (SchedulerBinding
                                          .instance.window.platformBrightness ==
                                      Brightness.light)
                                  ? const charts.TextStyleSpec(
                                      color: charts.MaterialPalette.black)
                                  : const charts.TextStyleSpec(
                                      color: charts.MaterialPalette.white),
                              innerPadding: 24,
                            ),
                            charts.ChartTitle(
                              (vehicleTripsData.isNotEmpty)
                                  ? (vehicleTripsData[0].distanceUnits ==
                                          DistanceUnits.km)
                                      ? "km/l"
                                      : "mpg"
                                  : (distanceUnits == DistanceUnits.km)
                                      ? "km/l"
                                      : "mpg",
                              behaviorPosition: charts.BehaviorPosition.start,
                              titleStyleSpec: (SchedulerBinding
                                          .instance.window.platformBrightness ==
                                      Brightness.light)
                                  ? const charts.TextStyleSpec(
                                      color: charts.MaterialPalette.black)
                                  : const charts.TextStyleSpec(
                                      color: charts.MaterialPalette.white),
                            )
                          ],
                          primaryMeasureAxis: charts.NumericAxisSpec(
                              renderSpec: charts.GridlineRendererSpec(
                            labelStyle: charts.TextStyleSpec(
                                fontSize: 10,
                                color: (SchedulerBinding.instance.window
                                            .platformBrightness ==
                                        Brightness.light)
                                    ? charts.MaterialPalette.black
                                    : charts.MaterialPalette.white),
                          )),
                          domainAxis: charts.DateTimeAxisSpec(
                            renderSpec: charts.GridlineRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                  fontSize: 10,
                                  color: (SchedulerBinding.instance.window
                                              .platformBrightness ==
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
                                                  vehicleTripsData[position]
                                                      .name,
                                              initDist:
                                                  vehicleTripsData[position]
                                                      .dist,
                                              initDur:
                                                  vehicleTripsData[position]
                                                      .dur,
                                              initDateInMilliSeconds:
                                                  vehicleTripsData[position]
                                                      .dateTime,
                                              initMileage:
                                                  vehicleTripsData[position]
                                                      .mileage,
                                            );
                                          });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (SchedulerBinding
                                                      .instance
                                                      .window
                                                      .platformBrightness ==
                                                  Brightness.light)
                                              ? purpleLightShade
                                              : purpleDarkShade,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(18),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    vehicleTripsData[position]
                                                        .name,
                                                  ),
                                                  Text(DateFormat.yMMMd()
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
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
                                                      "${vehicleTripsData[position].dist}${(vehicleTripsData[position].distanceUnits == DistanceUnits.km) ? 'km' : 'mi'}"),
                                                  Text(
                                                      "${vehicleTripsData[position].mileage} ${(vehicleTripsData[position].distanceUnits == DistanceUnits.km) ? 'km/l' : 'mpg'}"),
                                                  Text(
                                                      "${vehicleTripsData[position].dur}hrs"),
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
