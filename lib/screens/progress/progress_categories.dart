import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../models/index.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../pushNotification_handler.dart';
import '../skin_tracker/skin_tracker.dart';
import '../sleep_tracker/sleep_goal_page.dart';
import '../sleep_tracker/sleep_home_page.dart';
import '../sleep_tracker/sleep_tracker_provider.dart';
import '../water_tracker/water_goal_page.dart';
import '../water_tracker/water_home_page.dart';
import '../water_tracker/water_tracker_provider.dart';
import '../weight_tracker/weight_home_page.dart';
import '../weight_tracker/weight_init_page.dart';
import 'progress_screen.dart';
import 'wellness_overview_page.dart';

bool hair = false, weight = false, beard = false, skin = false;

class ProgressCategories extends StatefulWidget {
  final String? type;

  const ProgressCategories({Key? key, this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ProgressCategoriesState();
  }
}

class ProgressCategoriesState extends State<ProgressCategories> {
  var categories;
  late int progressPct;
  UserModel? userInfo;
  var progressVm;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      progressVm = Provider.of<ProgressTrackingVM>(context, listen: false);
      prefs = await SharedPreferences.getInstance();

      userInfo = Provider.of<UserModel>(Get.context!, listen: false);
      progressVm.categories =
          List.from(await progressVm.fetchCategories() ?? []);
      // progressVm.getProgress();
      progressPct = 0;
      progressVm.fetchWeightData();
      progressVm.setCategory(widget.type ?? '');
      progressVm.notifyListeners();
      // switch (widget.type) {
      //   case 'Hair':
      //     await Navigator.push(Get.context!,
      //         MaterialPageRoute(builder: (context) => ProgressScreen()));
      //     break;
      //   case 'Beard':
      //     await Navigator.push(Get.context!,
      //         MaterialPageRoute(builder: (context) => ProgressScreen()));
      //     break;
      //   case 'Weight Loss':
      //     progressVm?.getUser();
      //     progressVm?.fetchWeightData();
      //     if (userInfo?.user == null) {
      //       await Navigator.push(Get.context!,
      //           MaterialPageRoute(builder: (context) => NoUser()));
      //     } else {
      //       progressVm?.weightTracker!.startingWeight == 0
      //           ? await Navigator.push(
      //               Get.context!,
      //               MaterialPageRoute(
      //                   builder: (context) => const WeightInitPage()))
      //           : Navigator.push(
      //               Get.context!,
      //               MaterialPageRoute(
      //                   builder: (context) => const WeightHomePage()));
      //     }
      //     break;
      //   case 'Skin':
      //     await Navigator.push(Get.context!,
      //         MaterialPageRoute(builder: (context) => const Skin()));
      //     break;
      // }
      if (screenName == 'Hair') {
        progressVm = Provider.of<ProgressTrackingVM>(context, listen: false);
        progressVm.type = 'Hair';
        debugPrint('this is progress type: ${progressVm.type}');
        progressVm?.setCategory('Hair');
        await Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProgressScreen()));
        });
      } else if (screenName == 'Beard') {
        progressVm = Provider.of<ProgressTrackingVM>(context, listen: false);
        progressVm.type = 'Beard';
        debugPrint('this is progress type: ${progressVm.type}');
        progressVm?.setCategory('Beard');
        await Future.delayed(const Duration(seconds: 2)).then((value) {
          Navigator.push(Get.context!,
              MaterialPageRoute(builder: (context) => ProgressScreen()));
        });
      } else if (screenName == 'weight') {
        progressVm = Provider.of<ProgressTrackingVM>(context, listen: false);
        progressVm.type = 'WeightLoss';
        debugPrint('this is progress type: ${progressVm.type}');
        progressVm?.setCategory('WeightLoss');
        await Future.delayed(const Duration(seconds: 2)).then((value) {
          progressVm?.weightTracker!.startingWeight == 0
              ? Navigator.push(
                  Get.context!,
                  MaterialPageRoute(
                      builder: (context) => const WeightInitPage()))
              : Navigator.push(
                  Get.context!,
                  MaterialPageRoute(
                      builder: (context) => const WeightHomePage()));
        });
      } else if (screenName == 'skin') {
        progressVm = Provider.of<ProgressTrackingVM>(context, listen: false);
        progressVm.type = 'Skin';
        debugPrint('this is progress type: ${progressVm.type}');
        progressVm?.setCategory('Skin');
        await Future.delayed(const Duration(seconds: 3)).then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Skin()));
        });
      } else if (screenName == 'water') {
        await Future.delayed(const Duration(seconds: 2)).then((value) async {
          var waterVm =
              Provider.of<WaterTrackerProvider>(Get.context!, listen: false);
          await waterVm.getUserWaterData(userInfo?.user?.id ?? '');
          if (waterVm.waterTrackingModel == null ||
              waterVm.waterTrackingModel?.data?.monthsData?.isEmpty == true) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WaterInitPage(editGoal: false)));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const WaterHomePage()));
          }
        });
      } else if (screenName == 'sleep') {
        await Future.delayed(const Duration(seconds: 2)).then((value) async {
          var sleepVm =
              Provider.of<SleepTrackerProvider>(Get.context!, listen: false);
          await sleepVm.getSleepData(userID: userInfo?.user?.id ?? '');
          if (sleepVm.sleepTrackingModel?.data?.sleepGoal == null ||
              sleepVm.sleepTrackingModel?.data?.monthsData?.isEmpty == true) {
            unawaited(Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SleepGoalPage(editGoal: false))));
          } else {
            unawaited(Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SleepHomePage())));
          }
        });
      }
    });
  }

  dynamic getMessage({pct, type}) {
    if (pct == 0 && type == 'Hair') {
      return 'Watch your hair transform\nand grow!';
    }
    if (pct == 0 && type == 'Beard') {
      return 'Buckle down and watch\nyour Beard evolve!';
    }
    if (pct == 0 && type == 'Weight Loss') {
      return 'Embark on your\njourney to Fitness!';
    }
    if (pct == 0 && type == 'Skin') {
      return 'Monitor your skin. Dive into\nyour skincare journey';
    }
    if (pct >= 0 && pct <= 25) return 'Bravo! That’s the spirit';
    if (pct >= 25 && pct <= 50) {
      return 'Well done! You’re already\nmidway to your milestone!';
    }
    if (pct >= 50 && pct <= 75) return 'Woah! You\'re doing well.';
    if (pct >= 75 && pct <= 99) return 'Oncourse to hit your target!';
    if (pct == 100) return 'Congratulations! You’ve\nreached your goal.';
  }

  List<Widget> getCategoriesBox(ProgressTrackingVM pVm) {
    return List.generate(pVm.categories.length, (index) {
      if (pVm.categories[index]['name'] == 'Water' ||
          pVm.categories[index]['name'] == 'Sleep') {
        return Container(
          height: 20,
          color: Colors.black,
        );
      }
      var card = SizedBox(
        height: SizeConfig.blockSizeVertical! * 17,
        child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          elevation: 3,
          child: Row(
              mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16)),
                  child: CachedNetworkImage(
                    filterQuality: FilterQuality.low,
                    imageUrl: '${pVm.categories[index]['icon']}',
                    imageBuilder: (context, imageProvider) {
                      return Image(
                        height: SizeConfig.blockSizeVertical! * 18,
                        // width: 140,
                        image: imageProvider,
                        fit: BoxFit.fitHeight,
                      );
                    },
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal! * 4),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AutoSizeText(
                        getMessage(
                            pct: 0, type: pVm?.categories[index]['name']),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary),
                        maxLines: 3,
                      ),
                      sBox(h: 1),
                      if (pVm?.categories[index]['name'] == 'Hair')
                        AutoSizeText(
                          pVm?.hairp == true
                              ? 'Start Tracking!'
                              : 'Keep Tracking!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          maxLines: 3,
                        ),
                      if (pVm?.categories[index]['name'] == 'Beard')
                        AutoSizeText(
                          pVm?.beardp == true
                              ? 'Start Tracking!'
                              : 'Keep Tracking!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          maxLines: 3,
                        ),
                      if (pVm?.categories[index]['name'] == 'Weight Loss')
                        AutoSizeText(
                          pVm?.weightp == true
                              ? 'Start Tracking!'
                              : 'Keep Tracking!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          maxLines: 3,
                        ),
                      if (pVm?.categories[index]['name'] == 'Skin')
                        AutoSizeText(
                          pVm?.skinp == true
                              ? 'Start Tracking!'
                              : 'Keep Tracking!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          maxLines: 3,
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeVertical! * .2,
                            left: SizeConfig.blockSizeHorizontal! * 32),
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          color: Theme.of(context).primaryColor,
                          size: SizeConfig.blockSizeVertical! * 6,
                        ),
                      )
                    ],
                  ),
                ),
              ]),
        ),
      );
      return GestureDetector(
        onTap: () async {
          pVm.setCategory(pVm.categories[index]['name']);
          unawaited(pVm.fetchWeightData());

          if (pVm.type == 'Weight Loss') {
            pVm.getUser();
            unawaited(pVm.fetchWeightData());
            if (userInfo?.user == null) {
              unawaited(Get.to(NoUser()));
            } else {
              pVm.weightTracker == null ||
                      pVm.weightTracker?.startingWeight == 0
                  ? await Get.to(const WeightInitPage())
                  : await Get.to(const WeightHomePage());
            }
          } else if (pVm.type == 'Skin') {
            await Get.to(const Skin());
          } else {
            await Get.to(ProgressScreen());
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: card,
        ),
      );
    });
    //
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: SizeConfig.safeBlockVertical! * 38,
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
                      Consumer<UserModel>(
                        builder: (context, value, child) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20, left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.user != null
                                      ? 'Hi ${value.user!.name}'
                                      : 'Login!',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                sBox(h: 1.8),
                                Text(
                                  value.user != null
                                      ? 'Let\'s get Started'
                                      : 'To get Started',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: SizeConfig.blockSizeVertical! * 12,
                  // right: 0,
                  // left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onTap: () {
                        progressVm?.fetchCategories();
                        userInfo?.user != null
                            ? Navigator.push(
                                Get.context!,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WellnessOverviewPage()))
                            : Navigator.push(
                                Get.context!,
                                MaterialPageRoute(
                                    builder: (context) => NoUser(
                                          isWellness: true,
                                        )));
                      },
                      child: SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        child: Image.asset('assets/images/wellnessCard.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // categories header and list
          Expanded(
            child: Consumer<ProgressTrackingVM>(builder: (context, pVm, _) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xffFFFFFF),
                ),
                padding:
                    const EdgeInsets.only(right: 20.0, left: 20.0, top: 20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categories',
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            ?.copyWith(color: Theme.of(context).primaryColor)
                            .apply(fontSizeFactor: 1.4)),
                    const SizedBox(height: 10),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: getCategoriesBox(pVm),
                    )
                  ],
                ),
              );
            }),
          ),
        ]));
  }
}

class NoUser extends StatefulWidget {
  bool isWellness;
  NoUser({Key? key, this.isWellness = false}) : super(key: key);

  @override
  State<NoUser> createState() => _NoUserState();
}

class _NoUserState extends State<NoUser> {
  ProgressTrackingVM? progress =
      Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      progress?.getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    var headerText = '';
    if (widget.isWellness) {
      headerText = 'Wellness Overview';
      progress?.notifyListeners();
    } else if (progress?.type != null &&
        ((progress?.type == 'Skin') ||
            (progress?.type == 'Hair') ||
            (progress?.type == 'Beard'))) {
      headerText = '${progress?.type} Tracker';
      progress?.type = null;
    } else if (progress?.type == 'Weight Loss') {
      headerText = 'Wellness Tracker';
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title:
              Consumer<ProgressTrackingVM>(builder: (context, progress, child) {
            return Text(
              headerText,
              style: const TextStyle(
                color: Colors.black,
              ),
            );
          }),
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
        body: Center(
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
                        Get.context!,
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
        ));
  }
}
