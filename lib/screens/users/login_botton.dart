import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants.dart';
import '../../common/constants/user_prefrences.dart';
import '../../common/sizeConfig.dart';

class CustomOnBoardScreen extends StatefulWidget {
  const CustomOnBoardScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomOnBoardScreen> createState() => _CustomOnBoardScreenState();
}

class _CustomOnBoardScreenState extends State<CustomOnBoardScreen>
    with TickerProviderStateMixin {
  var isRequiredLogin;
  int page = 0;
  bool showLoginPage = false;
  final _gKey = GlobalKey<ScaffoldState>();
  Future<LottieComposition>? _composition;
  AnimationController? controller;
  AnimationController? slidecontroller;
  Animation<double>? _animation;
  bool isLoggedIn = false;
  Image? image1;
  Image? image2;
  Image? image3;

  List images = [];

  Future checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('loggedIn') ?? false;
  }

  @override
  void initState() {
    checkLogin();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    slidecontroller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween(begin: 0.0, end: 1.0).animate(controller!);

    _composition = _loadComposition();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<LottieComposition> _loadComposition() async {
    var assetData =
        await rootBundle.load('assets/images/lottie-high-five.json');
    return await LottieComposition.fromByteData(assetData);
  }

  Scaffold loginPage() {
    Timer(
      const Duration(seconds: 1),
      () => _gKey.currentState?.showBottomSheet((context) {
        return GestureDetector(
          onVerticalDragStart: (_) {},
          child: Container(
            height: SizeConfig.blockSizeVertical! * 35,
            width: double.infinity,
            // color: Colors.grey.shade200,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xffFEBF76).withOpacity(.88),
                    const Color(0xffFE8276).withOpacity(.94),
                    const Color(0xffFE8276)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(40)),
                color: Theme.of(context).primaryColor),
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: SizeConfig.blockSizeHorizontal! * 22,
                  height: SizeConfig.blockSizeVertical! * .5,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  'Get Onboard!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                if (isLoggedIn == false)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xffFE8276),
                        backgroundColor: Colors.white,
                        minimumSize: Size(SizeConfig.screenWidth! - 30,
                            SizeConfig.blockSizeVertical! * 6)),
                    onPressed: () async {
                      UserPreferences().seenAppOnboarding = true;
                      await Navigator.pushNamed(context, RouteList.login);
                    },
                    child: const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      backgroundColor: const Color(0xffFE8276),
                      foregroundColor: Colors.white,
                      minimumSize: Size(SizeConfig.screenWidth! - 30,
                          SizeConfig.blockSizeVertical! * 6)),
                  onPressed: () async {
                    UserPreferences().seenAppOnboarding = true;
                    await Navigator.pushReplacementNamed(
                        context, RouteList.dashboard);
                  },
                  child: Text(
                    isLoggedIn ? 'Continue' : 'Continue as Guest',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
    controller?.forward();

    return Scaffold(
      key: _gKey,
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FadeTransition(
                opacity: _animation!,
                child: SizedBox(
                  height: SizeConfig.blockSizeVertical! * 40,
                  width: SizeConfig.blockSizeVertical! * 50,
                  // color: Colors.red,
                  child: FutureBuilder<LottieComposition>(
                    future: _composition,
                    builder: (context, snapshot) {
                      var composition = snapshot.data;
                      if (composition != null) {
                        return Lottie(composition: composition);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'You\'re good to go!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0B4870),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Embark your journey to health and wellness',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff0B4870),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    slidecontroller?.forward();

    return loginPage();
  }
}
