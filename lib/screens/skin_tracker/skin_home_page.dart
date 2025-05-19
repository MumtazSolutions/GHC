import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../widgets/loading_widget.dart';
import 'skin_calendar.dart';

class SkinHomePage extends StatefulWidget {
  const SkinHomePage({Key? key}) : super(key: key);

  @override
  _SkinHomePageState createState() => _SkinHomePageState();
}

class _SkinHomePageState extends State<SkinHomePage> {
  // ProgressDialog? progressDialog;
  var progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  // var pCalendar = AppData();
  var values;

  ScrollController? _controller;
  ScrollController? _vcontroller;
  var progressDialog;
  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _vcontroller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context: context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Skin Tracker'),
        actions: [
          Consumer<ProgressTrackingVM>(builder: (context, progess, child) {
            return Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Theme.of(context).primaryColor)),
              child: Padding(
                  padding: const EdgeInsets.only(
                    right: 10.0,
                    left: 10.0,
                  ),
                  // add weeks from backend
                  child: progress.tracker != null
                      ? Text(
                          '${progress.tracker!.presentWeek}/${progress.tracker!.totalWeeks}')
                      : const Text('0/52')),
            );
          })
        ],
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Consumer<ProgressTrackingVM>(builder: (context, pVm, _) {
        return SingleChildScrollView(
          controller: _vcontroller,
          child: Column(
            children: pVm.isloading
                ? <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeVertical! * 35),
                        child: const LoadingWidget())
                  ]
                : <Widget>[
                    SkinCalendar(
                      progressDialog: progressDialog,
                      controller: _controller,
                      vScontroller: _vcontroller,
                    ),
                  ],
          ),
        );
      }),
    );
  }
}
