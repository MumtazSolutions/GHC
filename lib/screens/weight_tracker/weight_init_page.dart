import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../app.dart';
import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../models/index.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../progress/progress_categories.dart';
import 'weight_home_page.dart';

// import 'package:syncfusion_flutter_sliders/sliders.dart';

class WeightInitPage extends StatefulWidget {
  const WeightInitPage({Key? key}) : super(key: key);

  @override
  _WeightInitPageState createState() => _WeightInitPageState();
}

class _WeightInitPageState extends State<WeightInitPage> {
  double _hvalue = 170;
  ScrollController? _controller;
  double _scrollPosition = 0.0;
  var progressVm=Provider.of<ProgressTrackingVM>(Get.context!,listen:false);

  var x;
  var bmi;
  var c = 1.0;
  List a = [];
  String? msg;

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
                    App.fluxStoreNavigatorKey.currentContext!,
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

  void _scrollListener() {
    setState(() {
      _scrollPosition = _controller!.position.pixels;
    });
  }

  Widget weightPicker() {
    a.clear();
    for (int i = 0; i < 9; i++) {
      a.add('assets/images/scale.png');
    }
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 19,
      width: SizeConfig.screenWidth,
      child: Stack(
        children: [
          Image.asset('assets/images/weightScale1.png'),
          Positioned(
            top: SizeConfig.safeBlockVertical! * 2,
            left: SizeConfig.safeBlockHorizontal! * 35.5,
            child: Text('${(_scrollPosition / 10).toStringAsFixed(1)} Kg',
                style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: SizeConfig.safeBlockVertical! * 7,
            left: SizeConfig.safeBlockHorizontal! * 45,
            child: Image.asset('assets/images/scaleMarker.png'),
          ),
          Positioned(
            top: 0,
            right: SizeConfig.blockSizeHorizontal! * 7,
            left: SizeConfig.blockSizeHorizontal! * 2,
            bottom: 0,
            child: NotificationListener(
                onNotification: (t) {
                  setState(calcBMI);
                  return true;
                },
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: a.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: SizeConfig.blockSizeVertical! * 40,
                      child: Image.asset(a[index]),
                    );
                  },
                )),
          )
        ],
      ),
    );
  }

  Widget heightPicker() {
    return SizedBox(
      width: SizeConfig.screenWidth,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/heightScale1.png',
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            top: SizeConfig.blockSizeVertical! * 4,
            left: 0,
            right: SizeConfig.blockSizeHorizontal! * 5,
            child: Column(
              children: [
                Text(
                  '${_hvalue.toStringAsFixed(1)} cm',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SfSlider(
                  min: 110.0,
                  max: 250.0,
                  value: _hvalue,
                  interval: 20,
                  showTicks: true,
                  showLabels: true,
                  // enableTooltip: true,
                  minorTicksPerInterval: 1,
                  thumbShape: const SfThumbShape(),
                  onChanged: (dynamic value) {
                    setState(() {
                      _hvalue = value;
                      calcBMI();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // phraseToReturn() {
  //   if (UserPreferences().bmi < 18.5) {
  //     return 'Gain muscle weight';
  //   } else if (UserPreferences().bmi > 18.5 && UserPreferences().bmi < 24.9) {
  //     return 'You are healthy';
  //   } else if (UserPreferences().bmi > 25.0 && UserPreferences().bmi < 29.9) {
  //     return 'Try eating healthy';
  //   } else {
  //     return 'Burn those extra kilos';
  //   }
  // }

  double calcBMI() {
    setState(() {
      bmi = (_scrollPosition / 10) / ((_hvalue / 100) * (_hvalue / 100));
      // msg = phraseToReturn();
    });
    print(bmi.toStringAsFixed(1));
    return bmi;
  }

  dynamic returnNum() {
    if (bmi > 34) {
      return SizeConfig.blockSizeHorizontal! * 81;
    } else if (bmi < 16) {
      return SizeConfig.blockSizeHorizontal! * 4;
    } else if (bmi >= 29.8 && bmi <= 40) {
      return SizeConfig.blockSizeHorizontal! * 4 * 1.05 * (bmi - 15);
    } else {
      return SizeConfig.blockSizeHorizontal! * 4 * 1.05 * (bmi - 15);
    }
  }

  Widget bmiIndicator() {
    return SizedBox(
      width: SizeConfig.screenWidth,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/bmi1.png',
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            top: SizeConfig.safeBlockVertical! * 6,
            left: returnNum(),
            child: Image.asset('assets/images/scaleMarker.png'),
          ),
          Positioned(
            top: SizeConfig.blockSizeVertical! * 1.3,
            right: SizeConfig.blockSizeHorizontal! * 14,
            child: Text(
              bmi.toStringAsFixed(1),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Positioned(
          //   top: SizeConfig.blockSizeVertical * 1.7,
          //   right: SizeConfig.blockSizeHorizontal * 10,
          //   child: Text(
          //     msg,
          //     style: TextStyle(
          //         fontSize: 14,
          //         color: Theme.of(context).primaryColor,
          //         fontWeight: FontWeight.bold),
          //   ),
          // )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    x = SizeConfig.safeBlockHorizontal! * 6;
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller!.jumpTo(500);
    });
    calcBMI();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('_____________IN WEIGHT LOSS');

    final userInfo = Provider.of<UserModel>(context);
    // var weightData = Provider.of<ProgressTrackingVM>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProgressCategories()))),
      ),
      body: userInfo.user == null
          ? _noUserView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    sBox(h: 2),
                    weightPicker(),
                    sBox(h: 3),
                    heightPicker(),
                    sBox(h: 6),
                    bmiIndicator()
                  ],
                ),
              ),
            ),
      floatingActionButton: userInfo.user == null
          ? Container()
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                if (bmi <= 0.0) {
                  Fluttertoast.showToast(
                      msg: 'Please adjust height to calculate BMI ',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white);
                } else {
                  // FluxNavigate.pushReplacementNamed(
                  //     RouteList.weightHome,
                  //     // arguments: [],
                  //   );
                  setState(() {
                    // weightData.bmi = calcBMI().toInt();
                    // UserPreferences().bmi = weightData.bmi;
                    // UserPreferences().height =
                    //     double.parse(_hvalue.toStringAsFixed(1));P

                    progressVm.postHeightWeight(
                        weight: num.parse(
                            (_scrollPosition / 10).toStringAsFixed(1)),
                        height: num.parse(_hvalue.toString()),
                        context: context);
                    Provider.of<ProgressTrackingVM>(context, listen: false)
                        .fetchWeightData()
                        .then(
                          (value) => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WeightHomePage(
                                fromBmiPage: true,
                              ),
                            ),
                          ),
                        );
                    // FluxNavigate.pushReplacementNamed(
                    //       RouteList.weightHome,
                    //       arguments: WeightHomePage(
                    //         fromBmiPage: true,
                    //       ),
                    // ));

                    // Provider.of<ProgressTrackingVM>(context, listen: false)
                    //     .fetchWeightData()

                    //     .then((val) {
                    //   Navigator.pushReplacement(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => WeightHomePage()));
                    // });
                  });
                }
              },
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Proceed',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
