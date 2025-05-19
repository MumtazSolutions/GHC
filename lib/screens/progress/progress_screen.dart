import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../app.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../menu/maintab_delegate.dart';
import '../../models/entities/weight_data.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../models/user_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/progress_stepper/progress_calendar.dart';
import '../weight_tracker/weight_init_page.dart';

class ProgressScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProgressScreenPage();
  }
}

class ProgressScreenPage extends State<ProgressScreen> {
  PickedFile? image;
  File? tmpFile;
  int? weight;

  bool isSwitched = true;
  ScrollController? _controller;
  ScrollController? _vcontroller;

  Future getImage(progress) async {
    final picker = ImagePicker();
    bool isCamera = true;
    if (isCamera) {
      image = await picker.getImage(source: ImageSource.camera);
      setState(() {
        if (image != null) {
          tmpFile = File(image!.path);
        } else {
          tmpFile = null;
        }
      });
      // if (tmpFile != null) {
      //   progressDialog!.update(message: 'Uploading Image');
      //   await progressDialog!.show();
      //   await Provider.of<ProgressTrackingVM>(context, listen: false).addProgress(
      //       file: tmpFile,
      //       response: (result) {
      //         progressDialog!.hide();
      //       });
      // }
    }
  }

  Future getGalleryImage(progress) async {
    final picker = ImagePicker();
    bool isCamera = true;
    if (isCamera) {
      image = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (image != null) {
          tmpFile = File(image!.path);
        } else {
          tmpFile = null;
        }
      });
      // if (tmpFile != null) {
      //   progressDialog!.update(message: 'Uploading Image');
      //   await progressDialog!.show();
      //   await Provider.of<ProgressTrackingVM>(context, listen: false).addProgress(
      //       file: tmpFile,
      //       response: (result) {
      //         progressDialog!.hide();
      //       });
      // }
    }
  }

  late BuildContext dialogContext;
  void showAlertDialog(BuildContext context, progress) {
    // set up the buttons

    // set up the AlertDialog
    // ignore: omit_local_variable_types
    AlertDialog alert = AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        titlePadding: const EdgeInsets.fromLTRB(8, 0, 2, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upload Photo',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                })
          ],
        ),
        content: SizedBox(
          height: 150,
          // width: 300,
          child: Column(
            children: [
              TextButton(
                child: Text(
                  'Open Camera',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  getImage(progress);
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: Text(
                  'Upload from Gallery',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  getGalleryImage(progress);
                  Navigator.of(dialogContext).pop();
                },
              ),
              ElevatedButton(
                style: TextButton.styleFrom(
                  elevation: 7,
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(128, 27),
                  // padding: EdgeInsets.symmetric(horizontal: 16.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              )
            ],
          ),
        )
        // actions: [
        //   cancelButton,
        //   continueButton,
        // ],
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

  var progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);
  var userInfo = Provider.of<UserModel>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _vcontroller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      log('____HERE FETH');
      await progress.fetchImages();
    });
  }

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
                  // Navigator.of(
                  //   App.fluxStoreNavigatorKey.currentContext!,
                  // ).pushNamed(RouteList.login);
                  // progress.tabController?.removeListener(_tabListener);
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
    );
  }

  Widget showCatgeoryProgress(
      ProgressTrackingVM progress,
      // ProgressDialog pDialog,
      user) {

    if (progress.type == 'Weight Loss') {
      return user == null ? _noUserView() : const WeightInitPage();
    } else {
      return Center(
          child: SingleChildScrollView(
              controller: _vcontroller,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: progress.isloading
                    ? <Widget>[
                        //const Expanded(child:
                        const LoadingWidget()
                        //  )
                      ]
                    : <Widget>[
                        // ProgressTimeline(progress.images.length, context),
                        // ProgressStepper(currentIndex: progress.images.length),
                        ProgressCalendar(
                          // progressDialog: pDialog,
                          controller: _controller!,
                          vScontroller: _vcontroller!,
                        ),
                        // sBox(h: 1),
                        // Padding(
                        //     padding: const EdgeInsets.all(16.0),
                        //     child: Column(
                        //       children: [
                        //         const SizedBox(height: 34),
                        //         const SizedBox(height: 35),
                        //         TextButton(
                        //             onPressed: () {
                        //               FluxNavigate.pushNamed(
                        //                 RouteList.progressGallery,
                        //                 arguments: progress.tracker.months,
                        //               );
                        //             },
                        //             style: TextButton.styleFrom(
                        //               // backgroundColor: Theme.of(context).primaryColor,
                        //               backgroundColor:
                        //                   Color(0xffE4756A).withOpacity(.9),
                        //               minimumSize: const Size(326, 44),
                        //               // padding: EdgeInsets.symmetric(horizontal: 16.0),
                        //               shape: const RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     BorderRadius.all(Radius.circular(30)),
                        //               ),
                        //             ),
                        //             child: Padding(
                        //               padding:
                        //                   const EdgeInsets.symmetric(horizontal: 30.0),
                        //               child: Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.spaceBetween,
                        //                 children: [
                        //                   const Text(
                        //                     'Progress Gallery',
                        //                     style: TextStyle(
                        //                         color: Colors.white, fontSize: 22),
                        //                   ),
                        //                   const Icon(
                        //                     Icons.arrow_right_outlined,
                        //                     color: Colors.white,
                        //                     size: 32,
                        //                   )
                        //                 ],
                        //               ),
                        //             ))
                        //       ],
                        //     )),
                      ],
              )));
    }
  }

  Widget getWeightProgressView(ProgressTrackingVM progress) {
    return Column(
      children: progress.isloading
          ? <Widget>[const Expanded(child: Center(child: LoadingWidget()))]
          : [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SfCartesianChart(
                    title: ChartTitle(text: 'Monthly Weight Graph'),
                    legend: Legend(isVisible: true),
                    series: <ChartSeries>[
                      LineSeries<WeightProgress, double>(
                          dataSource: getWeightData(progress),
                          xValueMapper: (WeightProgress data, _) => data.month,
                          yValueMapper: (WeightProgress data, _) => data.weight,
                          name: 'Months')
                    ],
                    primaryYAxis: NumericAxis(labelFormat: '{value}KG'),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Center(
                    child: progress.isValidDate
                        ? FloatingActionButton.extended(
                            onPressed: () {
                              Navigator.of(
                                App.fluxStoreNavigatorKey.currentContext!,
                              ).pushNamed(RouteList.addWeight);
                              return;
                            },
                            isExtended: true,
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            // icon: const Icon(Icons.account_box_rounded, size: 20),
                            label: const Text('Enter Weight'),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context).primaryColor,
                                      spreadRadius: 1.5),
                                ],
                              ),
                              child: Text(
                                'You have added your weight already this week',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          )),
              )
            ],
    );
  }

  List<WeightProgress> getWeightData(ProgressTrackingVM progress) {
    List<WeightProgress> chart = [];
    // chart.add(WeightProgress(month: 0, weight: 0));
    // progress.tracker.months.asMap().forEach((index, element) {
    //   element.images.asMap().forEach((key, value) {
    //     chart.add(
    //         WeightProgress(month: index + (key / 10), weight: value.weight));
    //   });
    // });
    return chart;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // progressDialog = ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);
    log('_______________IS LOADING:${progress.isloading}');
    // TODO: implement build
    return Consumer<ProgressTrackingVM>(builder: (context, pVm, _) {
      return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text(
              "${pVm?.type ?? ""} Tracker",
              style: const TextStyle(
                color: Colors.black,
                // color: Theme.of(context).accentColor,
              ),
            ),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_sharp,
                  color: Colors.black,
                  size: SizeConfig.blockSizeVertical! * 2,
                  // color: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  Get.back();

                  log('__________INDEX:${MainTabControlDelegate.getInstance().index}');
                }),
            centerTitle: false,
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          body: userInfo.user == null
              ? _noUserView()
              : pVm.tracker.toString() == 'error'
                  ? const Center(child: Text('Please Reload!'))
                  : pVm.isloading
                      ? Column(children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  top: SizeConfig.blockSizeVertical! * 35),
                              child: const LoadingWidget())
                        ])
                      : showCatgeoryProgress(
                          progress!,
                          // progressDialog!,
                          userInfo.user));
    });
  }
}
