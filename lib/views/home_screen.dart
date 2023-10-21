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
  TextEditingController newUserVehicle = TextEditingController();

  List mileageChartData = [];
  List distanceChartData = [];
  List durationChartData = [];

  List<TripDetails> mileageVehicleTripsData = [];
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () async {
      Brightness systemTheme =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      if (FirebaseAuth.instance.currentUser != null) {
        await firestoreSetTheme(FirebaseAuth.instance.currentUser!,
            (systemTheme == Brightness.light) ? "light" : "dark");
      }
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
          if (documentSnapshot.data!.get('newUser') == false) {
            currentVehicle = documentSnapshot.data!.get('currentVehicle');

            vehiclesList = documentSnapshot.data!.get('vehiclesList').toSet();

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
                List<TripDetails> data = [];
                for (var element in collectionSnapshot.data!.docs) {
                  var trip = TripDetails(
                    dateTime: element['dateTime'],
                    distance: element['distance'].toDouble(),
                    duration: element['duration'].toDouble(),
                    id: element['id'],
                    tripTitle: element['tripTitle'],
                    distanceUnits: (element['distanceUnits'] == "km")
                        ? Units.km
                        : Units.mi,
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
                    .sort((a, b) => a.dateTime.compareTo(b.dateTime));

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
                }

                return FutureBuilder(
                  future: firestoreGetUnits(FirebaseAuth.instance.currentUser!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      kUnits = (snapshot.data == "km") ? Units.km : Units.mi;
                      if (vehicleTripsData.isNotEmpty &&
                          vehicleTripsData[0].distanceUnits != kUnits) {
                        for (int index = 0;
                            index < vehicleTripsData.length;
                            index++) {
                          Units prevDistanceUnits =
                              vehicleTripsData[index].distanceUnits;
                          vehicleTripsData[index].distanceUnits = kUnits;

                          if (kUnits == Units.km &&
                              kUnits != prevDistanceUnits) {
                            vehicleTripsData[index].distanceUnits = Units.km;
                            vehicleTripsData[index].distance = double.parse(
                                (vehicleTripsData[index].distance * 1.609)
                                    .toStringAsFixed(2));
                            vehicleTripsData[index].mileage = double.parse(
                                (vehicleTripsData[index].mileage! / 2.352)
                                    .toStringAsFixed(2));
                          }

                          if (kUnits == Units.mi &&
                              kUnits != prevDistanceUnits) {
                            vehicleTripsData[index].distanceUnits = Units.mi;

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
                                                setDistanceUnits:
                                                    vehicleTripsData[0]
                                                        .distanceUnits,
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
                                              ? (vehicleTripsData[0]
                                                          .distanceUnits ==
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
                                            setDistanceUnits:
                                                vehicleTripsData[0]
                                                    .distanceUnits,
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
                                          setDistanceUnits:
                                              vehicleTripsData[0].distanceUnits,
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
                                return {'Logout', 'Settings'}
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
                                                    onChangeDistanceUnits:
                                                        (Units distanceUnits) {
                                                      setState(() {
                                                        for (int index = 0;
                                                            index <
                                                                vehicleTripsData
                                                                    .length;
                                                            index++) {
                                                          Units
                                                              prevDistanceUnits =
                                                              vehicleTripsData[
                                                                      index]
                                                                  .distanceUnits;
                                                          vehicleTripsData[
                                                                      index]
                                                                  .distanceUnits =
                                                              distanceUnits;

                                                          if (distanceUnits ==
                                                                  Units.km &&
                                                              distanceUnits !=
                                                                  prevDistanceUnits) {
                                                            vehicleTripsData[
                                                                        index]
                                                                    .distanceUnits =
                                                                Units.km;
                                                            vehicleTripsData[
                                                                        index]
                                                                    .distance =
                                                                double.parse((vehicleTripsData[index]
                                                                            .distance *
                                                                        1.609)
                                                                    .toStringAsFixed(
                                                                        2));
                                                            vehicleTripsData[
                                                                    index]
                                                                .mileage = double.parse(((vehicleTripsData[index]
                                                                            .mileage !=
                                                                        null)
                                                                    ? vehicleTripsData[
                                                                            index]
                                                                        .mileage
                                                                    : 0 /
                                                                        2.352)!
                                                                .toStringAsFixed(
                                                                    2));
                                                          }

                                                          if (distanceUnits ==
                                                                  Units.mi &&
                                                              distanceUnits !=
                                                                  prevDistanceUnits) {
                                                            vehicleTripsData[
                                                                        index]
                                                                    .distanceUnits =
                                                                Units.mi;

                                                            vehicleTripsData[
                                                                        index]
                                                                    .distance =
                                                                double.parse((vehicleTripsData[index]
                                                                            .distance /
                                                                        1.609)
                                                                    .toStringAsFixed(
                                                                        2));
                                                            vehicleTripsData[
                                                                    index]
                                                                .mileage = double.parse(((vehicleTripsData[index]
                                                                            .mileage !=
                                                                        null)
                                                                    ? vehicleTripsData[
                                                                            index]
                                                                        .mileage
                                                                    : 0 *
                                                                        2.352)!
                                                                .toStringAsFixed(
                                                                    2));
                                                          }
                                                          firestoreUpdateTrip(
                                                              user: FirebaseAuth
                                                                  .instance
                                                                  .currentUser!,
                                                              updatedData:
                                                                  vehicleTripsData[
                                                                          index]
                                                                      .toMap(),
                                                              id: vehicleTripsData[
                                                                      index]
                                                                  .id);
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
                        body: DefaultTabController(
                          length: views.length,
                          child: SafeArea(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 18, left: 18, right: 18),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Total distance travelled: ",
                                              style: semiBold18(),
                                            ),
                                            Text(
                                              (vehicleTripsData.isNotEmpty)
                                                  ? "Average ${(kUnits == Units.km) ? 'km/l' : 'mpg'}:"
                                                  : "Average km/l:",
                                              style: semiBold18(),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text((vehicleTripsData.isNotEmpty)
                                                ? "${[
                                                    for (TripDetails trip
                                                        in vehicleTripsData)
                                                      trip.distance
                                                  ].sum.toStringAsFixed(2)} ${(kUnits == Units.km) ? 'km' : 'mi'}"
                                                : "0km"),
                                            Text((vehicleTripsData.isNotEmpty)
                                                ? "${(([
                                                      for (TripDetails trip
                                                          in vehicleTripsData)
                                                        (trip.mileage != 0)
                                                            ? trip.mileage!
                                                            : 0
                                                    ].sum / mileageVehicleTripsData.length)).toStringAsFixed(2)} ${(kUnits == Units.km) ? 'km/l' : 'mpg'}"
                                                : "0${(kUnits == Units.km) ? 'km/l' : 'mpg'}"),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
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
                                  Expanded(
                                    flex: 6,
                                    child: SizedBox(
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
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: (vehicleTripsData
                                                        .isNotEmpty)
                                                    ? vehicleTripsData.length
                                                    : 0,
                                                itemBuilder:
                                                    (bContext, position) {
                                                  return Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          showModalBottomSheet(
                                                              context: context,
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
                                                                      vehicleTripsData[
                                                                              position]
                                                                          .tripTitle,
                                                                  initDist: vehicleTripsData[
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
                                                                Radius.circular(
                                                                    18),
                                                              ),
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
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        vehicleTripsData[position]
                                                                            .tripTitle,
                                                                      ),
                                                                      Text(DateFormat
                                                                              .yMMMd()
                                                                          .format(
                                                                              DateTime.fromMillisecondsSinceEpoch(vehicleTripsData[position].dateTime)))
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
                                                                          "${vehicleTripsData[position].distance}${(vehicleTripsData[position].distanceUnits == Units.km) ? 'km' : 'mi'}"),
                                                                      (vehicleTripsData[position].mileage !=
                                                                              0)
                                                                          ? Text(
                                                                              "${vehicleTripsData[position].mileage} ${(vehicleTripsData[position].distanceUnits == Units.km) ? 'km/l' : 'mpg'}")
                                                                          : Container(),
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
                        child: Row(
                          children: [
                            Expanded(
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
                            ))
                          ],
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
                      )
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
  Units distanceUnits = Units.km;
  GraphMode graphMode = GraphMode.mileage;
  setValues({
    required mil,
    required String date,
    required Units setDistanceUnits,
    required String dist,
    required String dur,
    required GraphMode gMode,
  }) {
    mileage = mil;
    dateString = date;
    distanceUnits = setDistanceUnits;
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
            ? "$mileage ${(distanceUnits == Units.km) ? 'km/l' : 'mpg'} on $dateString"
            : "",
        textAlign: TextAlign.end,
      );
    } else if (graphMode == GraphMode.distance) {
      return Text(
        distance != ""
            ? "$distance ${(distanceUnits == Units.km) ? 'km' : 'mi'} on $dateString"
            : "",
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
