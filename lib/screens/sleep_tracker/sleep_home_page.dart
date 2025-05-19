import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common/common_widgets.dart';
import '../../../common/sizeConfig.dart';
import '../../../models/index.dart';
import 'sleep_goal_page.dart';
import 'sleep_tracker_provider.dart';

class SleepHomePage extends StatefulWidget {
  const SleepHomePage({Key? key}) : super(key: key);

  @override
  State<SleepHomePage> createState() => _SleepHomePageState();
}

class _SleepHomePageState extends State<SleepHomePage>
    with SingleTickerProviderStateMixin {
  int sleeplesness = 0;
  var userInfo;
  int sleepGoal = 0;
  int glassesIntake = 1;
  int selectedIndex = 0;
  int selectedWeight = 0;
  int selectedGlasses = 0;
  int overSleep = 0;
  int monthToShow = 0;
  int totalSleep = 0;

  // bool bedTime = false;
  int presentWeek = 0;
  var w;
  var dayOfWeek = 0;
  bool emptyWeek = false;
  var progress = Provider.of<SleepTrackerProvider>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var userinfo = Provider.of<UserModel>(context, listen: false);
      await progress.getSleepData(userID: userinfo.user?.id ?? '');
      progress.notifyListeners();
    });
  }

  String getTimeString(int value) {
    final int hour = value ~/ 60;
    final int minutes = value % 60;
    return '${hour.toString().padLeft(2, "0")} hours ${minutes.toString().padLeft(2, "0")} mins';
  }

  goalCard() {
    return Consumer<SleepTrackerProvider>(builder: (context, progress, child) {
      log('Am i being rebuild here');
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffFE8276), Color(0xffFEBF76)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // your goal and add glass button
                  const Text('Your Goal:',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  sBox(h: .5),
                  Text(getTimeString(sleepGoal),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  sBox(h: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.king_bed, color: Colors.white),
                      sBox(w: 1),
                      const Text(
                        'Bedtime:',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      Consumer<SleepTrackerProvider>(
                          builder: (context, progressVm, child) {
                        return Switch(
                          activeColor: const Color(0xff145986),
                          // activeTrackColor: Colors.white,
                          // inactiveThumbColor: Colors.indigo,
                          // inactiveTrackColor: Colors.white,
                          value: progressVm.sleepTrackingModel?.data?.bedTime ??
                              false,
                          onChanged: (val) async {
                            progressVm.sleepTrackingModel?.data?.bedTime = val;
                            progressVm.notifyListeners();
                            // setState(() {
                            //   bedTime = !bedTime;
                            // });
                            await progressVm
                                .setBedTime(
                                    bedTime: progressVm.sleepTrackingModel?.data
                                            ?.bedTime ??
                                        false,
                                    userID: userInfo.user.id,
                                    dateTime: DateTime.now())
                                .then((value) async {
                              await progressVm.getSleepData(
                                  userID: userInfo.user.id);
                            });
                          },
                        );
                      })
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/alarmClock.png',
                  scale: 3,
                ),
                sBox(h: 1),
                Consumer<SleepTrackerProvider>(
                    builder: (context, progressVm, child) {
                  return Text(
                    getTimeString(int.parse(totalSleep.toString() ?? '0')),
                    // getTimeString(totalSleep),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  );
                }),
              ],
            ),
            const Spacer()
          ],
        ),
      );
    });
  }

  tabs({title, index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selectedIndex == index
                ? const Color(0xff145986)
                : Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: selectedIndex == index ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  dataBar({title, sleepIntake}) {
    num multiplier(goal) {
      int g = (goal / 60).toInt();
      switch (g) {
        case 4:
          if (sleepIntake <= 120) {
            return 22; // goal 5h - 5.6,4.4,3.45
          } else if (sleepIntake > 120 && sleepIntake <= 240) {
            return 23.5;
          } else if (sleepIntake > 240 && sleepIntake <= 360) {
            return 24;
          } else {
            return 25;
          }
        case 5:
          if (sleepIntake <= 180) {
            return 15; // goal 5h - 3.8,3.55,3
          } else if (sleepIntake > 180 && sleepIntake <= 300) {
            return 19;
          } else if (sleepIntake > 300 && sleepIntake <= 420) {
            return 20.6;
          } else {
            return 22;
          }
        case 6:
          if (sleepIntake <= 240) {
            return 11; // goal 5h - 2.75,2.95,2.65
          } else if (sleepIntake > 240 && sleepIntake <= 360) {
            return 15.8;
          } else if (sleepIntake > 360 && sleepIntake <= 480) {
            return 18;
          } else {
            return 19;
          }

        case 7:
          if (sleepIntake <= 300) {
            return 9; // goal 5h - 2.2,2.5,2.4
          } else if (sleepIntake > 300 && sleepIntake <= 420) {
            return 13.5;
          } else if (sleepIntake > 420 && sleepIntake <= 540) {
            return 16;
          } else {
            return 17;
          }
        case 8:
          if (sleepIntake <= 360) {
            return 7.5; // goal 5h - 1.9,2.2,2.2
          } else if (sleepIntake > 360 && sleepIntake <= 480) {
            return 11.8;
          } else if (sleepIntake > 480 && sleepIntake <= 600) {
            return 14.5;
          } else {
            return 15.5;
          }
        case 9:
          if (sleepIntake <= 420) {
            return 6.4; // goal 5h - 1.6,1.95,2
          } else if (sleepIntake > 420 && sleepIntake <= 540) {
            return 10.5;
          } else if (sleepIntake > 540 && sleepIntake <= 660) {
            return 13.2;
          } else {
            return 14.2;
          }
        case 10:
          if (sleepIntake <= 480) {
            return 5.5; // goal 5h - 1.4,1.75,1.85
          } else if (sleepIntake > 480 && sleepIntake <= 600) {
            return 9.5;
          } else if (sleepIntake > 600 && sleepIntake <= 720) {
            return 12;
          } else {
            return 13;
          }
        case 11:
          if (sleepIntake <= 540) {
            return 5; // goal 5h - 1.3,1.6,1.7
          } else if (sleepIntake > 180 && sleepIntake <= 660) {
            return 8.6;
          } else if (sleepIntake > 660 && sleepIntake <= 780) {
            return 11.1;
          } else {
            return 12.1;
          }
        case 12:
          if (sleepIntake <= 600) {
            return 4.5; // goal 5h - 1.1,1.5,1.6
          } else if (sleepIntake > 600 && sleepIntake <= 720) {
            return 7.9;
          } else if (sleepIntake > 720 && sleepIntake <= 840) {
            return 10.3;
          } else {
            return 11.3;
          }

        default:
          if ((sleepIntake ?? 0) <= 120) {
            return 22; // goal 5h - 5.6,4.4,3.45
          } else if ((sleepIntake ?? 0) > 120 && (sleepIntake ?? 0) <= 240) {
            return 23.5;
          } else if ((sleepIntake ?? 0) > 240 && (sleepIntake ?? 0) <= 360) {
            return 24;
          } else {
            return 25;
          }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Consumer<SleepTrackerProvider>(builder: (context, progressVm, child) {
            return Text(
              '${((sleepIntake ?? 0) / 60).toStringAsFixed(1)}h',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            );
          }),
          sBox(h: 0.5),
          Container(
            width: SizeConfig.blockSizeHorizontal! * 1.7,
            height: (sleepIntake ?? 0) == 0
                ? 10
                : (sleepIntake ?? 0) <= (sleepGoal ?? 0) + 120
                    ? (((sleepIntake ?? 0) / 60) * multiplier(sleepGoal))
                    : 150,
            decoration: BoxDecoration(
                color: sleepIntake == 0
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(22)),
          ),
          sBox(h: .5),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }

  weekOfMonth(mydate) {
    String date = DateTime.now().toString();

// This will generate the time and date for first day of month
    String firstDay = date.substring(0, 8) + '01' + date.substring(10);

// week day for the first day of the month
    int weekDay = DateTime.parse(firstDay).weekday;

    DateTime testDate = mydate;

    int weekOfMonth;

//  If your calender starts from Monday
    weekDay--;
    weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
    print('Week of the month: ${weekOfMonth - 1}');
    weekDay++;

    return weekOfMonth - 1;
  }

  selectedTab({required int index, required SleepTrackerProvider progressVm}) {
    if (progress.sleepTrackingModel?.data != null) {
      dayOfWeek = DateTime.now().weekday;
      w = progress.sleepTrackingModel?.data?.monthly?.weekly ?? 0;
      for (int i = 0; i < w.length; i++) {
        if (w[i].currentWeek == true) {
          presentWeek = i;
        }
      }
      for (var w in progress.sleepTrackingModel?.data?.monthly?.weekly ?? []) {
        if (w.currentWeek == true) {
          if (progress.sleepTrackingModel?.data?.monthly?.weekly?[presentWeek]
                  .daily ==
              null) {
            totalSleep = 0;
          } else {
            totalSleep = int.parse(
                '${progress.sleepTrackingModel?.data?.monthly?.weekly?[presentWeek].daily?[dayOfWeek - 1].totalSleep?.toStringAsFixed(0)}');
          }
        }
      }

      sleepGoal = int.parse(
              progress.sleepTrackingModel?.data?.sleepGoal.toString() ?? '0') ??
          0;
      overSleep = int.parse(
              progress.sleepTrackingModel?.data?.oversleep.toString() ?? '0') ??
          0;
      sleeplesness = int.parse(
              progress.sleepTrackingModel?.data?.sleeplessness.toString() ??
                  '0') ??
          0;
      monthToShow = int.parse(progress
                  .sleepTrackingModel?.data?.monthly?.monthNumber
                  .toString() ??
              '0') ??
          0;
    }
    switch (index) {
      case 0:
        var w = progressVm
            .sleepTrackingModel?.data?.monthly?.weekly?[presentWeek].daily;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(dayList.length, (index) {
            return dataBar(
                title: dayList[index], sleepIntake: w?[index].totalSleep);
          }),
        );
      case 1:
        var w = progressVm.sleepTrackingModel?.data?.monthly?.weekly;
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
                w?.length ?? 0,
                (index) => dataBar(
                    title: 'W${w?[index].weekNumber}',
                    sleepIntake: (w?[index].totalWeeklySleep)!)));
      case 2:
        var m = progressVm?.sleepTrackingModel?.data?.monthsData ?? [];
        List allIntake = [];
        var w = -1;
        allIntake.clear();
        for (int i = 0; i < m.length; i++) {
          if (w != i) {
            w = i + 1;
            allIntake.add(m[i].totalMonthlySleep! +
                (int.parse(m[w].totalMonthlySleep.toString() ?? '0')));
          }
        }
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
                yearList.length,
                (index) => dataBar(
                    title: yearList[index],
                    sleepIntake: ((allIntake[index]) ?? 0).toInt())));
    }
  }

  avgToShow({required SleepTrackerProvider progress}) {
    switch (selectedIndex) {
      case 0:
        return ((progress.sleepTrackingModel?.data?.monthly
                    ?.weekly?[presentWeek].avgWeeklySleep ??
                0) /
            60);
      case 1:
        return ((progress.sleepTrackingModel?.data?.monthsData?[monthToShow - 1]
                    .monthlyAvgSleep ??
                0) /
            60);
      case 2:
        return ((progress.sleepTrackingModel?.data?.avgYearlySleep ?? 0) / 60);
    }
  }

  glassGraph({overIntake, idealIntake}) {
    return Container(
        color: Colors.white,
        height: 300.0,
        child: Stack(
          children: [
            Positioned(
              // blockSize * (over intake / ideal intake)
              // top: SizeConfig.safeBlockVertical * (overIntake / idealIntake),
              // top: 0,
              left: 0,
              bottom: 230,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${(overSleep / 60).toStringAsFixed(0)}h+',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1.5,
                    color: Theme.of(context).primaryColor,
                    height: 8,
                  ),
                  const Text(
                    'Snoozing',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              // blockSize * (over intake / ideal intake) + 10
              // top: SizeConfig.safeBlockVertical * 6.5,
              // top: 60.0,
              left: 0,
              bottom: 180,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${(sleepGoal / 60).toStringAsFixed(0)}h',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.green[300],
                    height: 8,
                  ),
                  const Text(
                    'Ideal sleep',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              // blockSize * (over intake / ideal intake) + 10
              // top: SizeConfig.safeBlockVertical * 13,
              // top: 0,
              left: 0,
              bottom: 130,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${(sleeplesness / 60).toStringAsFixed(0)}h',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.green[300],
                    height: 8,
                  ),
                  const Text(
                    'Sleeplessness',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              // top: SizeConfig.blockSizeVertical * 13,
              right: 0,
              left: SizeConfig.blockSizeHorizontal! * 12,
              // top: 0,
              bottom: 80,
              child: Consumer<SleepTrackerProvider>(
                  builder: (context, sleepVm, child) {
                return selectedTab(index: selectedIndex, progressVm: sleepVm);
              }),
            ),
            Positioned(
              // top: 0,
              left: 0,
              bottom: 10,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFEDE3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: SizeConfig.blockSizeHorizontal! * 10),
                    child: Consumer<SleepTrackerProvider>(
                        builder: (context, progressVm, child) {
                      return Text(
                        'Average Sleep: ${avgToShow(progress: progressVm).toStringAsFixed(2)}h',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  List graphList = ['Week', 'Month', 'Year'];
  List dayList = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  List weekList = ['W1', 'W2', 'W3', 'W4'];
  List yearList = ['J-F', 'M-A', 'M-J', 'J-A', 'S-O', 'N-D'];
  graphCard() {
    return Consumer<SleepTrackerProvider>(builder: (context, progress, child) {
      return SizedBox(
        height: 390,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 15),
            child: Column(
              children: [
                Container(
                  width: SizeConfig.screenWidth! - 120,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          graphList.length,
                          (index) =>
                              tabs(title: graphList[index], index: index)),
                    ),
                  ),
                ),
                sBox(h: 2),
                // to be dynamic
                glassGraph(overIntake: overSleep, idealIntake: sleepGoal)
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SleepTrackerProvider>(context, listen: true);

    // if (bedTime) {
    //   Timer.periodic(const Duration(minutes: 2), (timer) {
    //     print('fetching sleep time ${timer.tick}');
    //     Provider.of<ProgressTrackingVM>(context, listen: false).getProgress();
    //     progress = Provider.of<ProgressTrackingVM>(context, listen: false);
    //     setState(() {
    //       totalSleep = progress.sleepTrackerData.totalSleep;
    //     });
    //   });
    // }
    userInfo = Provider.of<UserModel>(context, listen: false);
    // debugPrint("_____YEAR:${progress.sleepTrackerData?.year}");
    return Consumer<SleepTrackerProvider>(builder: (context, sleep, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 30,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sleep Data',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Track your daily sleep',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SleepGoalPage(editGoal: true)));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff145986),
                    minimumSize: Size(SizeConfig.blockSizeHorizontal! * 5,
                        SizeConfig.blockSizeVertical! * 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Edit Goal', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [goalCard(), sBox(h: 4), graphCard()],
            ),
          ),
        ),
      );
    });
  }
}
