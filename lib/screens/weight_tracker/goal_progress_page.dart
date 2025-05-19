// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../progress/weight_history_page.dart';

class GoalProgressPage extends StatefulWidget {
  const GoalProgressPage({Key? key}) : super(key: key);

  @override
  _GoalProgressPageState createState() => _GoalProgressPageState();
}

class _GoalProgressPageState extends State<GoalProgressPage> {
  // weight counter
  num goalWeight = 0;
  num timeLine = 0;
  num timeLine1 = 2;
  var weightDat = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  // alert dialog
  BuildContext? dialogContext;
  void showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        int weight = 60;
        Object? val = 3;
        return StatefulBuilder(builder: (context, stState) {
          Row counter() {
            return Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      stState(() {
                        weight -= 1;
                        goalWeight = weight;
                      });
                    }),
                Text(
                  weight.toString(),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      stState(() {
                        weight += 1;
                        goalWeight = weight;
                      });
                    }),
              ],
            );
          }

          Column optionsList() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(children: [
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashRadius: 0.0,
                    value: 3,
                    groupValue: val,
                    onChanged: (value) {
                      stState(() {
                        val = value;

                        timeLine = int.parse(value.toString());
                      });
                    },
                  ),
                  const Text(' Next 3 Months')
                ]),
                Row(children: [
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashRadius: 0.0,
                    value: 6,
                    groupValue: val,
                    onChanged: (value) {
                      stState(() {
                        val = value;
                        timeLine = int.parse(value.toString());
                      });
                    },
                  ),
                  const Text(' Next 6 Months')
                ]),
                Row(children: [
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashRadius: 0.0,
                    value: 12,
                    groupValue: val,
                    onChanged: (value) {
                      stState(() {
                        val = value;
                        timeLine = int.parse(value.toString());
                      });
                    },
                  ),
                  const Text(' Next 12 Months')
                ]),
              ],
            );
          }

          return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              titlePadding: const EdgeInsets.fromLTRB(10, 0, 3, 0),
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Target Plan',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(dialogContext!).pop();
                          })
                    ],
                  ),
                  const Divider(color: Colors.grey),
                ],
              ),
              content: SizedBox(
                height: 260,
                // width: 300,
                child: Column(
                  children: [
                    // first option in dialog
                    Row(
                      children: [
                        const Text(
                          'Target Weight',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        sBox(w: 2),
                        Icon(
                          Icons.track_changes_rounded,
                          color: Theme.of(context).primaryColor,
                          size: SizeConfig.blockSizeVertical! * 5,
                        ),
                        sBox(w: 8),
                        counter()
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    // second option in dialog
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Timeline',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              sBox(w: 10),
                              Icon(
                                Icons.watch,
                                color: Theme.of(context).primaryColor,
                                size: SizeConfig.blockSizeVertical! * 5,
                              ),
                              sBox(w: 1),
                            ],
                          ),
                        ),
                        Expanded(child: optionsList()),
                      ],
                    ),
                    sBox(h: 2),
                    // save button
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        elevation: 7,
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size(128, 27),
                        // padding: EdgeInsets.symmetric(horizontal: 16.0),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        setState(() {
                          weightDat.createGoal(
                              goalWeight: weight,
                              timeline: timeLine,
                              context: context);

                          weightDat.fetchWeightData().then(
                              (value) => Navigator.of(dialogContext!).pop());
                        });
                      },
                    )
                  ],
                ),
              )
              // actions: [
              //   cancelButton,
              //   continueButton,
              // ],
              );
        });
      },
    );
  }

  Center progressCard() {
    var droppedWeight = ((weightDat.weightTracker?.startingWeight ?? 0) -
        (weightDat.weightTracker?.weight ?? 0));
    var startingWeight = weightDat.weightTracker?.startingWeight ?? 0;
    var targetWeight = weightDat.weightTracker?.targetWeight;
    var initialValue = targetWeight! < startingWeight
        ? (droppedWeight / (startingWeight - targetWeight)) * 100
        : 100 - (droppedWeight / (targetWeight - startingWeight)) * 100;

    var weightText = droppedWeight < 0
        ? 'Gained ${droppedWeight.abs().toStringAsFixed(1)} Kg'
        : 'Dropped ${droppedWeight.toStringAsFixed(1)} Kg';
    return Center(
      child: Container(
        width: SizeConfig.screenWidth! - 40,
        height: SizeConfig.safeBlockVertical! * 35,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(22)),
            border: Border.all(color: Colors.black12)),
        child: Stack(
          // fit: StackFit.loose,
          children: [
            Positioned(
                top: SizeConfig.safeBlockVertical! * 25.5,
                left: SizeConfig.safeBlockHorizontal! * 16,
                child: Text(
                  '${weightDat.weightTracker?.startingWeight ?? ''}',
                  style: const TextStyle(fontSize: 20),
                )),
            Positioned(
                top: SizeConfig.safeBlockVertical! * 25.5,
                right: SizeConfig.safeBlockHorizontal! * 16,
                child: Text(
                  '${weightDat.weightTracker?.targetWeight ?? ''}',
                  style: const TextStyle(fontSize: 20),
                )),
            Positioned(
              right: SizeConfig.safeBlockHorizontal,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: Size(SizeConfig.blockSizeHorizontal! * 30,
                      SizeConfig.blockSizeVertical! * 3),
                  // padding: EdgeInsets.symmetric(horizontal: 16.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                child: const Text(
                  'Adjust Goal',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                onPressed: () {
                  showAlertDialog(context);
                },
              ),
            ),
            Positioned(
              top: SizeConfig.safeBlockVertical! * 8,
              right: SizeConfig.safeBlockHorizontal! * 4,
              left: SizeConfig.safeBlockHorizontal! * 4,
              child: SleekCircularSlider(
                initialValue: initialValue,
                appearance: CircularSliderAppearance(
                  size: SizeConfig.safeBlockVertical! * 30,
                  customWidths: CustomSliderWidths(
                      progressBarWidth: SizeConfig.safeBlockHorizontal! * 5,
                      trackWidth: SizeConfig.safeBlockHorizontal! * 5),
                  startAngle: 180,
                  angleRange: 180,
                  customColors: CustomSliderColors(
                      hideShadow: true,
                      progressBarColors: [const Color(0xffF98377), const Color(0xffFCE1DE)],
                      trackColor: const Color(0xffE9E9FF),
                      dotColor: Colors.transparent),
                  infoProperties: InfoProperties(
                      bottomLabelStyle: TextStyle(
                          fontSize: 18,
                          color: droppedWeight < 0 ? Colors.red : Colors.green),
                      mainLabelStyle: const TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      topLabelStyle:
                          const TextStyle(fontSize: 24, color: Colors.black),
                      topLabelText: 'Now',
                      bottomLabelText: weightText,
                      modifier: (value) {
                        // return value.ceil().toInt().toString();
                        return '${weightDat?.weightTracker?.weight.toString()}';
                      }),
                ),
                // onChange: (double value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column trendCard() {
    Column trendBlock({textPhrase, weight, icon}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            textPhrase,
            style: const TextStyle(color: Color(0xffC9C9C9), fontSize: 16),
          ),
          sBox(h: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color:
                      weight > 0 ? Colors.green : Colors.red), // color dynamic
              sBox(w: 2),
              RichText(
                text: TextSpan(
                  text: weight.toString(),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                  children: const <TextSpan>[
                    TextSpan(
                      text: ' kg',
                      style: TextStyle(color: Color(0xffC9C9C9), fontSize: 22),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 55),
          child: Text(
            'Trends',
            style: TextStyle(fontSize: 22, color: Color(0xff474747)),
          ),
        ),
        sBox(h: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            trendBlock(
                textPhrase: 'last 10 days',
                icon: weightDat!.weightTracker!.trendsDay10!.toInt() > 0
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                weight: weightDat?.weightTracker?.trendsDay10?.toInt()),
            trendBlock(
                textPhrase: 'last 21 days',
                icon: weightDat!.weightTracker!.trendsDay20! > 0
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                weight: weightDat?.weightTracker?.trendsDay20)
          ],
        )
      ],
    );
  }

  Padding weightHistory() {
    Padding weightInfoTile({date, weight}) {
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

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'History',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                    children: <TextSpan>[
                      TextSpan(
                        text: '   last 30 days',
                        style:
                            TextStyle(color: Color(0xffC9C9C9), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WeightHistoryPage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).primaryColor)),
                    ),
                    child: Text(
                      'See All',
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            sBox(h: 2),
            if (weightDat?.weightTracker?.weightHistory?.actualWeight?.first !=
                0)
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: weightDat!.weightTracker!.weightHistory!
                              .actualWeight!.length >
                          3
                      ? 3
                      : weightDat
                          ?.weightTracker?.weightHistory?.actualWeight?.length,
                  itemBuilder: (context, index) {
                    return weightInfoTile(
                        date: weightDat
                            ?.weightTracker?.weightHistory?.date?[index],
                        weight: weightDat?.weightTracker?.weightHistory
                            ?.actualWeight?[index]);
                  }),
            if (weightDat?.weightTracker?.weightHistory?.actualWeight?.first ==
                0)
              const Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Text('Please Upload Your Weight Daily!'))
          ],
        ));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<ProgressTrackingVM>(context, listen: false)
              .weightTracker
              ?.targetWeight ==
          0) showAlertDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    weightDat = Provider.of<ProgressTrackingVM>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Goal Progress',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            progressCard(),
            sBox(h: 3),
            trendCard(),
            sBox(h: 4),
            weightHistory()
          ],
        ),
      ),
    );
  }
}
