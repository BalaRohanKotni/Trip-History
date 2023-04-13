import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import '../constants.dart';
import '../controllers/graph_layout_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List data = [
    [
      DateTime(2016).millisecondsSinceEpoch,
      29,
      "Mangolore Trip",
      900,
      /*dist */
      13,
      /*dur */
      "123jh4k1234",
    ],
    [
      DateTime(2017).millisecondsSinceEpoch,
      30.5,
      "Banglore Trip",
      758,
      11,
      "123jh4k1234",
    ],
    [
      DateTime(2018).millisecondsSinceEpoch,
      31,
      "Mysore Trip",
      700,
      10,
      "123jh4k1234",
    ],
    [
      DateTime(2019).millisecondsSinceEpoch,
      33,
      "Pondicherry Trip",
      800,
      12,
      "123jh4k1234",
    ],
    [
      DateTime(2020).millisecondsSinceEpoch,
      32,
      "Lonovola Trip",
      1200,
      15,
      "123jh4k1234",
    ],
    [
      DateTime(2021).millisecondsSinceEpoch,
      34,
      "Goa Trip",
      1100,
      14,
      "123jh4k1234",
    ],
  ];

  String selectedMileage = "", selectedDateString = "";

  final GlobalKey<_SelectedGraphTextWidgetState> _key = GlobalKey();

  List chartData = [];
  @override
  void initState() {
    super.initState();
    for (var element in data) {
      chartData.add([
        DateTime.fromMillisecondsSinceEpoch(element[0]),
        element[1].floor()
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (st) {},
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
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
                          "Average km/l:",
                          style: semiBold18(),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${[
                          for (var trip in data) trip[3]
                        ].fold(0, (p, c) => (p + c).toInt())}km"),
                        Text((data.isNotEmpty)
                            ? "${([
                                  for (var trip in data) trip[1]
                                ].fold(0, (p, c) => (p + c).toInt()) / data.length).toStringAsFixed(2)}km/l"
                            : "0km/l"),
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
                                  List selectedPoint = data[chartData.indexOf(
                                      model.selectedDatum.first.datum)];

                                  String dateTime =
                                      "${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint[0]))} \n${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(selectedPoint[0]))}";

                                  String mileage =
                                      selectedPoint[1].toDouble().toString();

                                  _key.currentState!
                                      .setValues(mileage, dateTime);
                                  _key.currentState!.update();
                                })
                          ],
                          behaviors: [
                            charts.ChartTitle(
                              "Trips",
                              titleOutsideJustification:
                                  charts.OutsideJustification.start,
                              innerPadding: 24,
                            ),
                            charts.ChartTitle(
                              "km/l",
                              behaviorPosition: charts.BehaviorPosition.start,
                            )
                          ],
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
                            itemCount: (data.isNotEmpty) ? data.length - 1 : 0,
                            itemBuilder: (bContext, position) {
                              return Column(
                                children: [
                                  Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
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
                                                  data[position][2],
                                                ),
                                                Text(DateFormat.yMMMd().format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            data[position][0])))
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
                                                Text("${data[position][3]}km"),
                                                Text(
                                                    "${data[position][1]} km/l"),
                                                Text("${data[position][4]}hrs"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
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

  setValues(mil, date) {
    mileage = mil;
    dateString = date;
  }

  update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      mileage != "" ? "$mileage km/l on $dateString" : "",
      textAlign: TextAlign.end,
    );
  }
}
