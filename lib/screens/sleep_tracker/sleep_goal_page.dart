
import 'package:flutter/material.dart';
import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:vertical_picker/vertical_picker.dart';

import 'sleep_home_page.dart';
import 'sleep_tracker_provider.dart';

class SleepGoalPage extends StatefulWidget {
  final bool editGoal;
  SleepGoalPage({Key? key, required this.editGoal}) : super(key: key);

  @override
  State<SleepGoalPage> createState() => _SleepGoalPageState();
}

class _SleepGoalPageState extends State<SleepGoalPage> {
  int selectedWeight = 0;
  List<int> hourList = List.empty(growable: true);
  List<int> minsList = List.empty(growable: true);
  int selectedHours = 0;
  int selectedMins = 0;
  var userInfo;
  bool loading = false;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
    //   var  user = Provider.of<UserModel>(context, listen: false);
    //   await Provider.of<SleepTrackerProvider>(context, listen: false).getSleepData(userID: user.user?.id??'');
    //
    // });
    List.generate(9, (index) {
      hourList.add(index);
    });
    List.generate(4, (index) => minsList.add(15 * index));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserModel>(context, listen: false);
    Provider.of<SleepTrackerProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.editGoal
                      ? 'Edit your daily goal'
                      : 'Set your daily goal',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              sBox(h: 1),
              Image.asset('assets/images/sleepTip.png'),
              sBox(h: 2),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.access_time,
                              color: Theme.of(context).primaryColor),
                          sBox(w: 5),
                          const Text(
                            'Choose Hours',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1.5,
                      ),
                      sBox(h: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: SizeConfig.blockSizeVertical! * 20,
                              // width: SizeConfig.blockSizeHorizontal * 20,
                              child: VerticalPicker(
                                borderColor: Colors.black26,
                                itemHeight:
                                    MediaQuery.of(context).size.height / 15,
                                items: List.generate(
                                    9,
                                    (index) => Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                (04 + index).toString(),
                                                style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff145986)),
                                              ),
                                              sBox(w: 1),
                                              const Text(
                                                'H',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Color(0xff145986)),
                                              )
                                            ],
                                          ),
                                        )),
                                onSelectedChanged: (index) {
                                  setState(() {
                                    selectedHours = index;
                                  });
                                },
                              ),
                            ),
                          ),
                          // ),
                          Container(
                            height: SizeConfig.blockSizeVertical! * 20,
                            width: SizeConfig.blockSizeHorizontal! * 40,
                            child: VerticalPicker(
                              borderColor: Colors.black26,
                              itemHeight:
                                  MediaQuery.of(context).size.height / 15,
                              items: List.generate(
                                  4,
                                  (index) => Center(
                                        child: Text(
                                          (15 * index).toString() + ' Mins',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Color(0xff145986)),
                                        ),
                                      )),
                              onSelectedChanged: (indexSelected) {
                                setState(() {
                                  selectedMins = indexSelected;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      sBox(h: 2),
                      Consumer<SleepTrackerProvider>(
                          builder: (context, sleepVM, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            widget.editGoal == true
                                ? await sleepVM
                                    .setSleepGoal(
                                        userID: userInfo.user.id,
                                        sleepGoal: ((hourList[selectedHours] + 4) * 60) +
                                            minsList[selectedMins],
                                        overSleep: (((hourList[selectedHours] + 4) * 60) +
                                                minsList[selectedMins]) +
                                            120,
                                        sleepLessNess:
                                            (((hourList[selectedHours] + 4) * 60) +
                                                    minsList[selectedMins]) -
                                                120)
                                    .then((value) async {
                                    await sleepVM
                                        .getSleepData(userID: userInfo.user.id)
                                        .then((value) {
                                      sleepVM.notifyListeners();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SleepHomePage()));
                                    });

                                    // widget.editGoal
                                    //     ? await Navigator.pushReplacement(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (context) =>
                                    //                 SleepHomePage()))
                                    //     : await Navigator.pushReplacement(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (context) =>
                                    //                 SleepHomePage()));
                                  })
                                : await sleepVM
                                    .setSleepGoal(
                                        userID: userInfo.user.id,
                                        sleepGoal: ((hourList[selectedHours] + 4) * 60) +
                                            minsList[selectedMins],
                                        overSleep:
                                            (((hourList[selectedHours] + 4) * 60) +
                                                    minsList[selectedMins]) +
                                                120,
                                        sleepLessNess:
                                            (((hourList[selectedHours] + 4) * 60) +
                                                    minsList[selectedMins]) -
                                                120)
                                    .then((value) async {
                                    await sleepVM
                                        .setBedTime(
                                            userID: userInfo.user.id,
                                            dateTime: DateTime.now(),
                                            bedTime: true)
                                        .then((value) async {
                                      await sleepVM
                                          .setBedTime(
                                              userID: userInfo.user.id,
                                              dateTime: DateTime.now(),
                                              bedTime: false)
                                          .then((value) async {
                                        await sleepVM
                                            .getSleepData(
                                                userID: userInfo.user.id)
                                            .then((value) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SleepHomePage()));
                                        });
                                      });
                                    });
                                  });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: const Color(0xff145986),
                              minimumSize: Size(SizeConfig.screenWidth ?? 0,
                                  SizeConfig.blockSizeVertical! * 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40))),
                          child: sleepVM.isLoading
                              ? SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 4,
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('SAVE',
                                  style: TextStyle(color: Colors.white)),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              sBox(h: 2),
            ],
          ),
        ),
      ),
    );
  }
}
