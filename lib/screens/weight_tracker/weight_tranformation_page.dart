import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/progress_stepper/progress_calendar.dart';

class WeightTransormatioPage extends StatefulWidget {
  const WeightTransormatioPage({Key? key}) : super(key: key);

  @override
  _WeightTransormatioPageState createState() => _WeightTransormatioPageState();
}

class _WeightTransormatioPageState extends State<WeightTransormatioPage> {
  ProgressDialog? progressDialog;
  var progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  ScrollController? _controller;
  ScrollController? _vcontroller;

  @override
  void initState() {
    _controller = ScrollController();
    _vcontroller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => progress.fetchImages());
    super.initState();
  }

  Widget showCatgeoryProgress(
      ProgressTrackingVM? progress, ProgressDialog? pDialog) {
    return SingleChildScrollView(
      controller: _vcontroller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: progress!.isloading
            ? <Widget>[const Expanded(child: Center(child: LoadingWidget()))]
            : <Widget>[
                ProgressCalendar(
                  controller: _controller,
                  vScontroller: _vcontroller,
                ),
                sBox(h: 1),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Wellness Tracker',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Colors.black,
              size: SizeConfig.blockSizeVertical! * 2,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Container(
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
                          '${progress.tracker!.presentWeek!}/${progress.tracker!.totalWeeks!}')
                      : Container()),
            )
          ],
          centerTitle: false,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: showCatgeoryProgress(progress, progressDialog));
  }
}
