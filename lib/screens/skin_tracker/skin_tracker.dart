import 'package:flutter/material.dart';
// import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../frameworks/progress/progress_service.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../models/user_model.dart';
import 'skin_home_page.dart';

class Skin extends StatefulWidget {
  const Skin({Key? key}) : super(key: key);
  @override
  _SkinState createState() => _SkinState();
}

class _SkinState extends State<Skin> {
  bool remindMe = false;
  int sindex = 0;
  var userInfo;
  // ProgressDialog? progressDialog;
  var progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);
  List conditions = [];
  List goals = [];
  bool show = true;
  num goalWeight = 0;
  num timeLine = 0;

  // var skinData;

  StatefulBuilder button({String? text}) {
    var bColor = Colors.white;
    getColor() {
      if (sindex == 0) {
        return conditions.contains(text)
            ? bColor = Theme.of(context).primaryColor
            : bColor = Colors.white;
      } else {
        return goals.contains(text)
            ? bColor = Theme.of(context).primaryColor
            : bColor = Colors.white;
      }
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setstate) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton(
          style: TextButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor),
            backgroundColor: getColor(),
            minimumSize: Size(SizeConfig.blockSizeHorizontal! * 80,
                SizeConfig.blockSizeVertical! * 4),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          child: Text(
            text!,
            style: TextStyle(
                color: bColor == Colors.white
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          onPressed: () {
            setstate(() {
              if (sindex == 0) {
                conditions.contains(text) == false
                    ? conditions.add(text)
                    : conditions.remove(text);

                print(conditions);
              } else {
                goals.contains(text) == false
                    ? goals.add(text)
                    : goals.remove(text);
              }
            });
          },
        ),
      );
    });
  }

  StatefulBuilder customTile(text, index) {
    var bColor = Colors.white;
    Color getColor() {
      if (sindex == 0) {
        return conditions.contains(progress!.conditions[index].id.toString())
            ? bColor = const Color(0xffFFEDE3)
            : bColor = Colors.white;
      } else {
        return goals.contains(progress!.goals[index].id.toString())
            ? bColor = const Color(0xffFFEDE3)
            : bColor = Colors.white;
      }
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setstate) {
      return GestureDetector(
        onTap: () {
          setstate(() {
            if (sindex == 0) {
              conditions.contains(progress!.conditions[index].id.toString()) ==
                      false
                  ? conditions.add(progress!.conditions[index].id.toString())
                  : conditions
                      .remove(progress!.conditions[index].id.toString());
            } else {
              goals.contains(progress!.goals[index].id.toString()) == false
                  ? goals.add(progress!.goals[index].id.toString())
                  : goals.remove(progress!.goals[index].id.toString());
            }
          });
        },
        child: Container(
          // margin:
          //     EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 3),
          padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal! * 10,
              top: SizeConfig.blockSizeVertical! * 3,
              bottom: SizeConfig.blockSizeVertical! * 3),
          color: getColor(),
          child: Row(
            children: [
              bColor == Colors.white
                  ? CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: SizeConfig.blockSizeHorizontal! * 2.7,
                      child: CircleAvatar(
                        radius: SizeConfig.blockSizeHorizontal! * 2.2,
                        backgroundColor: Colors.white,
                      ))
                  // ? Icon(
                  //     Icons.circle,
                  //     color: Colors.grey[300],
                  //   )
                  : Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
              sBox(w: 4),
              Text(
                text,
                style: const TextStyle(color: Colors.black, fontSize: 19),
              )
            ],
          ),
        ),
      );
    });
  }

  dynamic questionare(index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              sBox(h: 6),
              Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal! * 9,
                      right: SizeConfig.blockSizeHorizontal! * 0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lets Get started!',
                      // textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  )),
              sBox(h: 3),
              Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal! * 9,
                    right: SizeConfig.blockSizeHorizontal! * 9),
                child: const Text(
                  'Get Started by selecting below all the conditions that describe your skin',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              sBox(h: 4),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: progress!.conditions.length,
                  itemBuilder: (context, index) {
                    return customTile(progress!.conditions[index].name, index);
                  }),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {

                    setState(() {
                      if (conditions.isNotEmpty) {
                        sindex++;
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Select at least 1 Condition to Continue',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey[600],
                            textColor: Colors.white);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Theme.of(context).primaryColor))),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          sBox(w: 1),
                          Icon(
                            Icons.arrow_right_alt_rounded,
                            size: SizeConfig.blockSizeHorizontal! * 10,
                            color: Theme.of(context).primaryColor,
                          )
                        ]),
                  ),
                ),
              ),
              sBox(h: 10)
            ],
          ),
        );
      case 1:
        return Column(
          children: [
            sBox(h: 4),
            Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal! * 9,
                    right: SizeConfig.blockSizeHorizontal! * 9),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Your Skincare goals',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                )),
            sBox(h: 2),
            Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal! * 9,
                    right: SizeConfig.blockSizeHorizontal! * 9),
                child: const Text(
                  'Track your progress while you are on your treatment',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20),
                )),
            sBox(h: 4),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: progress!.goals.length,
                itemBuilder: (context, index) {
                  return customTile(progress!.goals[index].name, index);
                }),
            sBox(h: 6),
            ElevatedButton(
              style: TextButton.styleFrom(
                elevation: 5,
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: Size(SizeConfig.blockSizeHorizontal! * 30,
                    SizeConfig.blockSizeVertical! * 5),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              child: const Text(
                'Proceed To Track',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onPressed: () {
                setState(() {
                  if (goals.isNotEmpty) {
                    ProgressService().addConditionsGoals(
                        userId: progress!.user!.id,
                        type: progress!.type,
                        conditions: conditions,
                        goals: goals);
                    Provider.of<ProgressTrackingVM>(context, listen: false)
                        .fetchImages()
                        .then((value) => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SkinHomePage())));
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Select at least 1 Goal to Continue',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white);
                  }
                });
              },
            ),
            sBox(h: 2)
          ],
        );
    }
  }

  Widget _noUserView() {
    final progress = Provider.of<ProgressTrackingVM>(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            '${progress.type!} Tracker',
            style: const TextStyle(
              color: Colors.black,
              // color: Theme.of(context).accentColor,
            ),
          ),
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
        ));
  }

  Scaffold initialPage() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.chevron_left),
        ),
        title: userInfo.user.name != null
            ? Text('Hi ${userInfo.user.name}')
            : const Text(' Hey Login'),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: const Color(0xffFFEDE3),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            sBox(h: 25),
            Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                height: 600,
                child: Center(child: questionare(sindex)))
          ],
        ),
      ),
    );
  }

  // ignore: unused_field
  ScrollController? _controller;
  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // a = key.currentContext.findRenderObject();
    userInfo = Provider.of<UserModel>(context);
    // progressDialog = ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);
    return userInfo.user == null
        ? _noUserView()
        :
        // progress!.isloading
        //         ? Scaffold(
        //             appBar: AppBar(
        //               title: const Text('Skin Tracker'),
        //               backgroundColor: Theme.of(context).backgroundColor,
        //             ),
        //             body:
        //             Center(child: LoadingWidget()))
        //         :
        progress.skinData == null || progress.skinData!.conditions!.isEmpty
            ? initialPage()
            : const SkinHomePage();
  }
}
