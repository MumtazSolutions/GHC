import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as c;
import 'package:flutter/src/painting/text_style.dart' as ts;
import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/constants/user_prefrences.dart';
import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../routes/flux_navigate.dart';
import '../../screens/progress/progress_gallery.dart';
import '../../screens/progress/progress_screen.dart';
import '../../screens/skin_tracker/skin_health_page.dart';
import '../../screens/skin_tracker/skin_home_page.dart';
import '../../screens/weight_tracker/weight_tranformation_page.dart';

DateTime? dateofpic;
bool canGoBack = true;

class ProgressCalendar extends StatefulWidget {
  ProgressDialog? progressDialog;
  final ScrollController? controller;
  final ScrollController? vScontroller;

  ProgressCalendar(
      {Key? key, this.progressDialog, this.controller, this.vScontroller})
      : super(key: key);

  @override
  _ProgressCalendarState createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  int _selectedMonthIndex = 0;
  int _selectedWeekIndex = 0;
  bool isSwitched = false;
  int? initMonth;
  File? tmpFileF;
  File? tmpFileT;
  var frontPic;
  var topPic;
  int? weight;
  bool complete = false;
  int weeksMissed = 0;
  var progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  ScrollController? controller;

  List monthList = [];
  List yearList = [];
  String? dropdownValue;
  List weekList = [];

  bool isShowing = true;
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey uploadBoxes = GlobalKey();
  GlobalKey progressGalleryButton = GlobalKey();
  GlobalKey detailscard = GlobalKey();
  SharedPreferences? _prefs;

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

// calculates week number of date
  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  List getWeeks() {
    List w = [];
    List.generate(numOfWeeks(DateTime.now().year), (index) {
      w.add('Week ${index + 1}');
    });
    return w;
  }

  List getYears() {
    var y = [];
    var d = DateTime.now().difference(DateTime(DateTime.now().year - 5, 1, 1)).inDays;
    List.generate(6, (index) {
      var a = (DateTime.now().year - 5 + index).toString();
      y.add(a);
    });
    return y;
  }

  List getMonths() {
    List m = [];
    List.generate(12, (index) {
      // m.add(DateFormat.MMM('01-${index + 1}-2020').toString());
      var n = index >= 9 ? '' : '0';
      var month = DateFormat.MMM()
          // .format(DateTime(progress.tracker.startDate.month + index))
          .format(DateTime.parse('2020-$n${index + 1}-01'))
          .toString();
      m.add(month);
    });
    return m;
  }

  // _onSelected(int index) {
  //   setState(() => _selectedMonthIndex = index);
  // }

  Future<File?> compressImage(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,
    );

    return result;
  }

  XFile? image;
  Future getImage(ProgressTrackingVM? progress, {front}) async {
    final picker = ImagePicker();
    var isCamera = true;
    if (isCamera) {
      image = await picker.pickImage(source: ImageSource.camera);
      var file = File(image!.path);
      var compressedImage =
          await compressImage(file, '${image!.path}_compressed.jpg');
      setState(() {
        if (compressedImage != null) {
          front
              ? tmpFileF = File(compressedImage.path)
              : tmpFileT = File(compressedImage.path);
        } else {
          front ? tmpFileF = null : tmpFileT = null;
        }
      });
      if (front ? tmpFileF != null : tmpFileT != null) {
        canGoBack = false;
        await progress?.addProgress(
            file: front ? tmpFileF : tmpFileT,
            response: (result) async {
              front ? frontPic = result : topPic = result;
              if (progress.type == 'Skin') {
                if (frontPic != null || topPic != null) {
                  unawaited(progress
                      .uploadUserPics(topImg: topPic, frontImg: frontPic)
                      .then((value) {
                    if (value) {
                      canGoBack = true;
                    }
                  }));
                  // ScaffoldMessenger.maybeOf(context)
                  //     .showSnackBar(SnackBar(content: Text('Images Uploaded')));

                  await progress
                      .fetchImages()
                      .then((value) => log('FETCH IMAGE 1'));
                  unawaited(Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SkinHomePage())));
                  canGoBack = true;
                }
              } else {
                if (frontPic != null && topPic != null) {
                  canGoBack = false;
                  unawaited(progress
                      .uploadUserPics(topImg: topPic, frontImg: frontPic)
                      .then((value) {
                    if (value) {
                      canGoBack = true;
                    }
                  }));
                  // ScaffoldMessenger.maybeOf(context)
                  //     .showSnackBar(SnackBar(content: Text('Images Uploaded')));

                  await progress
                      .fetchImages()
                      .then((value) => log('FETCH IMAGE 2'));
                  Timer(const Duration(seconds: 5), () {});
                  unawaited(progress.type != 'Weight Loss'
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProgressScreen()))
                      : Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const WeightTransormatioPage())));
                }
              }
            });
      }
    }
    // progress.getProgress();
  }

  Future getGalleryImage(ProgressTrackingVM? progress, {front}) async {
    final picker = ImagePicker();
    var isCamera = true;
    if (isCamera) {
      image = await picker.pickImage(source: ImageSource.camera);
      var file = File(image!.path);
      var compressedImage =
          await compressImage(file, '${image!.path}_compressed.jpg');
      setState(() {
        if (compressedImage != null) {
          front
              ? tmpFileF = File(compressedImage.path)
              : tmpFileT = File(compressedImage.path);
        } else {
          front ? tmpFileF = null : tmpFileT = null;
        }
      });

      if (front ? tmpFileF != null : tmpFileT != null) {
        canGoBack = false;
        await progress?.addProgress(
            file: front ? tmpFileF : tmpFileT,
            response: (result) async {
              front ? frontPic = result : topPic = result;
              if (progress.type == 'Skin') {
                if (frontPic != null || topPic != null) {
                  unawaited(progress
                      .uploadUserPics(topImg: topPic, frontImg: frontPic)
                      .then((value) {
                    if (value) {
                      canGoBack = true;
                    }
                  }));
                  // ScaffoldMessenger.maybeOf(context)
                  //     .showSnackBar(SnackBar(content: Text('Images Uploaded')));
                  await progress
                      .fetchImages()
                      .then((value) => log('FETCH IMAGE 3'));
                  unawaited(Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SkinHomePage())));
                }
              } else {
                if (frontPic != null && topPic != null) {
                  canGoBack = false;
                  unawaited(progress
                      .uploadUserPics(topImg: topPic, frontImg: frontPic)
                      .then((value) {
                    if (value) {
                      canGoBack = true;
                    }
                  }));
                  // ScaffoldMessenger.maybeOf(context)
                  //     .showSnackBar(SnackBar(content: Text('Images Uploaded')));

                  await progress
                      .fetchImages()
                      .then((value) => log('FETCH IMAGE 4'));
                  Timer(const Duration(seconds: 5), () {});
                  unawaited(progress.type != 'Weight Loss'
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProgressScreen()))
                      : Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const WeightTransormatioPage())));
                }
              }
            });
      }
    }
    // progress.getProgress();
  }

  BuildContext? dialogContext;
  void showAlertDialog(BuildContext context, progress, {front = false}) {
    // set up the buttons

    // set up the AlertDialog
    // ignore: omit_local_variable_types
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      titlePadding: const EdgeInsets.fromLTRB(15, 0, 2, 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Upload Photo',
            style: ts.TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(dialogContext!).pop();
              })
        ],
      ),
      content: SizedBox(
        height: 100,
        // width: 300,
        child: Column(
          children: [
            TextButton(
              child: Text(
                'Open Camera',
                style: ts.TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                getImage(progress, front: front);
                Navigator.of(dialogContext!).pop();
              },
            ),
            TextButton(
              child: Text(
                'Upload from Gallery',
                style: ts.TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                getGalleryImage(progress, front: front);
                Navigator.of(dialogContext!).pop();
              },
            ),
            // ElevatedButton(
            //   style: TextButton.styleFrom(
            //     elevation: 3,
            //     backgroundColor: Theme.of(context).primaryColor,
            //     minimumSize: const Size(128, 27),
            //     shape: const RoundedRectangleBorder(
            //       borderRadius: BorderRadius.all(Radius.circular(30)),
            //     ),
            //   ),
            //   child: const Text(
            //     'Save',
            //     style: ts.TextStyle(
            //         color: Colors.white, fontWeight: FontWeight.bold),
            //   ),
            //   onPressed: () {
            //     Navigator.of(dialogContext).pop();
            //   },
            // )
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  int showMonth = 0;
  bool show = true;
  matchMonth() {
    print(_selectedMonthIndex + 1);
    print(_selectedWeekIndex);
    for (int i = 0; i < progress.tracker!.months!.length; i++) {
      if (_selectedMonthIndex + 1 ==
              int.parse(progress.tracker!.months![i].monthNumber!) &&
          dropdownValue == progress.tracker!.months![i].year.toString() &&
          progress.tracker!.months![i].weeks?[_selectedWeekIndex].frontImage !=
              '') {
        setState(() {
          showMonth = i;
          show = true;
        });
        return true;
      } else if (_selectedMonthIndex + 1 ==
              int.parse(progress.tracker!.months![i].monthNumber!) &&
          dropdownValue == progress.tracker!.months![i].year.toString() &&
          DateTime.now().year == int.parse(dropdownValue.toString()) &&
          progress.tracker!.months![i].weeks?[_selectedWeekIndex].currentWeek ==
              true) {
        setState(() {
          showMonth = i;
          show = true;
        });
        return true;
      }
    }

    setState(() {
      show = false;
    });
    return false;
  }

  void getPresentWeek() {
    var weeks = progress.tracker!.months![showMonth].weeks;
    for (int i = 0; i < weeks!.length; i++) {
      if (weeks[i].currentWeek == true) {
        setState(() {
          _selectedWeekIndex = i;
        });
      }
    }
  }

  dynamic getBannerImg({front, type}) {
    if (type == 'Hair') {
      return front
          ? 'assets/images/uploadFrontHair.png'
          : 'assets/images/uploadTopHair.png';
    } else if (type == 'Beard') {
      return front
          ? 'assets/images/uploadBeardRight.png'
          : 'assets/images/uploadBeardLeft.png';
    } else if (type == 'Skin') {
      return 'assets/images/skinUpload.png';
    } else {
      return front
          ? 'assets/images/uploadWeightFront.png'
          : 'assets/images/uploadWeightSide.png';
    }
  }

  bool isThisMonth() {
    if (dropdownValue == DateTime.now().year.toString() &&
        num.parse(progress!.tracker!.months!.last.monthNumber!) - 1 ==
            _selectedMonthIndex) {
      return true;
    } else {
      return false;
    }
  }

  dynamic isThisWeek() {
    int week = 0;
    for (int i = 0;
        i < int.parse(progress?.tracker?.months?.length.toString() ?? '0');
        i++) {
      for (var j = 0;
          j <
              int.parse(
                  progress?.tracker?.months?[i].weeks?.length.toString() ??
                      '0');
          j++) {
        if (progress?.tracker?.months?[i].weeks?[j].currentWeek == true) {
          return j as bool;
        }
      }
    }
  }

  int weekOfMonth(mydate) {
    String date = DateTime.now().toString();

// This will generate the time and date for first day of month
    String firstDay = '${date.substring(0, 8)}01${date.substring(10)}';

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

  getLastUpload() {
    for (int i = 0; i < progress!.tracker!.months!.length; i++) {
      for (var j = progress!.tracker!.months![i].weeks!.length - 1;
          j < progress!.tracker!.months![i].weeks!.length;
          j--) {
        if (progress!.tracker!.months![i].weeks![j].date.toString() != '') {
          return DateFormat.yMMMd()
              .format(progress!.tracker!.months![i].weeks![j].date!)
              .toString();
        }
      }
    }
  }

  Widget detailsCard(ProgressTrackingVM progress, context) {
    return Container(
      key: detailscard,
      child: GestureDetector(
        onTap: () {
          if (progress.skinData!.images!.months![showMonth]
                      .weeks![_selectedWeekIndex].conditions![0].score !=
                  0 &&
              show) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SkinHealthPage(
                    image: progress.skinData!.images!.months![showMonth]
                        .weeks![_selectedWeekIndex].frontImage,
                    weekScore: progress.skinData!.images!.months![showMonth]
                        .weeks![_selectedWeekIndex].weekOverallScore,
                    monthIndex: [showMonth, _selectedWeekIndex]),
              ),
            );
          }
        },
        child: Stack(
          children: [
            Padding(
              // key: key,
              padding: const EdgeInsets.all(20),
              child: Container(
                // key: key,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'My Skin Health',
                            style: ts.TextStyle(fontWeight: FontWeight.bold),
                          ),
                          sBox(w: 48),
                          Icon(
                            Icons.track_changes,
                            color: Theme.of(context).primaryColor,
                          ),
                          const Icon(Icons.chevron_right_sharp)
                        ],
                      ),
                      const Divider(
                        endIndent: 10,
                        indent: 2,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Last Update Skin Score',
                              style: ts.TextStyle(color: Colors.black38),
                            ),
                            Text(
                              DateFormat.yMMMd()
                                  .format(
                                      progress.skinData?.images?.lastUpload ??
                                          DateTime.now())
                                  .toString(),

                              // '2 Nov 2021',
                              style: const ts.TextStyle(color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                      sBox(h: 2),
                      // progress.skinData.images.months[showMonth]
                      //             .weeks[_selectedWeekIndex].reviewStatus !=
                      //         'Completed'
                      //     ?
                      show == false
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (index) => circularMarker(
                                    value: 75, text: 'Acne', context: context),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                  progress
                                          .skinData
                                          ?.images
                                          ?.months?[showMonth]
                                          .weeks?[_selectedWeekIndex]
                                          .conditions
                                          ?.length ??
                                      0, (index) {
                                return circularMarker(
                                    value: progress
                                        .skinData
                                        ?.images
                                        ?.months?[showMonth]
                                        .weeks?[_selectedWeekIndex]
                                        .conditions?[index]
                                        .score,
                                    text: progress
                                        .skinData
                                        ?.images
                                        ?.months?[showMonth]
                                        .weeks?[_selectedWeekIndex]
                                        .conditions?[index]
                                        .shortName,
                                    context: context);
                              }),
                            ),
                    ],
                  ),
                ),
              ),
            ),

            // condition for a user who already has a pic reviewed
            if (show == false)
              Positioned(
                top: SizeConfig.blockSizeVertical! * 2.4,
                right: SizeConfig.blockSizeVertical! * 2.4,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: SizeConfig.blockSizeVertical! * 27,
                      width: SizeConfig.blockSizeHorizontal! * 90.45,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          color: Colors.black.withOpacity(.5)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Text(
                            ((_selectedMonthIndex + 1 > DateTime.now().month) &&
                                    (DateTime.now().year > DateTime.now().year - 1) &&
                                    int.parse(dropdownValue!) >= DateTime.now().year)
                                ? 'Skin score will be updated once you upload a picture'
                                : 'Your Journey started from week ${weekOfMonth(progress.skinData?.images?.startDate)} of ${DateFormat.yMMMM().format(progress.skinData?.images?.startDate ?? DateTime.now()).toString()}',
                            textAlign: TextAlign.center,
                            style: const ts.TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // condition for a user who uploaded a pic
            if (progress.skinData!.images!.months![showMonth]
                        .weeks![_selectedWeekIndex].reviewStatus ==
                    'Pending' &&
                isThisMonth())
              Positioned(
                top: SizeConfig.blockSizeVertical! * 2.4,
                right: SizeConfig.blockSizeVertical! * 2.4,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: SizeConfig.blockSizeVertical! * 27,
                      width: SizeConfig.blockSizeHorizontal! * 90.45,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          color: Colors.black.withOpacity(.5)),
                      child: const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 45),
                        child: Text(
                          'Your picture is under review',
                          textAlign: TextAlign.center,
                          style: ts.TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            // condition for a new user And also if week has no upload for a existing user
            if (progress.skinData!.images!.months![showMonth]
                        .weeks![_selectedWeekIndex].reviewStatus ==
                    'NewUser' &&
                show == true)
              Positioned(
                top: SizeConfig.blockSizeVertical! * 2.4,
                right: SizeConfig.blockSizeVertical! * 2.4,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: SizeConfig.blockSizeVertical! * 27,
                      width: SizeConfig.blockSizeHorizontal! * 90.45,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          color: Colors.black.withOpacity(.5)),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: Text(
                          show
                              ? _selectedWeekIndex + 1 <
                                          weekOfMonth(progress
                                              .skinData!.images!.startDate) &&
                                      DateTime(int.parse(dropdownValue ?? ''),
                                                  _selectedMonthIndex + 1)
                                              .isBefore(progress.skinData!
                                                  .images!.startDate!) ==
                                          true
                                  ? 'Your Journey started from week ${weekOfMonth(progress.skinData?.images?.startDate)} of ${DateFormat.yMMMM().format(progress.skinData?.images?.startDate ?? DateTime.now()).toString()}'
                                  : (_selectedMonthIndex + 1 !=
                                              DateTime.now().month ||
                                          _selectedWeekIndex < isThisWeek())
                                      ? 'Oops! Looks like you missed uploading a picture for this week'
                                      : 'Skin score will be updated once you upload a picture'
                              : _selectedMonthIndex + 1 >
                                      progress
                                          .skinData!.images!.startDate!.month
                                  ? 'Skin score will be updated once you upload a picture'
                                  : 'Your Journey started from week ${weekOfMonth(progress.skinData?.images?.startDate) + 1} of ${DateFormat.yMMMM().format(progress.skinData?.images?.startDate ?? DateTime.now()).toString()}',
                          textAlign: TextAlign.center,
                          style: const ts.TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void initTargets() {
    targets.clear();
    if (progress.type == 'Skin') {
      targets.add(
        targetFocus(
            controller: tutorialCoachMark,
            targets: targets,
            identifier: 'uploadBoxes',
            key: uploadBoxes,
            text: 'Upload your picture every week to get your skin score'),
      );
      targets.add(
        targetFocus(
            controller: tutorialCoachMark,
            targets: targets,
            identifier: 'detailscard',
            key: detailscard,
            text: 'Track your skin score based on your concern'),
      );
      targets.add(
        targetFocus(
            controller: tutorialCoachMark,
            targets: targets,
            identifier: 'progressGalleryButton',
            key: progressGalleryButton,
            text: 'Monitor your Progress and see visible results'),
      );
    } else {
      targets.add(
        targetFocus(
            controller: tutorialCoachMark,
            targets: targets,
            identifier: 'uploadBoxes',
            key: uploadBoxes,
            text: 'Upload your picture every week'),
      );
      targets.add(
        targetFocus(
            controller: tutorialCoachMark,
            targets: targets,
            identifier: 'progressGalleryButton',
            key: progressGalleryButton,
            text: 'Monitor and compare your progress for visible results'),
      );
    }
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
        if (progress.isloading == false &&
            getSeen() == false &&
            complete == true &&
            isShowing) {
          isShowing = false;
          if (progress.isloading == false) {
            showTutorial();
          }
          print('showing tutorial${progress.type}');
          if (progress.type == 'Skin') {
            _prefs?.setBool('seenSkin', true);
            log('seen skin${UserPreferences().seenSkin}');
          } else if (progress.type == 'Hair') {
            _prefs?.setBool('seenHair', true);
          } else if (progress.type == 'Beard') {
            _prefs?.setBool('seenBeard', true);
          }

          index = 0;
        }
      },
      onClickTarget: (t) {},
      // print('onClickTarget: $target');

      onClickOverlay: (t) {},
      onSkip: () {
        tutorialCoachMark?.finish();
        if (progress.isloading == false &&
            getSeen() == false &&
            complete == true &&
            isShowing) {
          isShowing = false;
          if (progress.isloading == false) {
            showTutorial();
          }
          print('showing tutorial${progress.type}');
          if (progress.type == 'Skin') {
            _prefs?.setBool('seenSkin', true);
            log('seen skin${UserPreferences().seenSkin}');
          } else if (progress.type == 'Hair') {
            _prefs?.setBool('seenHair', true);
          } else if (progress.type == 'Beard') {
            _prefs?.setBool('seenBeard', true);
          }

          index = 0;
        }
      },
    )..show(context: context);
  }

  @override
  void initState() {
    controller = ScrollController();
    monthList = getMonths();
    yearList = getYears();
    weekList = getWeeks();
    dropdownValue = yearList[5];
    _selectedMonthIndex = int.parse(
            progress.tracker?.months?.last.monthNumber.toString() ?? '0') -
        1;
    showMonth = progress.tracker!.months!.length - 1;
    getPresentWeek();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _prefs = await SharedPreferences.getInstance();
      if (_selectedMonthIndex >= 6) widget.controller!.jumpTo(320);
      if (_selectedWeekIndex > 2) controller!.jumpTo(120);
      if (progress.type == 'Skin') {
        setState(() {
          widget.vScontroller!
              .animateTo(widget.vScontroller!.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.ease)
              .then((value) {
            Timer(const Duration(milliseconds: 500), () {
              setState(() {
                complete = true;
              });
            });
          });
        });
      }
      if (progress.type == 'Hair' || progress.type == 'Beard') {
        setState(() {
          widget.vScontroller!
              .animateTo(widget.vScontroller!.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.ease)
              .then((value) {
            Timer(const Duration(milliseconds: 500), () {
              setState(() {
                complete = true;
              });
            });
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tutorialCoachMark?.skip();
    super.dispose();
  }

  bool getSeen() {
    if (progress.type == 'Skin') {
      return _prefs?.getBool('seenSkin') ?? false;
    }
    return progress.type == 'Hair'
        ? _prefs?.getBool('seenHair') ?? false
        : _prefs?.getBool('seenBeard') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (progress.isloading == false &&
        getSeen() == false &&
        complete == true &&
        isShowing) {
      isShowing = false;
      if (progress.isloading == false) {
        showTutorial();
      }
      print('showing tutorial${progress.type}');
      if (progress.type == 'Skin') {
        _prefs?.setBool('seenSkin', true);
        log('seen skin${UserPreferences().seenSkin}');
      } else if (progress.type == 'Hair') {
        _prefs?.setBool('seenHair', true);
      } else if (progress.type == 'Beard') {
        _prefs?.setBool('seenBeard', true);
      }

      index = 0;
    }
    // progressDialog = ProgressDialog(context,

    return Consumer<ProgressTrackingVM>(builder: (context, pVm, _) {
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
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: SizeConfig.safeBlockHorizontal! * 80),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    icon: Container(
                        color: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 18,
                        )),
                    elevation: 0,
                    value: dropdownValue,
                    onChanged: (val) {
                      setState(
                        () {
                          dropdownValue = int.parse(val.toString()).toString();
                          if (dropdownValue == DateTime.now().year.toString()) {
                            _selectedMonthIndex = int.parse(
                                    pVm.tracker?.months?.last.monthNumber ??
                                        '0') -
                                1;
                            showMonth = int.parse(
                                    pVm.tracker?.months?.length.toString() ??
                                        '0') -
                                1;
                            getPresentWeek();
                            if (_selectedMonthIndex >= 6) {
                              widget.controller!.jumpTo(320);
                            }
                            if (_selectedWeekIndex > 2) controller!.jumpTo(120);
                          }
                          if (dropdownValue != DateTime.now().year.toString()) {
                            _selectedMonthIndex = 0;
                            _selectedWeekIndex = 0;
                            matchMonth();
                            widget.controller!.jumpTo(10);
                          }
                          matchMonth();
                        },
                      );
                    },
                    items: List.generate(yearList.length, (index) {
                      return DropdownMenuItem(
                          value: yearList[index].toString(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(yearList[index].toString()),
                          ));
                    }),
                  ),
                ),
              ),
              sBox(h: 1),
              Row(children: [
                const Icon(Icons.chevron_left),
                SizedBox(
                  height: SizeConfig.safeBlockVertical! * 4,
                  width: SizeConfig.screenWidth! - 50,
                  child: ListView.builder(
                      controller: widget.controller,
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMonthIndex = index;
                                // appData.month = _selectedMonthIndex;
                                matchMonth();
                                _selectedWeekIndex = 0;
                                // appData.week = _selectedWeekIndex;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: _selectedMonthIndex != null &&
                                            _selectedMonthIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3))),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: Text(
                                      monthList[index],
                                      style: ts.TextStyle(
                                        fontSize: 16,
                                        color: _selectedMonthIndex != null &&
                                                _selectedMonthIndex == index
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        );
                      }),
                ),
                const Icon(Icons.chevron_right)
              ]),
              sBox(h: 5),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 4,
                child: ListView(
                  controller: controller,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    pVm.tracker?.months?[showMonth] != null
                        ? 5
                        : getTotalNumberOfWeeksInMonth(
                            int.parse(dropdownValue.toString()),
                            7), // week length
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWeekIndex = index;
                          // appData.week = _selectedWeekIndex;
                          matchMonth();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.safeBlockVertical! * 1.8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1.0,
                                  color: _selectedWeekIndex != null &&
                                          _selectedWeekIndex == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              pVm.type == 'Beard' ||
                                      pVm.type == 'Hair' ||
                                      pVm.type == 'Weight Loss'
                                  ? 'Week ${pVm.tracker!.months![showMonth].weeks![index].weekNum!}'
                                  : pVm
                                      .tracker!
                                      .months![showMonth]
                                      .weeks![index]
                                      .weekNum!, // add empty weeks

                              style: ts.TextStyle(
                                  fontSize: 20,
                                  color: _selectedWeekIndex != null &&
                                          _selectedWeekIndex == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              sBox(h: 4),
              Container(
                key: uploadBoxes,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // front hair
                    show == false && isThisMonth() == false
                        ? GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg: 'This is not the current week',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[600],
                                  textColor: Colors.white);
                            },
                            child: Card(
                              elevation: 5,
                              child: SizedBox(
                                width: 161,
                                height: 126,
                                child: Image.asset(
                                    getBannerImg(type: pVm.type, front: true)),
                              ),
                            ),
                          )
                        : pVm.tracker?.months?[showMonth]
                                    .weeks?[_selectedWeekIndex].frontImage !=
                                ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  filterQuality: FilterQuality.low,
                                  imageUrl: pVm
                                          .tracker
                                          ?.months?[showMonth]
                                          .weeks?[_selectedWeekIndex]
                                          .frontImage ??
                                      '',
                                  imageBuilder: (context, imageProvider) {
                                    return Image(
                                      height: 126,
                                      width: 161,
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                                  ),
                                  // placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              )
                            : pVm
                                            .tracker!
                                            .months![showMonth]
                                            .weeks![_selectedWeekIndex]
                                            .currentWeek ==
                                        true &&
                                    isThisMonth()
                                ? tmpFileF == null
                                    ? GestureDetector(
                                        onTap: () {
                                          if (pVm.isValidDate)
                                          // getImage(pVm);
                                          {
                                            showAlertDialog(context, pVm,
                                                front: true);
                                          } else {
                                            FluxNavigate.pushNamed(
                                              RouteList.inValidDateScreen,
                                              arguments: [],
                                            );
                                          }
                                        },
                                        child: Card(
                                          elevation: 5,
                                          child: SizedBox(
                                            width: 161,
                                            height: 126,
                                            child: Image.asset(
                                              getBannerImg(
                                                  type: pVm.type, front: true),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Card(
                                        elevation: 5,
                                        child: SizedBox(
                                          width: 161,
                                          height: 126,
                                          child: Image.file(
                                            File(tmpFileF!.path),
                                          ), //frontImageToShow
                                        ),
                                      )
                                : GestureDetector(
                                    onTap: () {
                                      Fluttertoast.showToast(
                                          msg: 'This is not the current week',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey[600],
                                          textColor: Colors.white);
                                    },
                                    child: Card(
                                      elevation: 5,
                                      child: SizedBox(
                                        width: 161,
                                        height: 126,
                                        child: Image.asset(getBannerImg(
                                            type: pVm.type, front: true)),
                                      ),
                                    ),
                                  ),
                    const SizedBox(width: 12),
                    // top hair
                    if (pVm.type != 'Skin')
                      show == false && isThisMonth() == false
                          ? GestureDetector(
                              onTap: () {
                                Fluttertoast.showToast(
                                    msg: 'This is not the current week',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[600],
                                    textColor: Colors.white);
                              },
                              child: Card(
                                elevation: 5,
                                child: SizedBox(
                                  width: 161,
                                  height: 126,
                                  child: Image.asset(getBannerImg(
                                      type: pVm!.type, front: false)),
                                ),
                              ),
                            )
                          : pVm.tracker!.months![showMonth]
                                      .weeks![_selectedWeekIndex].frontImage !=
                                  ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    filterQuality: FilterQuality.low,
                                    imageUrl: pVm.tracker!.months![showMonth]
                                        .weeks![_selectedWeekIndex].topImage!,
                                    imageBuilder: (context, imageProvider) {
                                      return Image(
                                        height: 126,
                                        width: 161,
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                      ),
                                    ),
                                    // placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                )
                              : pVm
                                              .tracker
                                              ?.months![showMonth]
                                              .weeks![_selectedWeekIndex]
                                              .currentWeek ==
                                          true &&
                                      isThisMonth()
                                  ? tmpFileT == null
                                      ? GestureDetector(
                                          onTap: () {
                                            if (pVm!.isValidDate)
                                            // getImage(pVm);
                                            {
                                              showAlertDialog(context, pVm,
                                                  front: false);
                                            } else {
                                              FluxNavigate.pushNamed(
                                                RouteList.inValidDateScreen,
                                                arguments: [],
                                              );
                                            }
                                          },
                                          child: Card(
                                            elevation: 5,
                                            child: SizedBox(
                                              width: 161,
                                              height: 126,
                                              child: Image.asset(getBannerImg(
                                                  type: pVm!.type,
                                                  front: false)),
                                            ),
                                          ),
                                        )
                                      : Card(
                                          elevation: 5,
                                          child: SizedBox(
                                            width: 161,
                                            height: 126,
                                            child: Image.file(
                                              File(tmpFileT!.path),
                                            ), //frontImageToShow
                                          ),
                                        )
                                  : GestureDetector(
                                      onTap: () {
                                        Fluttertoast.showToast(
                                            msg: 'This is not the current week',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.grey[600],
                                            textColor: Colors.white);
                                      },
                                      child: Card(
                                        elevation: 5,
                                        child: SizedBox(
                                          width: 161,
                                          height: 126,
                                          child: Image.asset(getBannerImg(
                                              type: pVm!.type, front: false)),
                                        ),
                                      ),
                                    ),
                  ],
                ),
              ),
              sBox(h: 3),
              if (pVm.type == 'Skin') skinWidget(context, pVm),
              // if (pVm.type == 'Hair' || pVm.type == 'Beard') sBox(h: 2),
              if (pVm.type != 'Skin') cardWidget(),
            ],
          ));
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return ((to.difference(from).inHours / 24) / 7).round();
  }

  int weeksUploaded() {
    var weeks = 0;
    for (int i = 0; i < progress!.tracker!.months!.length; i++) {
      for (var j = 0; j < progress!.tracker!.months![i].weeks!.length; j++) {
        if (progress!.tracker!.months![i].weeks![j].frontImage != '') {
          weeks += 1;
        }
      }
    }
    return weeks;
  }

  Stack cardWidget() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          color: c.Color(0xffFFEDE3),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 4),
          child: Column(
            children: [
              sBox(h: 4),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal! * 4),
                  child: Column(
                    children: [
                      sBox(h: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${progress!.type!} Progress',
                            style: const ts.TextStyle(
                                color: c.Color(0xff0B4870),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Text('Uploaded:   ',
                              style: ts.TextStyle(color: Colors.grey)),
                          Text(
                            '${progress!.tracker!.presentWeek!}/${progress!.tracker!.totalWeeks!}  ',
                            style: const ts.TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey[700],
                      ),
                      if (show != false &&
                          (progress!.tracker!.months![showMonth]
                                      .weeks![_selectedWeekIndex].currentWeek ==
                                  true ||
                              progress!.tracker!.months![showMonth]
                                      .weeks![_selectedWeekIndex].frontImage !=
                                  ''))
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const c.Color(0xffFFEDE3),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                sBox(w: 3),
                                progress!
                                            .tracker!
                                            .months![showMonth]
                                            .weeks![_selectedWeekIndex]
                                            .frontImage ==
                                        ''
                                    ? Text(
                                        'Please upload your picture for this week',
                                        style: ts.TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 13),
                                      )
                                    : const Text(
                                        'Your picture was uploaded succesfully',
                                        style: ts.TextStyle(
                                            color: Colors.green, fontSize: 14),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      sBox(h: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your journey started from',
                              style: ts.TextStyle(
                                  fontSize: 15, color: Colors.black)),
                          // format date and display
                          Text(
                              DateFormat.yMMMd()
                                  .format(progress!.tracker!.startDate!)
                                  .toString(),
                              style: const ts.TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      sBox(h: 1.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${weeksUploaded()} weeks uploaded',
                              style: const ts.TextStyle(
                                  fontSize: 15, color: Colors.black)),
                          Text(
                              '${daysBetween(progress!.tracker!.startDate!, DateTime.now())} weeks missed',
                              style: const ts.TextStyle(
                                  fontSize: 15, color: Colors.black)),
                        ],
                      ),
                      sBox(h: 2),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Overall Progress',
                          style: ts.TextStyle(
                              color: c.Color(0xff0B4870),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      sBox(h: 1.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal! * 72,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                              child: LinearProgressIndicator(
                                minHeight: SizeConfig.safeBlockVertical! * .6,
                                value: ((weeksUploaded() / 52)),
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<c.Color>(
                                    Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          Text(
                            '${((weeksUploaded() / 52) * 100).toStringAsFixed(1)}%',
                            style: ts.TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                      sBox(h: 1.5)
                    ],
                  ),
                ),
              ),
              sBox(h: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ElevatedButton(
                  key: progressGalleryButton,
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: Size(SizeConfig.blockSizeHorizontal! * 90,
                        SizeConfig.blockSizeVertical! * 6),
                    // padding: EdgeInsets.symmetric(horizontal: 16.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Progress Gallery',
                          style: ts.TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        // Spacer(),
                        sBox(w: 8),
                        Icon(Icons.arrow_right_sharp,
                            color: Colors.white,
                            size: SizeConfig.blockSizeVertical! * 6)
                      ]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProgressGallery(
                              images: progress.tracker!.months,
                              type: progress!.type)),
                    );
                  },
                ),
              ),
              sBox(h: 4)
            ],
          ),
        ),
      ),
      // months before and after starting date
      if (show == false)
        Positioned(
          top: SizeConfig.blockSizeVertical! * 2.4,
          right: SizeConfig.blockSizeVertical! * 2.25,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: SizeConfig.blockSizeVertical! * 25.5,
                width: SizeConfig.blockSizeHorizontal! * 91.50,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Colors.black.withOpacity(.5)),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: Text(
                      getMessage(int.parse(dropdownValue.toString()),
                          _selectedMonthIndex + 1, _selectedWeekIndex + 1),
                      textAlign: TextAlign.center,
                      style: const ts.TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      //missed uploads and condition for month with data
      if (progress!.tracker!.months![showMonth].weeks![_selectedWeekIndex]
                  .frontImage ==
              '' &&
          progress!.tracker!.months![showMonth].weeks![_selectedWeekIndex]
                  .currentWeek !=
              true &&
          // _selectedWeekIndex != weekOfMonth(DateTime.now()) &&
          show == true)
        Positioned(
          top: SizeConfig.blockSizeVertical! * 2.4,
          right: SizeConfig.blockSizeVertical! * 2.25,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: SizeConfig.blockSizeVertical! * 25.5,
                width: SizeConfig.blockSizeHorizontal! * 91.50,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Colors.black.withOpacity(.5)),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Text(
                    getMessage(int.parse(dropdownValue.toString()),
                        _selectedMonthIndex + 1, _selectedWeekIndex + 1),
                    textAlign: TextAlign.center,
                    style: const ts.TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              ),
            ),
          ),
        )
    ]);
  }

  var showAll = true;

  Container skinWidget(context, progress) {
    String doctorNote = progress
        .skinData.images.months[showMonth].weeks[_selectedWeekIndex].doctorNote;
    return Container(
      decoration: const BoxDecoration(
          color: c.Color(0xffFFEDE3),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: Column(
        children: [
          sBox(h: 2),
          detailsCard(progress, context),
          sBox(h: 1),
          if (progress.skinData.images.months[showMonth]
                      .weeks[_selectedWeekIndex].doctorNote !=
                  '' &&
              dropdownValue ==
                  progress.skinData.images.months[showMonth].year.toString())
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const c.Color(0xffF6FCFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Doctor\'s note',
                                style:
                                    ts.TextStyle(fontWeight: FontWeight.bold),
                              ),
                              sBox(w: 48),
                            ],
                          ),
                          const Divider(
                            endIndent: 10,
                            indent: 2,
                            color: Colors.grey,
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 2, right: 10),
                              decoration: const BoxDecoration(
                                color: c.Color(0xffF2F5FB),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 12),
                                child: Text.rich(TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        style: const ts.TextStyle(
                                          fontSize: 14.0,
                                          color: c.Color(0xff0B4870),
                                        ),
                                        text: doctorNote),
                                  ],
                                )),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          sBox(h: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              key: progressGalleryButton,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: Size(SizeConfig.blockSizeHorizontal! * 90,
                      SizeConfig.blockSizeVertical! * 6),
                  // padding: EdgeInsets.symmetric(horizontal: 16.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'Progress Gallery',
                        style: ts.TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      // Spacer(),
                      sBox(w: 8),
                      Icon(Icons.arrow_right_sharp,
                          color: Colors.white,
                          size: SizeConfig.blockSizeVertical! * 6)
                    ]),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProgressGallery(
                              images: progress.tracker.months,
                              type: progress.type)));
                },
              ),
            ),
          ),
          sBox(h: 3)
        ],
      ),
    );
  }

  DateTime getFirstDateOfSelectedWeek(int year, int month, int weekNumber) {
    final firstDayOfMonth = DateTime(year, month);
    final firstDayOfWeek = firstDayOfMonth.weekday;

    final daysToAdd = (weekNumber - 1) * DateTime.daysPerWeek - firstDayOfWeek;
    final firstDateOfWeek = firstDayOfMonth.add(Duration(days: daysToAdd));
    final formatter = DateFormat('dd/MM/yyyy');
    final parsedDate = formatter.parse(formatter.format(firstDateOfWeek));
    return parsedDate;
  }

  DateTime getWeekStartDate(DateTime date) {
    final weekday = date.weekday;
    final weekStartDate =
        date.subtract(Duration(days: weekday - (DateTime.monday - 1)));
    final formatter = DateFormat('dd/MM/yyyy');
    final parsedDate = formatter.parse(formatter.format(weekStartDate));
    return parsedDate;
  }

  String getMessage(var selectedYear, var selectedMonth, var selectedWeek) {
    if (getFirstDateOfSelectedWeek(selectedYear, selectedMonth, selectedWeek)
        .isBefore(
            getWeekStartDate(progress.tracker?.startDate ?? DateTime.now()))) {
      return 'Your Journey started from week ${weekOfMonth(progress.tracker?.startDate)} of ${DateFormat.yMMMM().format(progress.tracker?.startDate ?? DateTime.now()).toString()}';
    } else if (getFirstDateOfSelectedWeek(
                selectedYear, selectedMonth, selectedWeek)
            .isAfter(getWeekStartDate(
                progress.tracker?.startDate ?? DateTime.now())) &&
        getFirstDateOfSelectedWeek(selectedYear, selectedMonth, selectedWeek)
            .isBefore(getWeekStartDate(DateTime.now()))) {
      return 'Oops! It seems that you forgot to upload a picture for this week';
    } else if (getFirstDateOfSelectedWeek(
            selectedYear, selectedMonth, selectedWeek)
        .isAfter(getWeekStartDate(DateTime.now()))) {
      return 'Uploading a picture is limited to current week only';
    } else {
      return 'Oops! It seems that you forgot to upload a picture for this week';
    }
  }

  int getTotalNumberOfWeeksInMonth(int year, int month) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    // Calculate the number of days in the month
    int totalDaysInMonth = lastDayOfMonth.day;

    // Calculate the number of weeks
    int totalNumberOfWeeks =
        ((totalDaysInMonth - firstDayOfMonth.weekday + 7) / 7).ceil();

    return totalNumberOfWeeks;
  }
}
