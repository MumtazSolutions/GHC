import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/index.dart';
import '../progress/wellness_overview_page.dart';
import 'water_goal_page.dart';
import 'water_tracker_provider.dart';

class WaterHomePage extends StatefulWidget {
  const WaterHomePage({Key? key}) : super(key: key);

  @override
  State<WaterHomePage> createState() => _WaterHomePageState();
}

class _WaterHomePageState extends State<WaterHomePage> {
  int? glassesLeft;
  var userInfo;
  int glassesGoal = 0;
  int glassesIntake = 1;
  int selectedIndex = 0;
  int selectedWeight = 0;
  int selectedGlasses = 0;
  int overIntake = 0;
  int monthToShow = 0;
  var progress = Provider.of<WaterTrackerProvider>(Get.context!, listen: false);
  int presentWeek = 0;

  @override
  void initState() {
    glassesIntake = progress.waterTrackingModel?.data?.glassesIntakeToday ?? 0;
    glassesGoal = progress.waterTrackingModel?.data?.goalGlasses ?? 0;
    glassesGoal - glassesIntake >= 0
        ? glassesLeft = glassesGoal - glassesIntake
        : glassesLeft = 0;
    overIntake = progress.waterTrackingModel?.data?.overIntake ?? 0;
    monthToShow = progress.waterTrackingModel?.data?.monthly?.monthNumber ?? 0;

    var w = progress.waterTrackingModel?.data?.monthly?.weekly;

    for (var i = 0; i < int.parse(w?.length.toString() ?? '0'); i++) {
      if (w?[i].currentWeek == true) {
        presentWeek = i;
      }
    }
    super.initState();
  }

  glassImagetoDisplay(glasses) {
    if (glasses >= glassesGoal / 2 && glasses < glassesGoal) {
      return 'assets/images/halfFilledGlass.png';
    }
    if (glasses < glassesGoal / 2) {
      return 'assets/images/emptyGlass.png';
    }
    if (glasses >= glassesGoal) {
      return 'assets/images/fullFilledGlass.png';
    }
  }

  goalCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffFE8276), Color(0xffFEBF76)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // your goal anf add glass button
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Goal:',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        sBox(h: .5),
                        Text(
                            '$glassesGoal Glasses(${glassesGoal * 200}ml)',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        sBox(h: 2),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xff145986), backgroundColor: Colors.white, minimumSize: Size(
                                SizeConfig.blockSizeHorizontal! * 5,
                                SizeConfig.safeBlockVertical! * 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              glassesIntake = glassesIntake + 1;
                              if (glassesLeft! > 0) {
                                glassesLeft = glassesGoal - glassesIntake;
                              }
                            });
                            await Provider.of<WaterTrackerProvider>(context,
                                    listen: false)
                                .addGlass(
                                    glasses: glassesIntake,
                                    userId: userInfo.user.id,
                                    date: DateTime.now());
                            await Provider.of<WaterTrackerProvider>(context,
                                    listen: false)
                                .getUserWaterData(userInfo.user.id);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '\t+1 Glass\t',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        sBox(h: 1),
                      ],
                    ),
                    // sBox(w: 20),
                    const Spacer(),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal! * 28,
                      height: SizeConfig.safeBlockHorizontal! * 28,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            right: 2,
                            left: 0,
                            child: Text(
                              '${200 * glassesGoal} ml',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            top: SizeConfig.blockSizeVertical! * 11,
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: const Text(
                              '200 ml',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 6),
                              child: Image.asset(
                                  glassImagetoDisplay(glassesIntake)))
                        ],
                      ),
                    )
                  ],
                ),
                Text(
                  '$glassesIntake/$glassesGoal( $glassesLeft more to go)',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                sBox(h: 1.5),
                SizedBox(
                  width: SizeConfig.safeBlockHorizontal! * 78,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    child: LinearProgressIndicator(
                      minHeight: SizeConfig.safeBlockVertical! * 1.1,
                      value: glassesIntake / glassesGoal,
                      backgroundColor: const Color(0xffFFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[100] ?? Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
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

  getBarHeight(barHeight) {
    barHeight = barHeight + 10;
    return barHeight;
  }

  dataBar({title, glasses}) {
    var goalGlasses = overIntake - 4;
    var barHeight = 0.0;

    if (glassesIntake > goalGlasses && goalGlasses == 5) {
      barHeight = 19.0;
    } else if (glassesIntake > goalGlasses && goalGlasses == 6) {
      barHeight = 16.4;
    } else if (glassesIntake > goalGlasses && goalGlasses == 7) {
      barHeight = 14.2;
    } else if (glassesIntake > goalGlasses && goalGlasses == 8) {
      barHeight = 13.6;
    } else if (glassesIntake > goalGlasses && goalGlasses == 9) {
      barHeight = 12.0;
    } else if (glassesIntake > goalGlasses && goalGlasses == 10) {
      barHeight = 11;
    } else if (glassesIntake > goalGlasses && goalGlasses == 11) {
      barHeight = 10.1;
    } else if (glassesIntake > goalGlasses && goalGlasses == 12) {
      barHeight = 9.3;
    } else if (goalGlasses == 5) {
      barHeight = 21.5;
    } else if (goalGlasses == 6) {
      barHeight = 18;
    } else if (goalGlasses == 7) {
      barHeight = 15.4;
    } else if (goalGlasses == 8) {
      barHeight = 13.5;
    } else if (goalGlasses == 9) {
      barHeight = 12;
    } else if (goalGlasses == 10) {
      barHeight = 10.8;
    } else if (goalGlasses == 11) {
      barHeight = 9.8;
    } else if (goalGlasses == 12) {
      barHeight = 9;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            glasses.toString() + 'g',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          sBox(h: .5),
          Container(
            width: SizeConfig.blockSizeHorizontal! * 1.7,
            height: glasses == 0
                ? 10
                : glasses > overIntake
                    ? 165
                    : glasses == overIntake
                        ? 158
                        : glasses * barHeight,
            decoration: BoxDecoration(
                color:
                    glasses == 0 ? Colors.grey : Theme.of(context).primaryColor,
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

  int weekOfMonth(mydate) {
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

    return weekOfMonth;
  }

  dynamic selectedTab({required int index, required WaterTrackerProvider waterVm}) {
    switch (index) {
      case 0:
        var m = waterVm.waterTrackingModel?.data?.monthly?.weekly?[presentWeek]
                .daily ??
            [];

        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
                dayList.length,
                (index) => dataBar(
                    title: dayList[index],
                    glasses: m.isEmpty
                        ? 0
                        : index == DateTime.now().weekday
                            ? glassesIntake
                            : m[index].waterIntake)));
      case 1:
        var w = waterVm.waterTrackingModel?.data?.monthly?.weekly ?? [];
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
                w.length,
                (index) => dataBar(
                    title: 'W${w[index].weekNumber}',
                    glasses: w[index].totalWeeklyIntake)));
      case 2:
        var m = waterVm.waterTrackingModel?.data?.monthsData ?? [];
        var allIntake = [];
        var w = -1;
        allIntake.clear();
        for (var i = 0; i < m.length; i++) {
          if (w != i) {
            w = i + 1;
            allIntake.add(m[i].totalMonthlyIntake! + m[w].totalMonthlyIntake!);
          }
        }
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
                yearList.length,
                (index) => dataBar(
                    title: yearList[index], glasses: allIntake[index])));
    }
  }

  avgToShow() {
    switch (selectedIndex) {
      case 0:
        return progress.waterTrackingModel?.data?.monthly?.weekly![presentWeek]
            .weeklyAvgIntake;
      case 1:
        return progress.waterTrackingModel?.data?.monthsData![monthToShow - 1]
            .monthlyAvgIntake;
      case 2:
        return progress.waterTrackingModel!.data?.yearlyAvgIntake;
    }
  }

  glassGraph({overIntake, idealIntake, required WaterTrackerProvider waterVm}) {
    return Container(
      color: Colors.white,
      height: 300,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 0,
            bottom: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${overIntake}g',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 1.5,
                  color: Theme.of(context).primaryColor,
                  height: 8,
                ),
                const Text(
                  'Over intake',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            bottom: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${idealIntake}g',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.green[300],
                  height: 8,
                ),
                const Text(
                  'Ideal intake',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            left: SizeConfig.blockSizeHorizontal! * 12,
            bottom: 90,
            right: SizeConfig.blockSizeHorizontal! * 0,
            child: selectedTab(index: selectedIndex, waterVm: waterVm),
          ),
          Positioned(
            top: 220,
            left: 0,
            bottom: 0,
            right: 0,
            child: Align(
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
                  child: Text(
                    'Average Intake: ${avgToShow().toString()} glasses(${(double.parse(avgToShow().toString()) * 200).toStringAsFixed(2)} ml)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      // ),
    );
  }

  List graphList = ['Week', 'Month', 'Year'];
  List dayList = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  List weekList = ['W1', 'W2', 'W3', 'W4'];
  List yearList = ['J-F', 'M-A', 'M-J', 'J-A', 'S-O', 'N-D'];
  graphCard({required WaterTrackerProvider waterVm}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  children: List.generate(graphList.length,
                      (index) => tabs(title: graphList[index], index: index)),
                ),
              ),
            ),
            sBox(h: 5),
            // to be dynamic
            glassGraph(
                overIntake: overIntake,
                idealIntake: glassesGoal,
                waterVm: waterVm)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserModel>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const WellnessOverviewPage()));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 25,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WellnessOverviewPage()));
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Icon(Icons.arrow_back),
            ),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Water Intake',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Track your daily water intake',
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
                          builder: (context) => WaterInitPage(
                              editGoal: true,
                              userWeight:
                                  progress.waterTrackingModel!.data?.weight,
                              waterIntake: progress.waterTrackingModel!.data
                                  ?.glassesIntakeToday)));
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
              children: [
                goalCard(),
                sBox(h: 4),
                Consumer<WaterTrackerProvider>(
                  builder: (context, waterVm, child) {
                    return graphCard(waterVm: waterVm);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
