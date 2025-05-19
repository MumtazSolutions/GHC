import 'package:flutter/material.dart';
import 'package:fstore/common/sizeConfig.dart';
import 'package:fstore/models/progress/progress_tracking_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeightHistoryPage extends StatelessWidget {
  const WeightHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var weightData = Provider.of<ProgressTrackingVM>(context);
    weightInfoTile({date, weight}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xffFBF4F3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.parse(date)),
                  // DateFormat('yyyy-MM-dd').parse(date).toString(),
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).primaryColor),
                ),
                RichText(
                  text: TextSpan(
                    text: weight.toString(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' kg',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'History',
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
            size: SizeConfig.blockSizeVertical !* 2,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: weightData.weightTracker?.weightHistory?.actualWeight?.length !=
                  null ||
              weightData.weightTracker?.weightHistory?.actualWeight?.isNotEmpty==true
          ? ListView.builder(
              physics: const BouncingScrollPhysics(),
              // shrinkWrap: true,
              itemCount:
                  weightData.weightTracker?.weightHistory?.actualWeight?.length,
              itemBuilder: (context, index) {
                return weightInfoTile(
                    date: weightData.weightTracker?.weightHistory?.date?[index],
                    weight: weightData
                        .weightTracker?.weightHistory?.actualWeight?[index]);
              })
          : const Center(
              child: Text('No Data To Show!'),
            ),
    );
  }
}
