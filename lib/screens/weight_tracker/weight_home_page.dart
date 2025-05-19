import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../app.dart';
import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/constants/user_prefrences.dart';
import '../../common/sizeConfig.dart';
import '../../models/index.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../models/progress/weight_tracker_model.dart';
import '../../widgets/loading_widget.dart';
import 'goal_progress_page.dart';
import 'weight_calendar.dart';
import 'weight_graph.dart';
import 'weight_tranformation_page.dart';

class WeightHomePage extends StatefulWidget {
  final bool fromBmiPage;
  const WeightHomePage({Key? key, this.fromBmiPage = false}) : super(key: key);

  @override
  _WeightHomePageState createState() => _WeightHomePageState();
}

class _WeightHomePageState extends State<WeightHomePage> {
  TextEditingController weightText = TextEditingController();
  var weightData = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);
  bool canClick = true;
  num goalWeight = 60;
  num timeLine = 0;

  bool isShowing = true;
  bool? seen;
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey fab = GlobalKey();
  GlobalKey weightcalendar = GlobalKey();
  GlobalKey weightgraph = GlobalKey();
  GlobalKey goalprogress = GlobalKey();
  bool skipped = false;
  bool isShown = false;

  Positioned pWidget({top = 0, right = 0, left = 0, bottom = 0, child}) {
    return Positioned(
      top: SizeConfig.blockSizeVertical! * top,
      right: SizeConfig.blockSizeHorizontal! * right,
      bottom: SizeConfig.blockSizeVertical! * bottom,
      left: SizeConfig.blockSizeHorizontal! * left,
      child: child,
    );
  }

  GestureDetector weightCalendar({newUser = false, data}) {
    var m = weightData.tracker?.startDate?.month;
    var y = weightData.tracker?.startDate?.year;
    var d = weightData.tracker?.startDate?.day;
    var daysPassed = DateTime.now()
        .difference(DateTime(y ?? 0, m ?? 0, d ?? 0))
        .inDays; // + 1 if using month and year
    var daysMissed;

    setState(() {
      daysMissed = (daysPassed -
              int.parse(Provider.of<ProgressTrackingVM>(context, listen: false)
                      .weightTracker
                      ?.weightHistory
                      ?.actualWeight
                      ?.length
                      .toString() ??
                  '0'))
          .abs();
    });

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WeightCalendarPage(
                  firstTime: widget.fromBmiPage == true ? true : false)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: Container(
          key: weightcalendar,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: newUser
                ?
                // new user interface
                Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weight Calendar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          sBox(w: 5),
                          sBox(w: 5),
                          Icon(
                            Icons.today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const Icon(Icons.chevron_right_sharp)
                        ],
                      ),
                      const Divider(
                        endIndent: 5,
                        indent: 2,
                        color: Colors.grey,
                      ),
                      const Text(
                          'Let\'s Track the number of days you have recorded as per your calendar '),
                      sBox(h: 1),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.all(Radius.circular(80)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                right: 10, left: 10, top: 6, bottom: 6),
                            child: Text(
                              'Add +',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                // Existing User Interface
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weight Calendar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          sBox(w: 5),
                          sBox(w: 5),
                          Icon(
                            Icons.today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const Icon(Icons.chevron_right_sharp)
                        ],
                      ),
                      const Divider(
                        endIndent: 5,
                        indent: 2,
                        color: Colors.grey,
                      ),
                      sBox(h: .5),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  sBox(w: .2),
                                  Container(
                                    width: 10,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[200],
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                  sBox(w: 1),
                                  Text(
                                      '${weightData.weightTracker?.weightHistory?.actualWeight?.length} Days Uploaded')
                                ],
                              ),
                              Row(
                                children: [
                                  sBox(w: .2),
                                  Container(
                                    width: 10,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                  sBox(w: 1),
                                  Text('$daysMissed Days Missed')
                                ],
                              )
                            ],
                          ),
                          sBox(w: 10),
                          SizedBox(
                            height: 50,
                            width: 50,
                            // color: Colors.red[200], ?
                            // calendar image
                            child: Image.asset(
                                'assets/images/calendarWidgetImage.png'),
                          ),
                          sBox(w: 14),
                          Icon(Icons.add_circle_outlined,
                              color: Theme.of(context).primaryColor)
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  GestureDetector weightGraph() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeightGraphPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: Container(
          key: weightgraph,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Weight Loss Journey',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sBox(w: 8),
                    sBox(w: 12),
                    Icon(
                      Icons.trending_up_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    const Icon(Icons.chevron_right_sharp)
                  ],
                ),
                const Divider(
                  endIndent: 5,
                  indent: 2,
                  color: Colors.grey,
                ),
                // sBox(h: .2),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Image.asset(
                    'assets/images/weightLossJourney.png',
                    // height: 150,
                    // scale: ,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector goalProgress({newUser = false, WeightTrackerModel? data}) {
    var startingWeight = data?.startingWeight;
    var currentWeight = data?.weight;
    var targetWeight = data?.targetWeight;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GoalProgressPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: Container(
          key: goalprogress,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Goal Progress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sBox(w: 8),
                    sBox(w: 14),
                    Icon(
                      Icons.track_changes,
                      color: Theme.of(context).primaryColor,
                    ),
                    const Icon(Icons.chevron_right_sharp)
                  ],
                ),
                const Divider(
                  endIndent: 5,
                  indent: 2,
                  color: Colors.grey,
                ),
                // sBox(h: .2),
                newUser
                    ? const Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(
                            'Set your Target Weight Goal & Time\n\nAchieve it like a BOSS!'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Current',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data?.weight.toString() ?? '',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Left',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    (double.parse(data?.weight.toString() ??
                                                '0') -
                                            int.parse(
                                                data?.targetWeight.toString() ??
                                                    '0'))
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Target',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data?.targetWeight.toString() ?? '',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            ],
                          ),
                          sBox(h: 2),
                          // progress bAR
                          // Container(
                          //   width: SizeConfig.safeBlockHorizontal * 70,
                          //   child: ClipRRect(
                          //     borderRadius:
                          //         BorderRadius.all(Radius.circular(30)),
                          //     child: LinearProgressIndicator(
                          //       minHeight: SizeConfig.safeBlockVertical * 1.1,
                          //       value: (1 -
                          //           ((weightData.weightTracker.weight -
                          //                   weightData
                          //                       .weightTracker.targetWeight) /
                          //               (weightData
                          //                       .weightTracker.startingWeight -
                          //                   weightData
                          //                       .weightTracker.targetWeight))),
                          //       //                  *
                          //       // 100,
                          //       backgroundColor: Color(0xffFFEDE3),
                          //       valueColor: AlwaysStoppedAnimation<Color>(
                          //           Theme.of(context).primaryColor),
                          //     ),
                          //   ),
                          // ),
                          Row(children: [
                            SizedBox(
                              width: SizeConfig.safeBlockHorizontal! * 62,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                child: LinearProgressIndicator(
                                  minHeight:
                                      SizeConfig.safeBlockVertical! * 1.1,
                                  value: ((startingWeight! - currentWeight!) /
                                      (startingWeight - targetWeight!)),
                                  //                  *
                                  // 100,
                                  backgroundColor: const Color(0xffFFEDE3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            sBox(w: 3),
                            Text(
                                '${(((startingWeight - currentWeight) / (startingWeight - targetWeight)) * 100).toStringAsFixed(1)}%')
                          ])
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector transformationTracker({newUser = false, data}) {
    getThisWeek() {
      for (var i = 0;
          i < int.parse(weightData.tracker?.months?.length.toString() ?? '0');
          i++) {
        for (var j = 0;
            j <
                int.parse(
                    weightData.tracker?.months?[i].weeks?.length.toString() ??
                        '0');
            j++) {
          if (weightData.tracker?.months?[i].weeks?[j].currentWeek == true) {
            return j;
          }
        }
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeightTransormatioPage()),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transformation Tracker',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sBox(w: 8),
                    sBox(w: 2),
                    Icon(
                      Icons.photo_library,
                      color: Theme.of(context).primaryColor,
                    ),
                    const Icon(Icons.chevron_right_sharp)
                  ],
                ),
                const Divider(
                  endIndent: 5,
                  indent: 2,
                  color: Colors.grey,
                ),
                // sBox(h: .2),
                newUser
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                              'Let\'s start tracking your transformation by uploading you pictures each week'),
                          sBox(h: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              sBox(w: 2),
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 22,
                                height: SizeConfig.blockSizeVertical! * 9,
                                decoration: const BoxDecoration(
                                  // color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                child: Image.asset(
                                    'assets/images/uploadWeightFront.png'),
                              ),
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 22,
                                height: SizeConfig.blockSizeVertical! * 9,
                                decoration: const BoxDecoration(
                                  // color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                child: Image.asset(
                                    'assets/images/uploadWeightSide.png'),
                              ),
                              sBox(w: 2)
                            ],
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              'Last Tracked ${DateFormat.yMMMd().format(DateTime.parse(weightData.weightTracker?.weightHistory?.date?.first))}'),
                          sBox(h: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              sBox(w: 2),
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 22,
                                height: SizeConfig.blockSizeVertical! * 9,
                                decoration: const BoxDecoration(
                                  // color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                child: weightData
                                            .tracker
                                            ?.months?[int.parse(weightData
                                                        .tracker
                                                        ?.months
                                                        ?.length
                                                        .toString() ??
                                                    '0') -
                                                1]
                                            .weeks?[int.parse(
                                                getThisWeek().toString())]
                                            .frontImage ==
                                        ''
                                    ? Image.asset(
                                        'assets/images/uploadWeightFront.png')
                                    : CachedNetworkImage(
                                        filterQuality: FilterQuality.low,
                                        imageUrl:
                                            '${weightData.tracker?.months?[int.parse(weightData.tracker?.months?.length.toString() ?? '0') - 1].weeks?[int.parse(getThisWeek().toString())].frontImage}'),
                              ),
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 22,
                                height: SizeConfig.blockSizeVertical! * 9,
                                decoration: const BoxDecoration(
                                  // color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(22)),
                                ),
                                child: weightData
                                            .tracker
                                            ?.months?[int.parse(weightData
                                                        .tracker
                                                        ?.months
                                                        ?.length
                                                        .toString() ??
                                                    '0') -
                                                1]
                                            .weeks?[int.parse(
                                                getThisWeek().toString())]
                                            .topImage ==
                                        ''
                                    ? Image.asset(
                                        'assets/images/uploadWeightSide.png')
                                    : CachedNetworkImage(
                                        filterQuality: FilterQuality.low,
                                        imageUrl:
                                            '${weightData.tracker?.months?[int.parse(weightData.tracker?.months?.length.toString() ?? '0') - 1].weeks?[int.parse(getThisWeek().toString())].topImage}'),
                              ),
                              sBox(w: 2)
                            ],
                          )
                        ],
                      ),
                sBox(h: 2)
              ],
            ),
          ),
        ),
      ),
    );
  }

  String phraseToReturn() {
    if (int.parse(weightData.weightTracker?.bmi.toString() ?? '0') < 18.5) {
      return 'Gain muscle weight';
    } else if (int.parse(weightData.weightTracker?.bmi.toString() ?? '0') >
            18.5 &&
        int.parse(weightData.weightTracker?.bmi.toString() ?? '0') < 24.9) {
      return 'You are healthy';
    } else if (int.parse(weightData.weightTracker?.bmi.toString() ?? '0') >
            25.0 &&
        int.parse(weightData.weightTracker?.bmi.toString() ?? '0') < 29.9) {
      return 'Try eating healthy';
    } else {
      return 'Burn those extra kilos';
    }
  }

  Widget _noUserView() {
    return Center(
      child: SizedBox(
        height: 400,
        child: Center(
          child: Column(
            children: [
              Icon(Icons.not_interested_outlined,
                  size: 120, color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              const Text('Login to View the Progress'),
              const SizedBox(height: 100),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(
                    App.fluxStoreNavigatorKey.currentContext ?? context,
                  ).pushNamed(RouteList.login);
                  return;
                },
                isExtended: true,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                icon: const Icon(Icons.account_box_rounded, size: 20),
                label: const Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }

  BuildContext? dialogContext;
  void showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        var weight = 60;
        var val = 3;
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
                        val = int.parse(value.toString());
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
                        val = int.parse(value.toString());
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
                        val = int.parse(value.toString());
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
                            Navigator.of(dialogContext ?? context).pop();
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
                        sBox(w: 2),
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
                              sBox(w: 5),
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
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () async {
                        setState(() async {
                          await weightData.createGoal(
                              goalWeight: goalWeight,
                              timeline: timeLine,
                              context: context);
                          await Provider.of<ProgressTrackingVM>(context,
                                  listen: false)
                              .fetchWeightData()
                              .then((value) {
                            isShown = true;
                            Navigator.of(dialogContext ?? context).pop();
                          });
                        });
                        // Timer(Duration(seconds: 2),
                        //     () => Navigator.of(dialogContext).pop());
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

  void checkIsSeen() async {
    var prefs = await SharedPreferences.getInstance();
    seen = prefs.getBool('seen') ?? false;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<ProgressTrackingVM>(context, listen: false)
                  .weightTracker
                  ?.targetWeight ==
              0 &&
          isShown == false) showAlertDialog(context);
    });
    checkIsSeen();
    if (UserPreferences().seenWeight == true) {
      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        hideSkip: true,
        colorShadow: Colors.black38,
        textSkip: 'SKIP',
        paddingFocus: 0,
        opacityShadow: 0.8,
        onFinish: () {
          // print("finish");
        },
        onClickTarget: (target) {
          // print('onClickTarget: $target');
        },
        onClickOverlay: (target) {
          // print('onClickOverlay: $target');
        },
        onSkip: () {
          // print("skip");
          tutorialCoachMark?.finish();
        },
      )..finish();
    }

    super.initState();
  }

  @override
  void dispose() {
    tutorialCoachMark?.skip();
    super.dispose();
  }

  void initTargets() {
    targets.clear();
    targets.add(
      targetFocus(
          controller: tutorialCoachMark,
          targets: targets,
          circle: true,
          identifier: 'Fab',
          key: fab,
          text: 'Add your daily weight to see your goal progress'),
    );
    targets.add(
      targetFocus(
          controller: tutorialCoachMark,
          targets: targets,
          identifier: 'WeightCalendar',
          key: weightcalendar,
          text: 'Track the number of days you have recorded your weight'),
    );
    targets.add(
      targetFocus(
          controller: tutorialCoachMark,
          targets: targets,
          identifier: 'WeightGraph',
          key: weightgraph,
          text: 'See how your weight loss journey is going'),
    );
    targets.add(
      targetFocus(
          controller: tutorialCoachMark,
          targets: targets,
          identifier: 'GoalProgress',
          key: goalprogress,
          text: 'Set your weight goal'),
    );
  }

  void showTutorial() {
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      hideSkip: true,
      colorShadow: Colors.black38,
      textSkip: 'SKIP',
      paddingFocus: 0,
      opacityShadow: 0.8,
      onFinish: () {
        // print("finish");
      },
      onClickTarget: (target) {
        // print('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        // print('onClickOverlay: $target');
      },
      onSkip: () {
        // print("skip");
        tutorialCoachMark?.finish();
      },
    )..show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    log('_____________IN WEIGHT LOSS');
    if (Provider.of<ProgressTrackingVM>(context, listen: false).isloading ==
            false &&
        isShowing &&
        UserPreferences().seenWeight == false) {
      isShowing = false;
      Future.delayed(const Duration(milliseconds: 500), showTutorial);
      UserPreferences().seenWeight = true;
      index = 0;
    }
    var progress = Provider.of<ProgressTrackingVM>(context);
    weightData = Provider.of<ProgressTrackingVM>(context);
    final userInfo = Provider.of<UserModel>(context);
    return WillPopScope(
      onWillPop: () async {
        if (tutorialCoachMark?.isShowing == true) {
          tutorialCoachMark?.skip();
          return Future.value(false);
        } else {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Wellness Tracker',
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
        body: userInfo.user == null
            ? _noUserView()
            : progress.isloading
                ? Column(children: [
                    Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeVertical! * 35),
                        child: const LoadingWidget())
                  ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // sBox(h: 1),
                      // Center(
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: Theme.of(context).primaryColor,
                      //       borderRadius: BorderRadius.all(Radius.circular(20)),
                      //     ),
                      //     child: Padding(
                      //       padding:
                      //           EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                      //       child: Text(
                      //         'Add Today\'s Weight',
                      //         style: TextStyle(
                      //             color: Colors.white, fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // sBox(h: 2),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 30),
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                      color: Theme.of(context).primaryColor,
                                      spreadRadius: .2)
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text(
                                    '${weightData.weightTracker?.bmi?.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text('Your BMI',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.only(left: 12),
                                //   child: Text('${phraseToReturn()}',
                                //       style: TextStyle(
                                //           color: Theme.of(context).primaryColor,
                                //           fontSize: 20,
                                //           fontWeight: FontWeight.bold)),
                                // ),
                              ],
                            ),
                          ]),
                      Expanded(
                        child: Stack(
                          fit: StackFit.passthrough,
                          clipBehavior: Clip.none,
                          children: [
                            pWidget(
                              top: 1.5,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xffFBF4F3),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(60),
                                      topRight: Radius.circular(60)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 30, left: 30, top: 20),
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      // sBox(h: 5),
                                      weightCalendar(
                                          newUser: weightData.weightTracker
                                                      ?.targetWeight ==
                                                  0
                                              ? true
                                              : false,
                                          data: weightData.weightTracker),
                                      weightGraph(),
                                      goalProgress(
                                          newUser: weightData.weightTracker
                                                      ?.targetWeight ==
                                                  0
                                              ? true
                                              : false,
                                          data: weightData.weightTracker),
                                      transformationTracker(
                                        newUser: weightData.weightTracker
                                                    ?.targetWeight ==
                                                0
                                            ? true
                                            : false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        floatingActionButton: DateFormat.yMMMd().format(DateTime.parse(
                        weightData
                            .weightTracker?.weightHistory?.date?.first)) !=
                    DateFormat.yMMMd().format(DateTime.now()) &&
                widget.fromBmiPage != true
            ? Padding(
                padding: EdgeInsets.only(
                    right: SizeConfig.blockSizeHorizontal! * 3,
                    bottom: SizeConfig.blockSizeVertical! * 12),
                child: FloatingActionButton(
                  key: fab,
                  onPressed: () {
                    showModalBottomSheet<void>(
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20)),
                      ),
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  'Welcome,',
                                  style: TextStyle(
                                    color: Color(0xff0B4870),
                                    fontSize: 26,
                                  ),
                                ),
                                Text(
                                  '${progress.user?.name}',
                                  style: const TextStyle(
                                      color: Color(0xff0B4870),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                                sBox(h: 1),
                                Image.asset('assets/images/addWeightTip.png'),
                                sBox(h: 1),
                                const Text(
                                  'Add Today\'s Weight',
                                  style: TextStyle(
                                    color: Color(0xff0B4870),
                                    fontSize: 26,
                                  ),
                                ),
                                sBox(h: 2),
                                TextField(
                                    controller: weightText,
                                    keyboardType: TextInputType.number),
                                sBox(h: 3),
                                Center(
                                  child: ElevatedButton(
                                      style: TextButton.styleFrom(
                                        elevation: 7,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        minimumSize: const Size(141, 37),
                                        // padding: EdgeInsets.symmetric(horizontal: 16.0),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                      ),
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      onPressed: () async {
                                        if (canClick) {
                                          canClick = false;
                                          setState(() async {
                                            var s = Stopwatch()
                                              ..start();
                                            await Fluttertoast.showToast(
                                                msg:
                                                    'Weight Added! Updating...',
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                    Colors.grey[600],
                                                textColor: Colors.white);
                                            await weightData.postDailyWeight(
                                                context: context,
                                                weight: double.parse(
                                                    weightText.text));
                                            await weightData
                                                .getWeightProgressData()
                                                .then((value) {
                                              canClick = true;
                                              Navigator.of(context).pop();
                                            });
                                            printLog(
                                                'OnPressed save button takes ${s..elapsed.inSeconds}');
                                            s.stop();
                                          });
                                        }
                                      }),
                                ),
                                sBox(h: 1)
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Image.asset(
                    'assets/images/weightScaleIcon.png',
                    scale: .95,
                  ),
                ),
              )
            : Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
