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
import 'package:collection/collection.dart';

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

  final GlobalKey<_SelectedGraphTextWidgetState> _tab1Key = GlobalKey();
  final GlobalKey<_SelectedGraphTextWidgetState> _tab2Key = GlobalKey();
  final GlobalKey<_SelectedGraphTextWidgetState> _tab3Key = GlobalKey();
  final GlobalKey<_SelectedGraphTextWidgetState> _tab4Key = GlobalKey();
  TextEditingController newUserVehicle = TextEditingController();

  final _scrollController = ScrollController();

  List mileageChartData = [];
  List distanceChartData = [];
  List durationChartData = [];
  List averageSpeedChartData = [];

  List<TripDetails> mileageVehicleTripsData = [];
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () async {
      if (await firestoreGetIsSystemTheme(FirebaseAuth.instance.currentUser!) ==
          true) {
        Brightness systemTheme =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        if (FirebaseAuth.instance.currentUser != null) {
          await firestoreSetTheme(FirebaseAuth.instance.currentUser!,
              (systemTheme == Brightness.light) ? "light" : "dark");
        }
      }
      setState(() {});
    };
  }

  void onChangeUnits(Units units) {
    setState(() {
      for (int index = 0; index < vehicleTripsData.length; index++) {
        Units prevUnits = vehicleTripsData[index].units;
        vehicleTripsData[index].units = units;

        if (units == Units.km && units != prevUnits) {
          vehicleTripsData[index].units = Units.km;
          vehicleTripsData[index].distance = double.parse(
              (vehicleTripsData[index].distance * 1.609).toStringAsFixed(2));
          vehicleTripsData[index].mileage = double.parse(
              ((vehicleTripsData[index].mileage != null)
                      ? vehicleTripsData[index].mileage! / 2.352
                      : 0 / 2.352)
                  .toStringAsFixed(2));
        }

        if (units == Units.mi && units != prevUnits) {
          vehicleTripsData[index].units = Units.mi;

          vehicleTripsData[index].distance = double.parse(
              (vehicleTripsData[index].distance / 1.609).toStringAsFixed(2));
          vehicleTripsData[index].mileage = double.parse(
              ((vehicleTripsData[index].mileage != null)
                      ? vehicleTripsData[index].mileage! * 2.352
                      : 0 * 2.352)
                  .toStringAsFixed(2));
        }
        firestoreUpdateTrip(
            user: FirebaseAuth.instance.currentUser!,
            updatedData: vehicleTripsData[index].toMap(),
            id: vehicleTripsData[index].id);
      }
    });
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
          if (documentSnapshot.data!.get('newUser') == false) {
            currentVehicle = documentSnapshot.data!.get('currentVehicle');

            vehiclesList = documentSnapshot.data!.get('vehiclesList').toSet();

            int defaultGraphTabIndex =
                documentSnapshot.data!.get('defaultGraphTabIndex');

            if (documentSnapshot.data!.get('theme') == "light") {
              kBrightness = Brightness.light;
              isLightThemeModeStreamController.add(true);
            } else if (documentSnapshot.data!.get('theme') == "dark") {
              kBrightness = Brightness.dark;
              isLightThemeModeStreamController.add(false);
            } else {
              {
                kBrightness = SchedulerBinding
                    .instance.platformDispatcher.platformBrightness;
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
                mileageChartData = [];
                distanceChartData = [];
                durationChartData = [];
                mileageVehicleTripsData = [];
                averageSpeedChartData = [];
                List<TripDetails> data = [];
                for (var element in collectionSnapshot.data!.docs) {
                  var trip = TripDetails(
                    dateTime: element['dateTime'],
                    distance: element['distance'].toDouble(),
                    duration: element['duration'].toDouble(),
                    id: element['id'],
                    tripTitle: element['tripTitle'],
                    units: (element['units'] == "km") ? Units.km : Units.mi,
                    vehicleName: element['vehicleName'],
                  );
                  try {
                    trip.mileage = (element['mileage'].toDouble() != null)
                        ? element['mileage'].toDouble()
                        : 0;
                  } catch (e) {
                    trip.mileage = 0;
                  }
                  data.add(trip);
                }
                for (TripDetails trip in data) {
                  vehiclesList.add(trip.vehicleName);
                  if (currentVehicle == "") {
                    currentVehicle = vehiclesList.first;
                  }
                  if (trip.vehicleName == currentVehicle) {
                    vehicleTripsData.add(trip);
                  }
                }

                firestoreUpdateVehiclesList(
                    user: FirebaseAuth.instance.currentUser!,
                    vehiclesList: vehiclesList.toList());

                vehicleTripsData
                    .sort((b, a) => a.dateTime.compareTo(b.dateTime));

                for (var trip in vehicleTripsData) {
                  if (trip.mileage != 0) {
                    mileageVehicleTripsData.add(trip);
                    mileageChartData.add([
                      DateTime.fromMillisecondsSinceEpoch(trip.dateTime),
                      trip.mileage!.floor()
                    ]);
                  }
                  distanceChartData.add([
                    DateTime.fromMillisecondsSinceEpoch(trip.dateTime),
                    trip.distance
                  ]);
                  durationChartData.add([
                    DateTime.fromMillisecondsSinceEpoch(trip.dateTime),
                    trip.duration
                  ]);
                  averageSpeedChartData.add([
                    DateTime.fromMillisecondsSinceEpoch(trip.dateTime),
                    trip.distance / trip.duration
                  ]);
                }

                return FutureBuilder(
                  future: firestoreGetUnits(FirebaseAuth.instance.currentUser!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      kUnits = (snapshot.data == "km") ? Units.km : Units.mi;
                      if (vehicleTripsData.isNotEmpty &&
                          vehicleTripsData[0].units != kUnits) {
                        for (int index = 0;
                            index < vehicleTripsData.length;
                            index++) {
                          Units prevUnits = vehicleTripsData[index].units;
                          vehicleTripsData[index].units = kUnits;

                          if (kUnits == Units.km && kUnits != prevUnits) {
                            vehicleTripsData[index].units = Units.km;
                            vehicleTripsData[index].distance = double.parse(
                                (vehicleTripsData[index].distance * 1.609)
                                    .toStringAsFixed(2));
                            vehicleTripsData[index].mileage = double.parse(
                                (vehicleTripsData[index].mileage! / 2.352)
                                    .toStringAsFixed(2));
                          }

                          if (kUnits == Units.mi && kUnits != prevUnits) {
                            vehicleTripsData[index].units = Units.mi;

                            vehicleTripsData[index].distance = double.parse(
                                (vehicleTripsData[index].distance / 1.609)
                                    .toStringAsFixed(2));
                            vehicleTripsData[index].mileage = double.parse(
                                (vehicleTripsData[index].mileage! * 2.352)
                                    .toStringAsFixed(2));
                          }
                          firestoreUpdateTrip(
                              user: FirebaseAuth.instance.currentUser!,
                              updatedData: vehicleTripsData[index].toMap(),
                              id: vehicleTripsData[index].id);
                        }
                      }

                      List<Widget> tabs = [
                        const Tab(
                          // icon: Icon(Icons.local_gas_station_outlined),
                          text: "Mileage",
                          iconMargin: EdgeInsets.only(bottom: 5),
                        ),
                        const Tab(
                          // icon: Icon(Icons.pin_drop_outlined),
                          text: "Distance",
                          iconMargin: EdgeInsets.only(bottom: 5),
                        ),
                        const Tab(
                          // icon: Icon(Icons.timer),
                          text: "Duration",
                          iconMargin: EdgeInsets.only(bottom: 5),
                        ),
                        const Tab(
                          // icon: Icon(Icons.speed),
                          text: "Average\nSpeed",
                          iconMargin: EdgeInsets.only(bottom: 5),
                        )
                      ];

                      List<Widget> views = [
                        // TAB 1 - Mileage
                        Column(
                          children: [
                            Expanded(
                              child: CustomMultiChildLayout(
                                delegate:
                                    GraphLayoutDelegate(position: Offset.zero),
                                children: [
                                  LayoutId(
                                    id: 1,
                                    child:
                                        SelectedGraphTextWidget(key: _tab1Key),
                                  ),
                                  LayoutId(
                                    id: 2,
                                    child: charts.TimeSeriesChart(
                                      [
                                        charts.Series(
                                          colorFn: (__, ___) =>
                                              charts.ColorUtil.fromDartColor(
                                                  (kBrightness ==
                                                          Brightness.light)
                                                      ? kPurpleDarkShade
                                                      : kPurpleLightShade),
                                          id: "Mileage",
                                          data: mileageChartData,
                                          domainFn: (dat, _) => dat[0],
                                          measureFn: (dat, _) => dat[1],
                                        )
                                      ],
                                      animate: true,
                                      defaultRenderer:
                                          charts.LineRendererConfig(
                                              includePoints: true),
                                      selectionModels: [
                                        charts.SelectionModelConfig(
                                            type:
                                                charts.SelectionModelType.info,
                                            changedListener: (model) {
                                              TripDetails selectedPoint =
                                                  mileageVehicleTripsData[
                                                      mileageChartData.indexOf(
                                                          model.selectedDatum
                                                              .first.datum)];

                                              String dateTime =
                                                  "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))}";

                                              String mileage = selectedPoint
                                                  .mileage!
                                                  .toDouble()
                                                  .toString();

                                              _tab1Key.currentState!.setValues(
                                                mil: mileage,
                                                date: dateTime,
                                                setUnits:
                                                    vehicleTripsData[0].units,
                                                dist: selectedPoint.distance
                                                    .toString(),
                                                dur: selectedPoint.duration
                                                    .toString(),
                                                gMode: GraphMode.mileage,
                                              );
                                              _tab1Key.currentState!.update();
                                            })
                                      ],
                                      behaviors: [
                                        charts.ChartTitle(
                                          "Trips",
                                          titleOutsideJustification:
                                              charts.OutsideJustification.start,
                                          titleStyleSpec:
                                              (kBrightness == Brightness.light)
                                                  ? const charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .black)
                                                  : const charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .white),
                                          innerPadding: 24,
                                        ),
                                        charts.ChartTitle(
                                          (vehicleTripsData.isNotEmpty)
                                              ? (vehicleTripsData[0].units ==
                                                      Units.km)
                                                  ? "km/l"
                                                  : "mpg"
                                              : (kUnits == Units.km)
                                                  ? "km/l"
                                                  : "mpg",
                                          behaviorPosition:
                                              charts.BehaviorPosition.start,
                                          titleStyleSpec:
                                              (kBrightness == Brightness.light)
                                                  ? const charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .black)
                                                  : const charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .white),
                                        )
                                      ],
                                      primaryMeasureAxis:
                                          charts.NumericAxisSpec(
                                              renderSpec:
                                                  charts.GridlineRendererSpec(
                                        labelStyle: charts.TextStyleSpec(
                                            fontSize: 10,
                                            color: (kBrightness ==
                                                    Brightness.light)
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
                                                  : charts
                                                      .MaterialPalette.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "Note: Trips without mileage will not be included in this graph*",
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        // TAB 2 - Distance
                        CustomMultiChildLayout(
                          delegate: GraphLayoutDelegate(position: Offset.zero),
                          children: [
                            LayoutId(
                              id: 1,
                              child: SelectedGraphTextWidget(key: _tab2Key),
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
                                    id: "Distance",
                                    data: distanceChartData,
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
                                                distanceChartData.indexOf(model
                                                    .selectedDatum
                                                    .first
                                                    .datum)];

                                        String dateTime =
                                            "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))}";

                                        String mileage = selectedPoint.mileage!
                                            .toDouble()
                                            .toString();

                                        _tab2Key.currentState!.setValues(
                                            mil: mileage,
                                            date: dateTime,
                                            setUnits: vehicleTripsData[0].units,
                                            dist: selectedPoint.distance
                                                .toString(),
                                            dur: selectedPoint.duration
                                                .toString(),
                                            gMode: GraphMode.distance);
                                        _tab2Key.currentState!.update();
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
                                            color: charts.MaterialPalette.black)
                                        : const charts.TextStyleSpec(
                                            color:
                                                charts.MaterialPalette.white),
                                    innerPadding: 24,
                                  ),
                                  charts.ChartTitle(
                                    "distance",
                                    behaviorPosition:
                                        charts.BehaviorPosition.start,
                                    titleStyleSpec: (kBrightness ==
                                            Brightness.light)
                                        ? const charts.TextStyleSpec(
                                            color: charts.MaterialPalette.black)
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
                                        color: (kBrightness == Brightness.light)
                                            ? charts.MaterialPalette.black
                                            : charts.MaterialPalette.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // TAB # - Duration
                        CustomMultiChildLayout(
                          delegate: GraphLayoutDelegate(position: Offset.zero),
                          children: [
                            LayoutId(
                              id: 1,
                              child: SelectedGraphTextWidget(key: _tab3Key),
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
                                    id: "Duration",
                                    data: durationChartData,
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
                                                durationChartData.indexOf(model
                                                    .selectedDatum
                                                    .first
                                                    .datum)];

                                        String dateTime =
                                            "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))}";

                                        String mileage = selectedPoint.mileage!
                                            .toDouble()
                                            .toString();

                                        _tab3Key.currentState!.setValues(
                                          mil: mileage,
                                          date: dateTime,
                                          setUnits: vehicleTripsData[0].units,
                                          dist:
                                              selectedPoint.distance.toString(),
                                          dur:
                                              selectedPoint.duration.toString(),
                                          gMode: GraphMode.duration,
                                        );
                                        _tab3Key.currentState!.update();
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
                                            color: charts.MaterialPalette.black)
                                        : const charts.TextStyleSpec(
                                            color:
                                                charts.MaterialPalette.white),
                                    innerPadding: 24,
                                  ),
                                  charts.ChartTitle(
                                    "hours",
                                    behaviorPosition:
                                        charts.BehaviorPosition.start,
                                    titleStyleSpec: (kBrightness ==
                                            Brightness.light)
                                        ? const charts.TextStyleSpec(
                                            color: charts.MaterialPalette.black)
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
                                        color: (kBrightness == Brightness.light)
                                            ? charts.MaterialPalette.black
                                            : charts.MaterialPalette.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Tab 4 - Average Trip Speed
                        CustomMultiChildLayout(
                          delegate: GraphLayoutDelegate(position: Offset.zero),
                          children: [
                            LayoutId(
                              id: 1,
                              child: SelectedGraphTextWidget(key: _tab4Key),
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
                                    id: "Average Speed",
                                    data: averageSpeedChartData,
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
                                                averageSpeedChartData.indexOf(
                                                    model.selectedDatum.first
                                                        .datum)];

                                        String dateTime =
                                            "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint.dateTime))}";

                                        String mileage = selectedPoint.mileage!
                                            .toDouble()
                                            .toString();

                                        _tab4Key.currentState!.setValues(
                                          mil: mileage,
                                          date: dateTime,
                                          setUnits: vehicleTripsData[0].units,
                                          dist:
                                              selectedPoint.distance.toString(),
                                          dur:
                                              selectedPoint.duration.toString(),
                                          gMode: GraphMode.averageSpeed,
                                        );
                                        _tab4Key.currentState!.update();
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
                                            color: charts.MaterialPalette.black)
                                        : const charts.TextStyleSpec(
                                            color:
                                                charts.MaterialPalette.white),
                                    innerPadding: 24,
                                  ),
                                  charts.ChartTitle(
                                    "Average Speed",
                                    behaviorPosition:
                                        charts.BehaviorPosition.start,
                                    titleStyleSpec: (kBrightness ==
                                            Brightness.light)
                                        ? const charts.TextStyleSpec(
                                            color: charts.MaterialPalette.black)
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
                                        color: (kBrightness == Brightness.light)
                                            ? charts.MaterialPalette.black
                                            : charts.MaterialPalette.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ];
                      return Scaffold(
                        resizeToAvoidBottomInset: false,
                        appBar: AppBar(
                          title: Text(currentVehicle),
                          actions: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.menu),
                              onSelected: (st) {},
                              itemBuilder: (BuildContext context) {
                                return {'Settings', 'Logout'}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                    onTap: () {
                                      Future.delayed(const Duration(seconds: 0),
                                          () {
                                        if (choice == "Settings") {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (_) => SettingsDialog(
                                                    // vehicleTrips:
                                                    //     vehicleTripsData,
                                                    // replaceVehicleInTrips:
                                                    //     (vehicleToBeReplaced,
                                                    //         vehicleReplacing) {
                                                    //   setState(() {
                                                    //     for (var element
                                                    //         in vehicleTripsData) {
                                                    //       if (element
                                                    //               .vehicleName ==
                                                    //           vehicleToBeReplaced) {
                                                    //         element.vehicleName =
                                                    //             vehicleReplacing;
                                                    //       }
                                                    //     }
                                                    //   });
                                                    // },
                                                    onDeleteOfVehicle: (String
                                                            deletingVehicle,
                                                        String
                                                            newVehicleReplacing) {
                                                      setState(() {
                                                        for (int index = 0;
                                                            index < data.length;
                                                            index++) {
                                                          if (data[index]
                                                                  .vehicleName ==
                                                              deletingVehicle) {
                                                            TripDetails
                                                                updatedTrip =
                                                                data[index];
                                                            updatedTrip
                                                                    .vehicleName =
                                                                newVehicleReplacing;
                                                            firestoreUpdateTrip(
                                                                user: FirebaseAuth
                                                                    .instance
                                                                    .currentUser!,
                                                                updatedData:
                                                                    updatedTrip
                                                                        .toMap(),
                                                                id: updatedTrip
                                                                    .id);
                                                          }
                                                        }
                                                      });
                                                    },
                                                    onChangeUnits: (Units
                                                            units) =>
                                                        onChangeUnits(units),
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
                        body: DefaultTabController(
                          initialIndex: defaultGraphTabIndex,
                          length: views.length,
                          child: SafeArea(
                            child: Scrollbar(
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 18, left: 18, right: 18),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: (MediaQuery.of(context)
                                                    .size
                                                    .height >=
                                                MediaQuery.of(context)
                                                    .size
                                                    .width)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1 /
                                                12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1 /
                                                12,
                                        child: Wrap(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Wrap(
                                                spacing: 8,
                                                alignment: WrapAlignment.center,
                                                children: [
                                                  Text(
                                                    "Total distance travelled: ",
                                                    style: semiBold18(),
                                                  ),
                                                  Text((vehicleTripsData
                                                          .isNotEmpty)
                                                      ? "${[
                                                          for (TripDetails trip
                                                              in vehicleTripsData)
                                                            trip.distance
                                                        ].sum.toStringAsFixed(2)} ${(kUnits == Units.km) ? 'km' : 'mi'}"
                                                      : "0km"),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Wrap(
                                                spacing: 8,
                                                alignment: WrapAlignment.center,
                                                children: [
                                                  Text(
                                                    (vehicleTripsData
                                                            .isNotEmpty)
                                                        ? "Average ${(kUnits == Units.km) ? 'km/l' : 'mpg'}:"
                                                        : "Average km/l:",
                                                    style: semiBold18(),
                                                  ),
                                                  Text((vehicleTripsData
                                                          .isNotEmpty)
                                                      ? "${(([
                                                            for (TripDetails trip
                                                                in vehicleTripsData)
                                                              (trip.mileage !=
                                                                      0)
                                                                  ? trip
                                                                      .mileage!
                                                                  : 0
                                                          ].sum / mileageVehicleTripsData.length)).toStringAsFixed(2)} ${(kUnits == Units.km) ? 'km/l' : 'mpg'}"
                                                      : "0${(kUnits == Units.km) ? 'km/l' : 'mpg'}"),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                5 /
                                                12,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TabBar(tabs: tabs),
                                            Expanded(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            4),
                                                child: TabBarView(
                                                  children: views,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: (vehicleTripsData
                                                        .isNotEmpty)
                                                    ? vehicleTripsData.length
                                                    : 0,
                                                itemBuilder:
                                                    (bContext, position) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        width: double.maxFinite,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                builder:
                                                                    (buildContext) {
                                                                  return TripDialog(
                                                                    tripDialogMode:
                                                                        TripDialogMode
                                                                            .edit,
                                                                    id: vehicleTripsData[
                                                                            position]
                                                                        .id,
                                                                    initTripName:
                                                                        vehicleTripsData[position]
                                                                            .tripTitle,
                                                                    initDist: vehicleTripsData[
                                                                            position]
                                                                        .distance,
                                                                    initDur: vehicleTripsData[
                                                                            position]
                                                                        .duration,
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
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: (kBrightness ==
                                                                        Brightness
                                                                            .light)
                                                                    ? kPurpleLightShade
                                                                    : kPurpleDarkShade,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          18),
                                                                ),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        kPurpleDarkShade),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: double
                                                                          .maxFinite,
                                                                      child:
                                                                          Wrap(
                                                                        alignment:
                                                                            WrapAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(vehicleTripsData[position].tripTitle.length > 16
                                                                              ? "${vehicleTripsData[position].tripTitle.substring(0, 13)}..."
                                                                              : vehicleTripsData[position].tripTitle),
                                                                          Text(
                                                                              "${vehicleTripsData[position].duration}hrs"),
                                                                          Text(DateFormat.yMMMd()
                                                                              .format(DateTime.fromMillisecondsSinceEpoch(vehicleTripsData[position].dateTime))),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    SizedBox(
                                                                      width: double
                                                                          .maxFinite,
                                                                      child:
                                                                          Wrap(
                                                                        alignment:
                                                                            WrapAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                              "${vehicleTripsData[position].distance}${(vehicleTripsData[position].units == Units.km) ? 'km' : 'mi'}"),
                                                                          Text(
                                                                              "${(vehicleTripsData[position].distance / vehicleTripsData[position].duration).toStringAsFixed(2)} ${(vehicleTripsData[position].units == Units.km) ? 'km/h' : 'mph'}"),
                                                                          (vehicleTripsData[position].mileage != 0)
                                                                              ? Text("${vehicleTripsData[position].mileage} ${(vehicleTripsData[position].units == Units.km) ? 'km/l' : 'mpg'}")
                                                                              : Container(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 18,
                                                      )
                                                    ],
                                                  );
                                                }),
                                            const SizedBox(
                                              height: 58,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
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
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
            );
          } else {
            void createNewVehicle(String vehicle) async {
              if (vehicle != "") {
                await firestoreSetCurrentVehicle(
                    user: FirebaseAuth.instance.currentUser!,
                    currentVehicle: vehicle);
                await firestoreCreateNewVehicle(
                    FirebaseAuth.instance.currentUser!, vehicle);
                await firestoreUpdateNewUser(
                    FirebaseAuth.instance.currentUser!, false);
              }
            }

            newUserVehicle.addListener(
              () {
                setState(() {});
              },
            );
            return Scaffold(
              body: Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(fontSize: 27, color: kPurpleDarkShade),
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 24),
                        child: TextField(
                          controller: newUserVehicle,
                          decoration: InputDecoration(
                              labelText: "Vehicle Name",
                              errorText: newUserVehicle.text.isEmpty
                                  ? ("Required")
                                  : null,
                              suffix: IconButton(
                                  onPressed: () {
                                    createNewVehicle(newUserVehicle.text);
                                  },
                                  icon: const Icon(Icons.check))),
                        ),
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      const Text(
                        "More vehicles can be added later in settings.",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
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
                                        setState(() {
                                          kUnits = units!;
                                          onChangeUnits(kUnits);
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
                                        setState(() {
                                          kUnits = units!;
                                          onChangeUnits(kUnits);
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
                    ],
                  ),
                ),
              ),
            );
          }
        });
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
  String mileage = "", dateString = "", distance = "", duration = "";
  Units units = Units.km;
  GraphMode graphMode = GraphMode.mileage;
  setValues({
    required mil,
    required String date,
    required Units setUnits,
    required String dist,
    required String dur,
    required GraphMode gMode,
  }) {
    mileage = mil;
    dateString = date;
    units = setUnits;
    distance = dist;
    duration = dur;
    graphMode = gMode;
  }

  update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (graphMode == GraphMode.mileage) {
      return Text(
        mileage != ""
            ? "$mileage ${(units == Units.km) ? 'km/l' : 'mpg'} on $dateString"
            : "",
        textAlign: TextAlign.end,
      );
    } else if (graphMode == GraphMode.distance) {
      return Text(
        distance != ""
            ? "$distance ${(units == Units.km) ? 'km' : 'mi'} on $dateString"
            : "",
        textAlign: TextAlign.end,
      );
    } else if (graphMode == GraphMode.averageSpeed) {
      return Text(
        "${(double.parse(distance) / double.parse(duration)).toStringAsFixed(2)} ${(units == Units.km) ? 'km/h' : 'mph'} on $dateString",
        textAlign: TextAlign.end,
      );
    } else {
      return Text(
        duration != "" ? "$duration hrs on $dateString" : "",
        textAlign: TextAlign.end,
      );
    }
  }
}
