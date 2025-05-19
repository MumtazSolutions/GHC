import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../frameworks/progress/progress_service.dart';
import '../../models/entities/progress_image.dart';
import '../../models/index.dart';
import '../../models/progress/progress_tracking_model.dart';
import '../../widgets/loading_widget.dart';

class SkinHealthPage extends StatefulWidget {
  final String? image;
  final num? weekScore;
  final List? monthIndex;
  final int? showMonth;
  final int? selectedWeekIndex;
  const SkinHealthPage(
      {Key? key,
      this.image,
      this.weekScore,
      this.monthIndex,
      this.showMonth,
      this.selectedWeekIndex})
      : super(key: key);

  @override
  _SkinHealthPageState createState() => _SkinHealthPageState();
}

class _SkinHealthPageState extends State<SkinHealthPage> {
  ProgressWeek? presentImage;
  ProgressTrackingVM? progress;
  List<String> selectedConditions = [];
  bool loading = false;

  StatefulBuilder selectedChips({index, selected}) {
    bool sel = selected;

    return StatefulBuilder(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            state(() {
              sel = !sel;
              selectedConditions.contains(progress!.conditions[index].id)
                  ? selectedConditions.remove(progress!.conditions[index].id)
                  : selectedConditions.add(progress!.conditions[index].id!);
              print(selectedConditions);
            });
          },
          child: Chip(
            backgroundColor:
                sel ? Theme.of(context).primaryColor : Colors.white,
            side: BorderSide(color: Theme.of(context).primaryColor),
            label: Text(progress!.conditions[index].name ?? ''),
            labelPadding: const EdgeInsets.all(6),
            labelStyle: TextStyle(
                color: sel ? Colors.white : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Column overallSkinHealth() {
    for (var c in progress!.skinData!.conditions!) {
      selectedConditions.add(c.id!);
    }
    dynamic getImage() {
      for (ProgressWeek w in progress!.tracker!.months!.last.weeks!) {
        if (w.currentWeek == true) {
          return w.frontImage;
        }
      }
    }

    return Column(
      children: [
        sBox(h: .5),
        SizedBox(
          height: 150,
          width: 250,
          // color: Colors.red,
          child: CachedNetworkImage(
            filterQuality: FilterQuality.low,
            imageUrl: widget.image!,
            imageBuilder: (context, imageProvider) {
              return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image(
                    height: SizeConfig.blockSizeVertical! * 5,
                    image: imageProvider,
                    fit: BoxFit.fitHeight,
                  ));
            },
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        sBox(h: 1.5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IgnorePointer(
              ignoring: true,
              child: Container(),
            ),
            circularHealthMarker(
                value: widget.weekScore.toString(), text: '', context: context),
            //   SingleCircularSlider(
            //     300, int.parse(progress?.skinData?.overallSkinHealth.toString()??'0') * 3,
            //     // value - calc(value), //180-30,300-60,90-15,270-45
            //     height: SizeConfig.blockSizeVertical! * 12,
            //     width: SizeConfig.blockSizeVertical! * 12,
            //     handlerColor: Colors.transparent,
            //     showHandlerOutter: false,
            //     baseColor: Color(0xff145986),
            //     selectionColor: Theme.of(context).primaryColor,
            //     sliderStrokeWidth: 12.0,
            //     child: Center(
            //       child: Text(
            //         widget.weekScore.toString(),
            //         style: TextStyle(
            //           fontSize: 20.0,
            //           color: Color(0xff145986),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            sBox(w: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Skin Health',
                  style: TextStyle(fontSize: 21, color: Color(0xff0B4870)),
                ),
                sBox(h: 1),
                Text(
                  'Tracking ${progress!.skinData!.conditions!.length}/${progress!.conditions.length} skin conditions',
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[600], letterSpacing: .7),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  Column conditionsCard() {
    Padding conditionTile({name, score, image}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            image == ''
                ? SizedBox(
                    height: SizeConfig.blockSizeVertical! * 5,
                    width: SizeConfig.blockSizeVertical! * 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/uploadFrontHair.png'),
                    ))
                : CachedNetworkImage(
                    filterQuality: FilterQuality.low,
                    imageUrl: image,
                    imageBuilder: (context, imageProvider) {
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image(
                            height: SizeConfig.blockSizeVertical! * 5,
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                          ));
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
            sBox(w: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, color: Color(0xff0B4870)),
                ),
                if (score == 0)
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 50,
                    child: Text(
                      '\u{24D8} Health score for this condition is being calculated',
                      style: TextStyle(color: Colors.green[400], fontSize: 16),
                    ),
                  ),
                if (score != 0)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ProductModel.showList(
                        context: context,
                        cateId:
                            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI3NDU3OTUyMTcwMA==',
                        cateName: 'Skin',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).primaryColor))),
                      child: Text(
                        'Recommended Products \u{2192}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            sBox(w: 8),
            if (score != 0)
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: SizeConfig.blockSizeVertical! * 2.5,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: SizeConfig.blockSizeVertical! * 2.2,
                  child: Text(
                    score.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0B4870),
                    ),
                  ),
                ),
              ),
            // if (score == 0) const Spacer()
          ],
        ),
      );
    }

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal! * 17),
          child: const Text(
            'Skin Conditions Being Tracked:',
            style: TextStyle(color: Color(0xff0B4870), fontSize: 19),
          ),
        ),
        sBox(h: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: progress!.skinData!.conditions?.length,
          itemBuilder: (context, index) => Align(
            alignment: Alignment.centerLeft,
            child: conditionTile(
              name: progress?.skinData?.conditions?[index].name,
              image: progress?.skinData?.conditions?[index].image,
              score: getScore(progress?.skinData?.conditions?[index].id),
            ),
          ),
        ),
        sBox(h: 1),
        ElevatedButton(
          style: TextButton.styleFrom(
            elevation: 5,
            backgroundColor: Theme.of(context).primaryColor,
            minimumSize: Size(SizeConfig.blockSizeHorizontal! * 30,
                SizeConfig.blockSizeVertical! * 5),
            // padding: EdgeInsets.symmetric(horizontal: 16.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          child: const Text(
            '\u{002B}  Add More Conditions',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          onPressed: () {
            print(selectedConditions);
            showModalBottomSheet<void>(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              context: context,
              builder: (BuildContext contex) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 12, top: 10),
                        child: Text(
                          'Add more conditions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        ),
                      ),
                      Wrap(
                        children: List.generate(
                          progress!.conditions.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: selectedChips(
                              index: index,
                              // selected: true
                              selected: selectedConditions
                                  .contains(progress!.conditions[index].id),
                            ),
                          ),
                        ),
                      ),
                      sBox(h: 3),
                      Center(
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Theme.of(context).primaryColor,

                            minimumSize: Size(
                                SizeConfig.blockSizeHorizontal! * 25,
                                SizeConfig.blockSizeVertical! * 4),
                            // padding: EdgeInsets.symmetric(horizontal: 16.0),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          onPressed: () {
                            if (selectedConditions.isNotEmpty) {
                              setState(() {
                                Navigator.pop(contex);
                                loading = true;
                              });
                              List? gList = [];
                              for (var g in progress!.skinData!.skinGoals!) {
                                gList.add(g.id.toString());
                              }
                              //Call api
                              ProgressService().addConditionsGoals(
                                  userId: progress!.user!.id,
                                  type: progress!.type,
                                  conditions: selectedConditions,
                                  goals: gList);
                              Provider.of<ProgressTrackingVM>(context,
                                      listen: false)
                                  .fetchImages()
                                  .then((val) {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SkinHealthPage(
                                              image: widget.image,
                                              monthIndex: widget.monthIndex,
                                              weekScore: widget.weekScore,
                                              selectedWeekIndex:
                                                  widget.selectedWeekIndex,
                                              showMonth: widget.showMonth,
                                            )));
                              });
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      'Select at least 1 Condition to Continue',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[600],
                                  textColor: Colors.white);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Padding overAllScore() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal! * 9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                blurRadius: 2,
                // spreadRadius: .2,/
                color: Theme.of(context).primaryColor),
          ],
        ),
        child: Column(
          children: [
            sBox(h: 1),
            const Text(
              'Your overall skin score has improved',
              style: TextStyle(color: Color(0xff145986), fontSize: 18),
            ),
            sBox(h: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IgnorePointer(ignoring: true, child: Container()),
                // SingleCircularSlider(
                //     300, int.parse( progress?.skinData?.skinScoreBefore.toString()??'0') * 3,
                //     // value - calc(value), //180-30,300-60,90-15,270-45
                //     height: SizeConfig.blockSizeVertical! * 12,
                //     width: SizeConfig.blockSizeVertical! * 12,
                //     handlerColor: Colors.transparent,
                //     showHandlerOutter: false,
                //     baseColor: Color(0xff145986),
                //     selectionColor: Theme.of(context).primaryColor,
                //     sliderStrokeWidth: 12.0,
                //     child: Center(
                //       child: Text(
                //         progress!.skinData!.skinScoreBefore.toString(),
                //         style: const TextStyle(
                //           fontSize: 20.0,
                //           color: Color(0xff145986),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                circularHealthMarker(
                    value: progress!.skinData!.skinScoreBefore.toString(),
                    text: '',
                    context: context),
                sBox(w: 5),
                Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).primaryColor,
                  size: SizeConfig.safeBlockHorizontal! * 10,
                ),
                sBox(w: 5),
                circularHealthMarker(
                    value: progress!.skinData!.overallSkinHealth.toString(),
                    text: '',
                    context: context),
                IgnorePointer(ignoring: true, child: Container()),
                // SingleCircularSlider(
                //     300,
                //     (int.parse(progress?.skinData?.overallSkinHealth.toString()??'0') * 3),
                //     // value - calc(value), //180-30,300-60,90-15,270-45
                //     height: SizeConfig.blockSizeVertical! * 12,
                //     width: SizeConfig.blockSizeVertical! * 12,
                //     handlerColor: Colors.transparent,
                //     showHandlerOutter: false,
                //     baseColor: Color(0xff145986),
                //     selectionColor: Theme.of(context).primaryColor,
                //     sliderStrokeWidth: 12.0,
                //     child: Center(
                //       child: Text(
                //         progress!.skinData!.overallSkinHealth.toString(),
                //         style:
                //             TextStyle(fontSize: 20.0, color: Color(0xff145986)),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            sBox(h: 1),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progress = Provider.of<ProgressTrackingVM>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Skin Tracker'),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: loading != true
          ? SingleChildScrollView(
              child: Column(children: [
                overallSkinHealth(),
                sBox(h: 3),
                conditionsCard(),
                sBox(h: 3),
                overAllScore(),
                sBox(h: 4)
              ]),
            )
          : const Center(child: LoadingWidget()),
    );
  }

  num? getScore(var id) {
    num? score = 0;
    for (var i = 0;
        i <
            (progress!.skinData!.images?.months?[widget.showMonth ?? 1]
                    .weeks?[widget.selectedWeekIndex ?? 0].conditions?.length ??
                0);
        i++) {
      if (id ==
          progress!.skinData!.images?.months?[widget.showMonth ?? 1]
              .weeks?[widget.selectedWeekIndex ?? 0].conditions?[i].id) {
        score = progress!.skinData!.images?.months?[widget.showMonth ?? 1]
            .weeks?[widget.selectedWeekIndex ?? 0].conditions?[i].score;
        break;
      } else {
        score = 0;
      }
    }
    return score;
  }
}
