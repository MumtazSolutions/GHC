
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../models/user_model.dart';
import '../../widgets/loading_widget.dart';
import '../sleep_tracker/sleep_goal_page.dart';
import '../sleep_tracker/sleep_home_page.dart';
import '../sleep_tracker/sleep_tracker_provider.dart';
import '../water_tracker/water_goal_page.dart';
import '../water_tracker/water_home_page.dart';
import '../water_tracker/water_tracker_provider.dart';
import '../wellness_weightTracker/wellness_weight_tracker_home.dart';
import '../wellness_weightTracker/wellness_wieght_tracker_provider.dart';

class WellnessOverviewPage extends StatefulWidget {
  const WellnessOverviewPage({Key? key}) : super(key: key);

  @override
  State<WellnessOverviewPage> createState() => _WellnessOverviewPageState();
}

class _WellnessOverviewPageState extends State<WellnessOverviewPage> {
  int? glassesLeft;
  int? glassesGoal;
  int glassesIntake = 0;
  bool enableWaterNotif = true;
  bool enableSleepNotif = true;
  num? sleepGoal;
  num? totalSleep = 0;

  bool isLoading = false;
  // bool bedTime = false;
  num bmi = 15;
  int? updatedWeight;
  int presentWeek = 0;
  var dayOfWeek = 0;
  var userInfo = Provider.of<UserModel>(Get.context!, listen: false);
  ProgressTrackingVM progress = ProgressTrackingVM();
  WaterTrackerProvider waterVm = WaterTrackerProvider();
  SleepTrackerProvider sleepVm = SleepTrackerProvider();
  WellnessWeightTrackerProvider weightVm = WellnessWeightTrackerProvider();

  @override
  void initState() {
    sleepVm = Provider.of<SleepTrackerProvider>(Get.context!, listen: false);
    weightVm =
        Provider.of<WellnessWeightTrackerProvider>(Get.context!, listen: false);
    waterVm = Provider.of<WaterTrackerProvider>(Get.context!, listen: false);
    var userInfo = Provider.of<UserModel>(Get.context!, listen: false);
    waterVm.getUserWaterData(userInfo.user?.id ?? '');
    sleepVm.getSleepData(userID: userInfo.user?.id ?? '');

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);
      sleepVm = Provider.of<SleepTrackerProvider>(Get.context!, listen: false);
      waterVm = Provider.of<WaterTrackerProvider>(Get.context!, listen: false);
      var userInfo = Provider.of<UserModel>(Get.context!, listen: false);
      await weightVm.getWeightData(userInfo.user?.id ?? '');
      await sleepVm.getSleepData(userID: userInfo.user?.id ?? '');
      if (progress.weightTracker != null &&
          progress.weightTracker!.startingWeight != null &&
          progress.weightTracker!.startingWeight != 0) {
        progress.weightTracker!.startingWeight =
            progress.weightTracker!.startingWeight;
      }
      if (sleepVm.sleepTrackingModel != null) {
        var w = sleepVm.sleepTrackingModel?.data?.monthly?.weekly;
        for (var i = 0; i < w!.length; i++) {
          if (w[i].currentWeek == true) {
            presentWeek = i;
          }
        }
        for (var w
            in (sleepVm.sleepTrackingModel!.data?.monthly?.weekly!) ?? []) {
          dayOfWeek = DateTime.now().weekday;
          if (w.currentWeek == true) {
            if (sleepVm.sleepTrackingModel!.data!.monthly!.weekly![presentWeek]
                    .daily ==
                null) {
              totalSleep = 0;
            } else {
              totalSleep = sleepVm.sleepTrackingModel!.data!.monthly
                  ?.weekly?[presentWeek].daily?[dayOfWeek - 1].totalSleep;
            }
          }
        }
      }
    });
  }

  double bmiPlacer(bmi) {
    if (bmi > 0 && bmi <= 15) {
      return ((0 + (12 * bmi)) - 160);
    }
    if (bmi >= 15 && bmi <= 16) {
      return ((0 + (10 * bmi)) - 150);
    }
    if (bmi >= 16 && bmi <= 18.5) {
      return ((10 + (4.8 * bmi)) - 76.8);
    }
    if (bmi >= 18.5 && bmi <= 25) {
      return ((22 + (3.5 * bmi)) - 65.5);
    }
    if (bmi >= 25 && bmi <= 30) {
      return ((45 + (2.8 * bmi)) - 70);
    }
    if (bmi >= 30 && bmi <= 35) {
      return ((59 + (3 * bmi)) - 90);
    }
    if (bmi >= 35 && bmi <= 40) {
      return ((74 + (2.2 * bmi)) - 83);
    }
    return ((74 + (2.2 * 40)) - 83);
    
  }

  Text phraseToReturn(bmi) {
    if (bmi < 18.5) {
      return const Text(
        'Underweight',
        textAlign: TextAlign.end,
        style: TextStyle(color: Color(0xff560FCA)),
      );
    } else if (bmi > 18.5 && bmi < 24.9) {
      return const Text(
        'Normal',
        textAlign: TextAlign.end,
        style: TextStyle(color: Color(0xff72F2F2)),
      );
    } else if (bmi > 25.0 && bmi < 29.9) {
      return const Text(
        'Overweight',
        textAlign: TextAlign.end,
        style: TextStyle(color: Color(0xffFFE848)),
      );
    } else {
      return const Text(
        'Obese',
        textAlign: TextAlign.end,
        style: TextStyle(color: Color(0xffF9B05B)),
      );
    }
  }

  GestureDetector waterCard({newUser = false, String? user, WaterTrackerProvider? data}) {
    return newUser == false
        ? GestureDetector(
            onTap: () {
              // water home page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const WaterHomePage()));
            },
            child: Consumer<WaterTrackerProvider>(builder: (context, data, _) {
              if (data.waterTrackingModel != null) {
                glassesIntake =
                    waterVm.waterTrackingModel?.data?.glassesIntakeToday ?? 0;
                glassesGoal =
                    waterVm.waterTrackingModel?.data?.goalGlasses ?? 0;
                (glassesGoal ?? 0) - glassesIntake >= 0
                    ? glassesLeft = (glassesGoal ?? 0) - glassesIntake
                    : glassesLeft = 0;
              }
              return Container(
                width: SizeConfig.screenWidth! / 2 - 21,
                height: 200,
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 5),
                          color: Colors.black12,
                          blurRadius: 20,
                          spreadRadius: .2),
                    ],
                    color: const Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Water Intake',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      sBox(h: 1.4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: SizeConfig.safeBlockHorizontal! * 18,
                                height: SizeConfig.safeBlockHorizontal! * 18,
                                child: LiquidCircularProgressIndicator(
                                  value: (glassesIntake) / (glassesGoal ?? 0),
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.blue[300] ?? Colors.blue),
                                  backgroundColor: Colors.white,
                                  borderColor: Theme.of(context).primaryColor,
                                  borderWidth: 3.0,
                                  direction: Axis.vertical,
                                  center: Text(
                                    '${glassesLeft ?? 0}\nmore to go',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ((glassesIntake) /
                                                  (glassesGoal ?? 0)) >
                                              0.7
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              sBox(h: .5),
                              Text('$glassesIntake/${glassesGoal ?? 0}')
                            ],
                          ),
                          sBox(w: 3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily Goal:',
                                  style: TextStyle(fontSize: 12)),
                              sBox(h: .3),
                              Text('${glassesGoal ?? 0} Glasses',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              sBox(h: .3),
                              sBox(h: 1),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xff145986),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () async {
                              glassesIntake = glassesIntake + 1;
                              if ((glassesLeft ?? 0) > 0) {
                                glassesLeft =
                                    (glassesGoal ?? 0) - glassesIntake;
                              }
                              setState(() {});
                              await Provider.of<WaterTrackerProvider>(context,
                                      listen: false)
                                  .addGlass(
                                      glasses: glassesIntake,
                                      userId: userInfo.user?.id,
                                      date: DateTime.now());
                              await Provider.of<WaterTrackerProvider>(context,
                                      listen: false)
                                  .getUserWaterData(userInfo.user?.id);
                            },
                            child: const Text(
                              '\t\t\t\t+1 Glass\t\t\t\t',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          )
        : GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WaterInitPage(editGoal: false)));
            },
            child: Container(
              width: SizeConfig.screenWidth! / 2 - 21,
              height: 200,
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 5),
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: .1)
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/waterBg.png'),
                    fit: BoxFit.cover,
                  ),
                  color: const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Water Intake',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    sBox(h: 3),
                    const Text(
                      'Drinking water is essential for healthy lifestyle',
                      style: TextStyle(),
                    ),
                    sBox(h: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xff145986),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WaterInitPage(editGoal: false)));
                          },
                          child: const Text(
                            'Set Your Goal',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  String getTimeString(int value) {
    if (value != null) {
      final hour = value ~/ 60;
      final minutes = value % 60;
      return '${hour.toString().padLeft(2, "0")}h\n${minutes.toString().padLeft(2, "0")}m';
    } else {
      const hour = 0;
      const minutes = 0;
      return '${hour.toString().padLeft(2, "0")}h\n${minutes.toString().padLeft(2, "0")}m';
    }
  }

  GestureDetector sleepCard({newUser = false, SleepTrackerProvider? data}) {
    return newUser == false
        ? GestureDetector(
            onTap: () {
              // sleep home page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SleepHomePage()));
            },
            child: Container(
              width: SizeConfig.blockSizeHorizontal! * 44,
              height: 200,
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 5),
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: .1)
                  ],
                  color: const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Sleep data',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: SizeConfig.blockSizeHorizontal! * 9,
                              backgroundColor: Colors.green[100],
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: SizeConfig.blockSizeHorizontal! * 8.2,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Consumer<SleepTrackerProvider>(
                                            builder:
                                                (context, progressVm, child) {
                                          return Text(
                                            getTimeString(int.parse(
                                                totalSleep.toString() ?? '0')),
                                            style:
                                                const TextStyle(color: Colors.black),
                                          );
                                        }),
                                      ),
                                      Center(
                                        child: SizedBox(
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  17.3,
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  17.3,
                                          child: CircularProgressIndicator(
                                            value: totalSleep != null
                                                ? totalSleep! /
                                                    (data?.sleepTrackingModel
                                                            ?.data?.sleepGoal ??
                                                        0)
                                                : 0,
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation(
                                                Theme.of(context).primaryColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            sBox(h: .5),
                            const Text('Last Night\'s \nSleep')
                          ],
                        ),
                        // sBox(w: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: M,
                          children: [
                            const Text('Daily Goal:',
                                style: TextStyle(fontSize: 12)),
                            sBox(h: .3),
                            Text(
                                '${(data!.sleepTrackingModel != null ? data.sleepTrackingModel!.data!.sleepGoal! / 60 : 0).toStringAsFixed(0)} Hours',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            sBox(h: 1),
                          ],
                        )
                      ],
                    ),
                    // sBox(h: 1.2),
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'Bed Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            Flexible(
                              child: Consumer<SleepTrackerProvider>(
                                  builder: (context, sleepVM, child) {
                                return Switch(
                                    activeTrackColor:
                                        const Color(0xff145986).withOpacity(.3),
                                    activeColor: const Color(0xff145986),
                                    value: sleepVM.sleepTrackingModel?.data
                                            ?.bedTime ??
                                        false,
                                    onChanged: (val) {
                                      var user = Provider.of<UserModel>(context,
                                          listen: false);
                                      sleepVM.sleepTrackingModel?.data
                                          ?.bedTime = val;
                                      sleepVM.notifyListeners();
                                      Provider.of<SleepTrackerProvider>(
                                              Get.context!,
                                              listen: false)
                                          .setBedTime(
                                              bedTime: val,
                                              userID: user.user!.id.toString(),
                                              dateTime: DateTime.now())
                                          .then((value) {
                                        if (val == false) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const WellnessOverviewPage()));
                                        }
                                      });
                                    });
                              }),
                            ),
                          ],
                        )),
                    // sBox(h: 1)
                  ],
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              // water init page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SleepGoalPage(editGoal: false)));
            },
            child: Container(
              width: SizeConfig.screenWidth! / 2 - 21,
              height: 200,
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 5),
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: .1)
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/sleepTracker.png'),
                    fit: BoxFit.cover,
                  ),
                  color: const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Sleep Data',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // Spacer(),
                        // GestureDetector(
                        //     child: enableSleepNotif
                        //         ? Icon(
                        //             Icons.notifications_sharp,
                        //             color: Colors.black,
                        //             size: SizeConfig.blockSizeVertical * 3.5,
                        //           )
                        //         : Icon(
                        //             Icons.notifications_off_rounded,
                        //             color: Colors.black,
                        //             size: SizeConfig.blockSizeVertical * 3.5,
                        //           ),
                        //     onTap: () {
                        //       setState(() {
                        //         enableSleepNotif = !enableSleepNotif;
                        //       });
                        //     }),
                      ],
                    ),
                    const Spacer(flex: 2),
                    const Text(
                      'If you sleep better, your body functions better',
                      style: TextStyle(),
                    ),
                    // sBox(h: 7),
                    const Spacer(flex: 5),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SleepGoalPage(editGoal: false)));
                        },
                        child: const Text(
                          'Set Your Goal',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                    sBox(h: 3)
                  ],
                ),
              ),
            ),
          );
  }

  SizedBox comingSoonCard() {
    return SizedBox(
        width: SizeConfig.screenWidth! / 2 - 21,
        height: SizeConfig.blockSizeVertical! * 27,
        child: Image.asset('assets/images/comingSoonW.png', width: 450));
  }

  GestureDetector addWeightCard(weight, WellnessWeightTrackerProvider data) {
    var weightGain;

    data.weightTrackingModel != null
        ? weightGain = data.weightTrackingModel!.data!.firstWeight!.toInt() -
            data.weightTrackingModel!.data!.currentWeight!.toInt()
        : weightGain = 0;

    if (updatedWeight != null && updatedWeight != 0) {
      weight = updatedWeight;
      weightGain = data!.weightTrackingModel!.data!.firstWeight!.toInt() -
          updatedWeight!.toInt();
    }

    return weight == 0 || weight == null
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      // ignore: prefer_const_constructors
                      builder: (context) => WeightBmiEditPage(
                            fromWeight: true,
                          )));
            },
            child: Container(
              width: SizeConfig.screenWidth! / 2 - 21,
              height: 200,
              decoration: BoxDecoration(
                  boxShadow: const [
                    // ignore: prefer_const_constructors
                    BoxShadow(
                        offset: Offset(0, 5),
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: .1)
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/recordWeightbg.png'),
                    fit: BoxFit.cover,
                  ),
                  color: const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Record weight',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    sBox(h: 13),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(left: 23, right: 23),
                            backgroundColor: const Color(0xff145986),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WeightBmiEditPage(fromWeight: true)));
                          },
                          child: const Text(
                            'Add Weight',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // child: Container(
            //   width: SizeConfig.screenWidth / 2 - 20,
            //   height: SizeConfig.blockSizeVertical * 25,
            //   decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage("assets/images/recordWeightW.png"),
            //         fit: BoxFit.cover,
            //       ),
            //       color: Color(0xffFFFFFF),
            //       borderRadius: BorderRadius.circular(15)),
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            //     child: Column(
            //       children: [
            //         Spacer(flex: 6),
            //         Align(
            //           alignment: Alignment.bottomCenter,
            //           child: ElevatedButton(
            //             style: ElevatedButton.styleFrom(
            //               primary: Color(0xff145986),
            //               onPrimary: Colors.white,
            //               shape: new RoundedRectangleBorder(
            //                 borderRadius: new BorderRadius.circular(30.0),
            //               ),
            //             ),
            //             onPressed: () {
            //               Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                       builder: (context) =>
            //                           WeightBmiEditPage(fromWeight: true)));
            //             },
            //             child: Text(
            //               '\tAdd Weight\t',
            //               style: TextStyle(
            //                   fontSize: 16, fontWeight: FontWeight.bold),
            //             ),
            //           ),
            //         ),
            //         Spacer()
            //       ],
            //     ),
            //   ),
            // ),
          )
        : GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const WeightBmiEditPage(fromWeight: true)));
            },
            child: Container(
              width: SizeConfig.screenWidth! / 2 - 20,
              height: 210,
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 5),
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: .1)
                  ],
                  color: const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Record Weight',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data!.weightTrackingModel!.data!.firstWeight
                              .toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff145986)),
                        ),
                        const Text(
                          ' Kgs',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'Your current weight',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                            weightGain > 0
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: weightGain == 0
                                ? Colors.white
                                : weightGain > 0
                                    ? Colors.green
                                    : Colors.red), // color dynamic
                        sBox(w: 2),
                        RichText(
                          text: TextSpan(
                            text: weight.toString(),
                            style: TextStyle(
                                color:
                                    weightGain > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' kg',
                                style: TextStyle(
                                    color: weightGain > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff145986),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WeightBmiEditPage(fromWeight: true)));
                          },
                          child: const Text(
                            '\tAdd Weight\t',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    // sBox(h: 2)
                  ],
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProgressTrackingVM, SleepTrackerProvider,
        WaterTrackerProvider, WellnessWeightTrackerProvider>(
      builder: (context, value, sleepVm, waterVm, weightVm, child) {
        return SafeArea(
          child: value.isloading
              ? const Center(child: LoadingWidget())
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Container(
                                height: SizeConfig.safeBlockVertical! * 28,
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xffFE8276),
                                          Color(0xffFEBF76)
                                        ]),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    sBox(w: SizeConfig.screenWidth),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.arrow_back,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              const Text(
                                                'Wellness Overview',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const Text(
                                            '           Optimize your health and wellness',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //-------
                              // BMI Card
                              //-------
                              weightVm.weightTrackingModel != null &&
                                      weightVm.weightTrackingModel!.data!.bmi !=
                                          0
                                  ? Positioned(
                                      top: SizeConfig.blockSizeVertical! * 11,
                                      // right: 0,
                                      // left: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             WellnessOverviewPage()));
                                          },
                                          child: Container(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                90,
                                            height: 170,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      offset: Offset(0, 5),
                                                      color: Colors.black12,
                                                      blurRadius: 10,
                                                      spreadRadius: .1)
                                                ]),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  sBox(
                                                      w: SizeConfig
                                                          .screenWidth),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        weightVm
                                                            .weightTrackingModel!
                                                            .data!
                                                            .bmi!
                                                            .toStringAsFixed(1),
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff145986)),
                                                      ),
                                                      sBox(w: 2),
                                                      phraseToReturn(weightVm
                                                          .weightTrackingModel
                                                          ?.data!
                                                          .bmi),
                                                      const Spacer(
                                                        flex: 2,
                                                      ),
                                                      IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Color(
                                                                0xff145986),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const WeightBmiEditPage(
                                                                  fromWeight:
                                                                      false,
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                    ],
                                                  ),
                                                  const Text('Your current BMI'),
                                                  const Spacer(),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        // SizeConfig.blockSizeHorizontal * 85 total width of image
                                                        left: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            (bmiPlacer(weightVm
                                                                    .weightTrackingModel!
                                                                    .data!
                                                                    .bmi) *
                                                                1),
                                                        bottom: 0),
                                                    child: Image.asset(
                                                      'assets/images/bmiMarker.png',
                                                      scale: 7,
                                                    ),
                                                  ),
                                                  // const Spacer(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            bottom: 10),
                                                    child: Image.asset(
                                                        'assets/images/bmiIndicator2.png'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  // if weight tracker has no data
                                  : Positioned(
                                      top: SizeConfig.blockSizeVertical! * 14,
                                      // right: 0,
                                      // left: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                        ),
                                        child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const WeightBmiEditPage(
                                                            fromWeight: false,
                                                          )));
                                            },
                                            child: Stack(
                                              children: [
                                                // Image.asset(
                                                //   'assets/images/bmiCardW.png',
                                                //   scale: 3.8,
                                                // ),
                                                Container(
                                                  width:
                                                      SizeConfig.screenWidth! /
                                                              1 -
                                                          20,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                      boxShadow: const [
                                                        // ignore: prefer_const_constructors
                                                        BoxShadow(
                                                            offset:
                                                                Offset(0, 5),
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 10,
                                                            spreadRadius: .1)
                                                      ],
                                                      image: const DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/bmiCardW.png'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      color: const Color(0xffFFFFFF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: const [
                                                            Text(
                                                              'Record BMI',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        sBox(h: 1),
                                                        const Text(
                                                          'Your chances of having a longer and healthier life are improved if you have a healthy BMI',
                                                          style: TextStyle(),
                                                        ),
                                                        sBox(h: 3),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 80,
                                                  left: 110,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(0xff145986),
                                                      foregroundColor: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const WeightBmiEditPage(
                                                                      fromWeight:
                                                                          true)));
                                                    },
                                                    child: const Text(
                                                      'Record Bmi',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        // other cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              waterCard(
                                  newUser: waterVm.waterTrackingModel == null ||
                                          waterVm.waterTrackingModel?.data
                                                  ?.monthsData?.isEmpty ==
                                              true
                                      ? true
                                      : false,
                                  user: userInfo?.user?.id,
                                  data: waterVm),
                              sleepCard(
                                  newUser: (sleepVm.sleepTrackingModel?.data
                                                  ?.sleepGoal ==
                                              null ||
                                          sleepVm.sleepTrackingModel?.data
                                                  ?.monthsData?.isEmpty ==
                                              true)
                                      ? true
                                      : false,
                                  data: sleepVm)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Consumer<WellnessWeightTrackerProvider>(
                                builder: (context, value, child) {
                                  return addWeightCard(
                                      value.weightTrackingModel == null
                                          ? 0
                                          : value.weightTrackingModel!.data
                                              ?.weightHistory!.first.weight!,
                                      value);
                                },
                              ),
                              comingSoonCard()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
