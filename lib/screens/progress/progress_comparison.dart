import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/entities/progress_image.dart';
import '../../models/index.dart';
import '../../models/progress/progressComparison_vm.dart';
import '../../models/progress/progress_tracking_model.dart';
import 'full_image_screen.dart';

class ProgressComparisonPage extends StatefulWidget {
  final ProgressWeek? images1;
  final ProgressWeek? images2;
  final bool? front;
  const ProgressComparisonPage(
      {Key? key, this.images1, this.images2, this.front})
      : super(key: key);

  @override
  _ProgressComparisonPageState createState() => _ProgressComparisonPageState();
}

class _ProgressComparisonPageState extends State<ProgressComparisonPage> {
  int selectedIndex = 0;
  ScreenshotController screenshotController = ScreenshotController();
  String? rating;
  var progress = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  TextEditingController feedbackController = TextEditingController();
  num? weeks;

  picToShow({index, isFirst = false}) {
    if ((widget.images2!.date!.difference(widget.images1!.date!).inDays ~/ 7)
            .toInt() <
        0) {
      if (isFirst) {
        return index == 0
            ? widget.images2!.frontImage
            : widget.images2!.topImage;
      } else {
        return index == 0
            ? widget.images1!.frontImage
            : widget.images1!.topImage;
      }

      // return index == 0 ? widget.images2.frontImage : widget.images1.topImage;
    } else {
      if (isFirst) {
        return index == 0
            ? widget.images1!.frontImage
            : widget.images1!.topImage;
      } else {
        return index == 0
            ? widget.images2!.frontImage
            : widget.images2!.topImage;
      }
    }
  }

  Row imageView(index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              final image = {
                'src': picToShow(index: index, isFirst: true),
                'index': index
              };
              return FullImageView(image);
            }));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              filterQuality: FilterQuality.low,
              imageUrl: picToShow(index: index, isFirst: true),
              imageBuilder: (context, imageProvider) {
                return Image(
                  height: 160,
                  width: 160,
                  image: imageProvider,
                  fit: BoxFit.cover,
                );
              },
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: CircularProgressIndicator(
                      value: downloadProgress.progress),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        sBox(w: 4),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  final image = {
                    'src': picToShow(index: index),
                    'index': index
                  };
                  return FullImageView(image);
                },
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              filterQuality: FilterQuality.low,
              imageUrl: picToShow(index: index),
              imageBuilder: (context, imageProvider) {
                return Image(
                  height: 160,
                  width: 160,
                  image: imageProvider,
                  fit: BoxFit.cover,
                );
              },
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: CircularProgressIndicator(
                      value: downloadProgress.progress),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ],
    );
  }

  Padding compareDates(index) {
    String dateToShow;
    if (widget.images2!.date!.difference(widget.images1!.date!).inDays ~/ 7 <
        0) {
      weeks = widget.images1!.date!.difference(widget.images2!.date!).inDays ~/
          7.abs();
      dateToShow = DateFormat.MMMd().format(widget.images2!.date!);
    } else {
      weeks =
          (widget.images2!.date!.difference(widget.images1!.date!).inDays / 7)
              // .toInt()
              .abs();
      dateToShow = DateFormat.MMMd().format(widget.images1!.date!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Text(
        weeks! > 1
            ? '${weeks!.toStringAsFixed(0)} weeks of progress tracked from $dateToShow'
            : '${weeks!.toStringAsFixed(0)} week of progress tracked from $dateToShow',
        style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  dynamic getName({front = false}) {
    switch (progress.type) {
      case 'Hair':
        return front ? 'Front' : 'Top';
      case 'Beard':
        return front ? 'Left' : 'Right';
      case 'Weight Loss':
        return front ? 'Front' : 'Side';
      case 'Skin':
        return front ? 'Face' : 'Face';
    }
  }

  changePage(type) {
    //skinId = Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI3NDU3OTUyMTcwMA==
    //weight = Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NzM2MjA3NDc4OA==
    //performance = Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI4MDMwOTUzMDc4OA==
    //beard = Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI4MDMwOTI2ODY0NA==
    //hair = Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI4MDMwODA1NjIyOA==
    switch (type) {
      case 'Hair':
        Navigator.of(Get.context!).popUntil((route) => route.isFirst);
        ProductModel.showList(
          context: Get.context,
          cateId: 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI4MDMwODA1NjIyOA==',
          cateName: 'Hair Growth And Hair Care Products',
        );
        break;
      case 'Beard':
        Navigator.of(Get.context!).popUntil((route) => route.isFirst);
        ProductModel.showList(
          context: Get.context,
          cateId: 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI4MDMwOTI2ODY0NA==',
          cateName: 'Beard Growth Products',
        );
        break;
      case 'Weight Loss':
        Navigator.of(Get.context!).popUntil((route) => route.isFirst);
        ProductModel.showList(
          context: Get.context,
          cateId: 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NzM2MjA3NDc4OA==',
          cateName: 'Weight Loss Supplements',
        );
        break;
      case 'Skin':
        Navigator.of(Get.context!).popUntil((route) => route.isFirst);
        ProductModel.showList(
          context: Get.context,
          cateId: 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI3NDU3OTUyMTcwMA==',
          cateName: 'Skin',
        );
        break;
    }
  }

  BuildContext? dialogContext;
  void showAlertDialog(BuildContext context) {
    Widget continueButton = ElevatedButton(
      style: TextButton.styleFrom(
        elevation: 5,
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: Size(SizeConfig.blockSizeHorizontal! * 40,
            SizeConfig.blockSizeVertical! * 5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      child: const Text(
        'Shop',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      onPressed: () {
        print('test feedback');
        var progress =
            Provider.of<ProgressTrackingVM>(Get.context!, listen: false);
        changePage(progress.type);
      },
    );

    // set up the AlertDialog
    // ignore: omit_local_variable_types
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 2.0),
      content: SizedBox(
        height: SizeConfig.blockSizeVertical! * 32,
        width: SizeConfig.blockSizeHorizontal! * 22,
        child: Image.asset('assets/images/ThankyouCard.png'),
      ),
      actionsPadding: EdgeInsets.only(
          right: SizeConfig.blockSizeHorizontal! * 17,
          left: SizeConfig.blockSizeHorizontal! * 4,
          bottom: 20),
      actions: [
        continueButton,
      ],
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

  void takeSS() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);

        /// Share Plugin
        await Share.shareFiles([imagePath.path],
            text:
                'Here is my ${addMsg()} progress tracked from mars by ghc App. Click the link to download the app. \n https://play.google.com/store/apps/details?id=com.ghc.marsapp');
      }
    });
  }

  addMsg() {
    var type = Provider.of<ProgressTrackingVM>(context, listen: false).type;
    switch (type) {
      case 'Hair':
        return 'Hair Growth';
      case 'Beard':
        return 'Beard Growth';
      case 'Weight Loss':
        return 'Weight Loss';
      case 'Skin':
        return 'Skin';
    }
  }

  @override
  void initState() {
    super.initState();
    widget.front! ? selectedIndex = 0 : selectedIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Progress Comparison',
            style: TextStyle(
              // color: Theme.of(context).accentColor,
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
              // color: Theme.of(context).accentColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
                onPressed: () => takeSS())
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              sBox(h: 2),
              if (progress.type != 'Skin')
                Container(
                  // width: SizeConfig.blockSizeHorizontal * 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndex == 0
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              // border: Border.all(color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              child: Text(
                                getName(front: true) + ' View',
                                style: TextStyle(
                                    color: selectedIndex == 0
                                        ? Colors.white
                                        : Theme.of(context).primaryColor),
                              ),
                            )),
                      ),
                      sBox(w: 1),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              // border: Border.all(color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              child: Text(
                                getName() + ' View',
                                style: TextStyle(
                                    color: selectedIndex == 1
                                        ? Colors.white
                                        : Theme.of(context).primaryColor),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              sBox(h: 4),
              imageView(selectedIndex),
              sBox(h: 4),
              compareDates(selectedIndex),
              sBox(h: 6),
              Text(
                'Tell us how’s your treatment is going',
                style: TextStyle(
                    fontSize: 17, color: Theme.of(context).accentColor),
              ),
              sBox(h: 4),
              RatingBar.builder(
                initialRating: 0,
                itemCount: 5,
                // ignore: missing_return
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return rating == null
                          ? const Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.redAccent,
                            )
                          : getSmiley(rating);
                    // : rating == '1.0'?getSmiley(rating):
                    case 1:
                      return rating == null
                          ? const Icon(
                              Icons.sentiment_dissatisfied,
                              color: Colors.redAccent,
                            )
                          // : getSmiley(rating);
                          : double.parse(rating!) >= 2.0
                              ? getSmiley(rating)
                              : const Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.redAccent,
                                );

                    case 2:
                      return rating == null
                          ? const Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            )
                          // : getSmiley(rating);
                          : double.parse(rating!) >= 3.0
                              ? getSmiley(rating)
                              : const Icon(
                                  Icons.sentiment_neutral,
                                  color: Colors.amber,
                                );
                    case 3:
                      return rating == null
                          ? const Icon(
                              Icons.sentiment_satisfied,
                              color: Colors.lightGreen,
                            )
                          // : getSmiley(rating);
                          : double.parse(rating!) >= 4.0
                              ? getSmiley(rating)
                              : const Icon(
                                  Icons.sentiment_satisfied,
                                  color: Colors.lightGreen,
                                );
                    case 4:
                      return rating == null
                          ? const Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            )
                          // : getSmiley(rating);
                          : double.parse(rating!) >= 5.0
                              ? getSmiley(rating)
                              : const Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green,
                                );

                    default:
                      return rating == null
                          ? const Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.redAccent,
                            )
                          : getSmiley(rating);
                  }
                },
                onRatingUpdate: (r) {
                  // print(r);
                  setState(() {
                    rating = r.toString();
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  maxLines: 5,
                  controller: feedbackController,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    hintText: "Your message here",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    fillColor: Colors.black,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF434343))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF434343))),
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              if (rating != null || feedbackController.text != '') {
                var feedbackApi =
                    Provider.of<ProgressComparisonVm>(context, listen: false);
                feedbackApi.collectFeedback(
                    feedbackController.text,
                    context,
                    rating,
                    progress.type,
                    weeks!.toStringAsFixed(0),
                    picToShow(index: index, isFirst: true),
                    picToShow(index: index),
                    widget.images1!.date,
                    widget.images2!.date);
                Navigator.pop(context);
                // Navigator.push(context,
                // MaterialPageRoute(builder: (context) => ProgressGallery()));
                showAlertDialog(context);
              } else {
                Fluttertoast.showToast(
                    msg: 'Please select rating or type message',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey[600],
                    textColor: Colors.white);
              }
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  getSmiley(rating) {
    switch (rating) {
      case '1.0':
        return const Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.redAccent,
        );
      case '2.0':
        return const Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.redAccent,
        );
      case '3.0':
        return const Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
        );
      case '4.0':
        return const Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        );
      case '5.0':
        return const Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
        );
    }
  }
}
