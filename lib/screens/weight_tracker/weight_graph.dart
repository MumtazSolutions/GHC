import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';

class WeightGraphPage extends StatefulWidget {
  const WeightGraphPage({Key? key}) : super(key: key);

  @override
  _WeightGraphPageState createState() => _WeightGraphPageState();
}

class _WeightGraphPageState extends State<WeightGraphPage> {
  List<WeightData> chartData = [];
  List<WeightData> chartData1 = [];
  ProgressTrackingVM? weightData =
      Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0;
        i < weightData!.weightTracker!.weightHistory!.actualWeight!.length;
        i++) {
      chartData.add(WeightData(
          date: DateTime.parse(
              weightData!.weightTracker!.weightHistory!.date![i]),
          weight: weightData!.weightTracker!.weightHistory!.actualWeight![i]));
      chartData1 = List.generate(
        1000,
        (index) => WeightData(
            date: DateTime(
                DateTime.parse(
                        weightData!.weightTracker!.weightHistory!.date![i])
                    .year,
                DateTime.parse(
                        weightData!.weightTracker!.weightHistory!.date![i])
                    .month,
                DateTime.parse(
                            weightData!.weightTracker!.weightHistory!.date![i])
                        .day +
                    index),
            weight: weightData!.weightTracker!.weightHistory!.goalWeight!.last),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Weight Loss Journey',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.black,
            size: SizeConfig.blockSizeVertical! * 2,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            sBox(h: 15),
            weightData!.weightTracker!.targetWeight != 0
                ? Center(
                    child: Container(
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.years,
                          interval: 1,
                          majorGridLines: MajorGridLines(
                              width: 0,
                              color: Colors.grey[300],
                              dashArray: const <double>[8, 8]),
                        ),
                        primaryYAxis: NumericAxis(
                            plotOffset: 20,
                            majorGridLines: MajorGridLines(
                                width: 1,
                                color: Colors.grey[300],
                                dashArray: const <double>[8, 8]),
                            minorGridLines: const MinorGridLines(
                                width: 0,
                                color: Colors.green,
                                dashArray: <double>[5, 5]),
                            minorTicksPerInterval: 2),
                        series: <ChartSeries>[
                          // Renders spline chart
                          SplineSeries<WeightData, DateTime>(
                              color: Colors.green[800],
                              dataSource: chartData1,
                              xValueMapper: (WeightData sales, _) => sales.date,
                              yValueMapper: (WeightData sales, _) =>
                                  sales.weight),
                          SplineSeries<WeightData, DateTime>(
                              markerSettings: MarkerSettings(
                                isVisible: true,
                                borderWidth: 4,
                                height: SizeConfig.blockSizeVertical! * 0.5,
                                width: SizeConfig.blockSizeVertical! * 0.5,
                              ),
                              color: Theme.of(context).primaryColor,
                              dataSource: chartData,
                              splineType: SplineType.monotonic,
                              xValueMapper: (WeightData sales, _) => sales.date,
                              yValueMapper: (WeightData sales, _) =>
                                  sales.weight),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text('Please Update your Target Weight!'),
                  ),
            sBox(h: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    sBox(w: .2),
                    Container(
                      width: 10,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    sBox(w: 1),
                    const Text('Target Weight')
                  ],
                ),
                Row(
                  children: [
                    sBox(w: .2),
                    Container(
                      width: 10,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    sBox(w: 1),
                    const Text('Your Progress')
                  ],
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WeightData {
  num? weight;
  DateTime? date;

  WeightData({this.weight, this.date});
}
