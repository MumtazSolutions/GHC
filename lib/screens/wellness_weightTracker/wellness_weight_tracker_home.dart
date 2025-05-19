import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../models/user_model.dart';
import '../progress/wellness_overview_page.dart';
import 'wellness_wieght_tracker_provider.dart';

class WeightBmiEditPage extends StatefulWidget {
  final fromWeight;
  const WeightBmiEditPage({Key? key, this.fromWeight}) : super(key: key);

  @override
  State<WeightBmiEditPage> createState() => _WeightBmiEditPageState();
}

class _WeightBmiEditPageState extends State<WeightBmiEditPage> {
  bool loading = false;
  List<int> weightList = List.empty(growable: true);
  List<num> decimalList = List.empty(growable: true);
  List<int> heightList = List.empty(growable: true);
  int selectedWeight = 0;
  int selectedheight = 0;
  int selectedDecimal = 0;
  int pickerToshow = 0;
  List graphList = ['Weight', 'Height'];
  int? updatedWeight;
  int? updatedHeight;

  num bmi = 15;
  final _formKey = GlobalKey<FormState>();
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();

  @override
  void initState() {
    var w = Provider.of<WellnessWeightTrackerProvider>(context, listen: false);
    List.generate(81, (index) {
      weightList.add(40 + index);
    });
    List.generate(226, (index) {
      heightList.add(50 + index);
    });
    List.generate(9, (index) => decimalList.add(((index + 1) / 10)));
    w.weightTrackingModel != null
        ? bmi = w.weightTrackingModel!.data!.bmi!
        : bmi = 15;
    if (w.weightTrackingModel != null &&
        w.weightTrackingModel!.data!.currentWeight != 0) {
      weight = TextEditingController(
          text: w.weightTrackingModel!.data!.currentWeight.toString());
    }
    if (w.weightTrackingModel != null &&
        w.weightTrackingModel!.data!.currentHeight != 0) {
      height = TextEditingController(
          text: w.weightTrackingModel!.data!.currentHeight.toString());
    }

    super.initState();
  }

  ElevatedButton saveButton() {
    var userInfo = Provider.of<UserModel>(context, listen: false);
    var progress =
        Provider.of<WellnessWeightTrackerProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate() == true) {
          setState(() {
            bmi = num.parse(weight.text) /
                ((num.parse(height.text) / 100) *
                    (num.parse(height.text) / 100));
          });
          if (progress.weightTrackingModel == null ||
              progress.weightTrackingModel!.data!.weightHistory!.first.createdAt
                      .toString() ==
                  '' ||
              DateFormat.yMMMd().format(DateTime.parse(progress
                      .weightTrackingModel!.data!.weightHistory!.first.createdAt
                      .toString())) !=
                  DateFormat.yMMMd().format(DateTime.now())) {
            if (loading == false) {
              setState(() {
                loading = true;
              });

              await progress
                  .setHeightWeight(
                      userId: userInfo.user!.id,
                      height: num.parse(height.text),
                      weight: num.parse(weight.text))
                  .then((value) {
                if (value == true) {
                  setState(() {
                    loading = false;
                  });

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WellnessOverviewPage()));
                } else {
                  Fluttertoast.showToast(
                      msg: 'Error! Try again...',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white);
                }
              });
            }
          } else {
            await Fluttertoast.showToast(
                msg: 'Already Updated for Today',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white);
          }
        } else {
          printLog('out');
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff145986),
          minimumSize:
              Size(SizeConfig.screenWidth!, SizeConfig.blockSizeVertical! * 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
      child: loading
          ? SizedBox(
              height: SizeConfig.blockSizeVertical! * 3,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('SAVE', style: TextStyle(color: Colors.white)),
    );
  }

  Padding pickerToShow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      'Update Weight and Height',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1.5,
                ),
                sBox(h: 3),
                Row(
                  children: [
                    Text(
                      'Weight',
                      style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                    ),
                    sBox(w: 6),
                    Flexible(
                      child: TextFormField(
                        controller: weight,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'in kgs',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Can not be empty';
                          }
                          return null;
                        },
                      ),
                    )
                  ],
                ),
                sBox(h: 1),
                Row(
                  children: [
                    Text(
                      'Height',
                      style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                    ),
                    sBox(w: 6),
                    Flexible(
                      child: TextFormField(
                        controller: height,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'in cms',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Can not be empty';
                          }
                          if (num.parse(value) < 100) {
                            return 'Height must be greater 100 cm';
                          }

                          return null;
                        },
                      ),
                    )
                  ],
                ),
                sBox(h: 4),
                saveButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  double bmiPlacer(bmi) {
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
        style: TextStyle(color: Color(0xff560FCA)),
      );
    } else if (bmi > 18.5 && bmi < 24.9) {
      return const Text(
        'Normal',
        style: TextStyle(color: Color(0xff72F2F2)),
      );
    } else if (bmi > 25.0 && bmi < 29.9) {
      return const Text(
        'Overweight',
        style: TextStyle(color: Color(0xffFFE848)),
      );
    } else {
      return const Text(
        'Obese',
        style: TextStyle(color: Color(0xffF9B05B)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: SizeConfig.safeBlockVertical! * 46,
                color: Colors.white,
                child: Stack(
                  children: [
                    Container(
                      height: SizeConfig.safeBlockVertical! * 28,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffFE8276), Color(0xffFEBF76)]),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sBox(w: SizeConfig.screenWidth),
                          Padding(
                            padding: const EdgeInsets.only(left: 0, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                          fontWeight: FontWeight.bold),
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
                    Positioned(
                      top: SizeConfig.blockSizeVertical! * 12,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            height: 180,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sBox(w: SizeConfig.screenWidth),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        bmi.toStringAsFixed(1),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff145986)),
                                      ),
                                      sBox(w: 2),
                                      phraseToReturn(bmi),
                                      const Spacer(
                                        flex: 2,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Text('Your current BMI'),
                                  const Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      // SizeConfig.blockSizeHorizontal * 85 total width of image
                                      left: bmi == 0
                                          ? SizeConfig.blockSizeHorizontal! *
                                              (bmiPlacer(15) * 1)
                                          : SizeConfig.blockSizeHorizontal! *
                                              (bmiPlacer(bmi) * 1),
                                    ),
                                    child: Image.asset(
                                      'assets/images/bmiMarker.png',
                                      scale: 7,
                                    ),
                                  ),
                                  // Spacer(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Image.asset(
                                        'assets/images/bmiIndicator2.png'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sBox(h: 3),
              pickerToShow()
            ],
          ),
        ),
      ),
    );
  }
}
