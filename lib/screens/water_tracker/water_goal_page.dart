import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertical_picker/vertical_picker.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/user_model.dart';
import 'water_home_page.dart';
import 'water_info_page.dart';
import 'water_tracker_provider.dart';

class WaterInitPage extends StatefulWidget {
  final bool? editGoal;
  final userWeight;
  var waterIntake;
  WaterInitPage({Key? key, this.editGoal, this.userWeight, this.waterIntake})
      : super(key: key);

  @override
  State<WaterInitPage> createState() => _WaterInitPageState();
}

class _WaterInitPageState extends State<WaterInitPage> {
  int selectedWeight = 0;
  List<int> weightList = List.empty(growable: true);
  List<int> glassesList = List.empty(growable: true);
  bool isSelectingWeight = true;
  int selectedGlassesIndex = 0;
  int userSelectedGlasses = 0;
  var userInfo;
  bool loading = false;

  @override
  void initState() {
    List.generate(81, (index) {
      weightList.add(40 + index);
    });
    List.generate(8, (index) => glassesList.add(5 + index));
    super.initState();
  }

  void getGlasses({weightIndex, glassesIndex}) {
    var weight = weightList[weightIndex];
    setState(() {
      if (weight >= 40 && weight < 50) {
        selectedGlassesIndex = 0;
      }
      if (weight >= 50 && weight < 60) {
        selectedGlassesIndex = 1;
      }
      if (weight >= 60 && weight < 70) {
        selectedGlassesIndex = 2;
      }
      if (weight >= 70 && weight < 80) {
        selectedGlassesIndex = 3;
      }
      if (weight >= 80 && weight < 90) {
        selectedGlassesIndex = 4;
      }
      if (weight >= 90 && weight < 100) {
        selectedGlassesIndex = 5;
      }
      if (weight >= 100 && weight < 110) {
        selectedGlassesIndex = 6;
      }
      if (weight >= 110 && weight < 120) {
        selectedGlassesIndex = 7;
      }
      if (weight >= 120) {
        selectedGlassesIndex = 7;
      }
    });
  }

  Row glassesCounter() {
    return Row(
      children: [
        const Text(
          'Glasses:',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff145986), width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selectedGlassesIndex > 0) {
                  selectedGlassesIndex--;
                }
              });
            },
            child: const Icon((Icons.remove), color: Color(0xff145986)),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(10)),
          child: Text(
            glassesList[selectedGlassesIndex].toString(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              if (selectedGlassesIndex < 7) {
                selectedGlassesIndex++;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff145986), width: 2),
                borderRadius: BorderRadius.circular(6)),
            child: const Icon((Icons.add), color: Color(0xff145986)),
          ),
        ),
        const Spacer(
          flex: 3,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => WaterHomePage()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.editGoal!
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
              Image.asset('assets/images/waterTip.png'),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/weightScaleIcon.png',
                            color: Theme.of(context).primaryColor,
                          ),
                          sBox(w: 5),
                          const Text(
                            'Adjust your weight to set your goal',
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
                          Flexible(
                            child: SizedBox(
                              height: SizeConfig.blockSizeVertical! * 20,
                              // width: SizeConfig.screenWidth,
                              child: VerticalPicker(
                                leftMargin:
                                    SizeConfig.safeBlockHorizontal! * 22,
                                rightMargin:
                                    SizeConfig.safeBlockHorizontal! * 22,
                                borderColor: Colors.black26,
                                itemHeight: SizeConfig.blockSizeVertical! * 10,
                                // MediaQuery.of(context).size.height / 15,
                                items: List.generate(
                                    81,
                                    (index) => Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                (40 + index).toString(),
                                                style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff145986)),
                                              ),
                                              sBox(w: 1),
                                              const Text(
                                                'kg',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Color(0xff145986)),
                                              )
                                            ],
                                          ),
                                        )),
                                onSelectedChanged: (index) {
                                  setState(() {
                                    selectedWeight = index;
                                    if (isSelectingWeight == false) {
                                      getGlasses(weightIndex: index);
                                      isSelectingWeight = true;
                                    } else {
                                      isSelectingWeight = true;
                                      getGlasses(weightIndex: index);
                                      selectedWeight = index;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          // ),
                          // GestureDetector(
                          //   onTapDown: (TapDownDetails t) {
                          //     setState(() {
                          //       isSelectingWeight = false;
                          //       getGlasses(weightIndex: selectedWeight);
                          //     });
                          //   },
                          //   child: isSelectingWeight
                          //       ?
                          //       // Expanded(
                          //       //     child:
                          //       Container(
                          //           width: SizeConfig.blockSizeHorizontal * 40,
                          //           padding: EdgeInsets.symmetric(
                          //               vertical:
                          //                   SizeConfig.blockSizeVertical * .02,
                          //               horizontal: 10),
                          //           decoration: BoxDecoration(
                          //             border: Border(
                          //               top: BorderSide(
                          //                   width: 2.15, color: Colors.black26),
                          //               bottom: BorderSide(
                          //                   width: 2, color: Colors.black26),
                          //             ),
                          //           ),
                          //           child: Center(
                          //             child: Text(
                          //               glassesList[selectedGlassesIndex]
                          //                       .toString() +
                          //                   ' glasses',
                          //               style: TextStyle(
                          //                   fontSize: 22,
                          //                   color: Color(0xff145986)),
                          //             ),
                          //             // ),
                          //           ),
                          //         )
                          //       : Container(
                          //           height: SizeConfig.blockSizeVertical * 20,
                          //           width: SizeConfig.blockSizeHorizontal * 40,
                          //           child: VerticalPicker(
                          //             borderColor: Colors.black26,
                          //             itemHeight:
                          //                 MediaQuery.of(context).size.height /
                          //                     15,
                          //             items: List.generate(
                          //                 8,
                          //                 (index) => Center(
                          //                       child: Text(
                          //                         (5 + index).toString() +
                          //                             ' glasses',
                          //                         style: TextStyle(
                          //                             fontSize: 22,
                          //                             color: Color(0xff145986)),
                          //                       ),
                          //                     )),
                          //             onSelectedChanged: (indexSelected) {
                          //               setState(() {
                          //                 isSelectingWeight = false;
                          //                 userSelectedGlasses = indexSelected;
                          //                 getGlasses(
                          //                     weightIndex: selectedWeight);
                          //               });
                          //             },
                          //           ),
                          //         ),
                          // ),
                        ],
                      ),
                      sBox(h: 4),
                      glassesCounter(),
                      sBox(h: 3),
                      // Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (loading == false) {
                            setState(() {
                              loading = true;
                            });
                            if (widget.waterIntake != null &&
                                widget.waterIntake != 0) {
                              widget.waterIntake = widget.waterIntake;
                            } else {
                              widget.waterIntake = 0;
                            }

                            await Provider.of<WaterTrackerProvider>(context,
                                    listen: false)
                                .setWaterGoal(
                              userId: userInfo.user.id,
                              weight: weightList[selectedWeight],
                              goalGlasses: glassesList[selectedGlassesIndex],
                              overIntake: glassesList[selectedGlassesIndex] + 4,
                            )
                                .then((value) async {
                              if (value == true) {
                                await Provider.of<WaterTrackerProvider>(context,
                                        listen: false)
                                    .addGlass(
                                        glasses: widget.waterIntake,
                                        userId: userInfo.user.id,
                                        date: DateTime.now());
                                await Provider.of<WaterTrackerProvider>(context,
                                        listen: false)
                                    .getUserWaterData(userInfo.user.id);
                                setState(() {
                                  loading = false;
                                });
                                widget.editGoal!
                                    ? await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WaterHomePage()))
                                    : await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WaterHomePage()));
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff145986),
                            minimumSize: Size(SizeConfig.screenWidth!,
                                SizeConfig.blockSizeVertical! * 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40))),
                        child: loading
                            ? SizedBox(
                                height: SizeConfig.blockSizeVertical! * 5,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('SAVE',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              sBox(h: 2),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const WaterInfoPage()));
                },
                child: Text(
                  'Ideal water Intake',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
