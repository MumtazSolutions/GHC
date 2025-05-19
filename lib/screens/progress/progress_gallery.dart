import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/entities/monthly_progress_images.dart';
import '../../models/entities/progress_image.dart';
import '../../models/progress/progress_tracking_model.dart';
import 'full_image_screen.dart';
import 'progress_comparison.dart';

class ProgressGallery extends StatefulWidget {
  final List<ProgressMonth>? images;
  final String? type;
  const ProgressGallery({Key? key, this.images, this.type}) : super(key: key);

  @override
  _ProgressGalleryState createState() => _ProgressGalleryState();
}

class _ProgressGalleryState extends State<ProgressGallery> {
  ProgressWeek? selection1;
  ProgressWeek? selection2;
  bool isTopSelected = false;
  bool isFrontSelected = false;
  int? topIndex;
  int? frontIndex;
  int? topMonth;
  int? frontMonth;

  int getMissedWeeksCount(monthNum) {
    var totalWeeksInMonth = widget.images![monthNum].weeks?.length ?? 0;
    var missedWeeks = 0;
    for (var i = 0; i < totalWeeksInMonth; i++) {
      if (widget.images![monthNum].weeks![i].frontImage != null &&
          widget.images![monthNum].weeks![i].frontImage != '') {
        missedWeeks = missedWeeks + 1;
      }
    }
    return totalWeeksInMonth - missedWeeks;
  }

  getName({front = false}) {
    var progress = Provider.of<ProgressTrackingVM>(context, listen: false);
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

  Widget monthSection({monthNum}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.images![monthNum].monthName! +
                  ' ' +
                  widget.images![monthNum].year.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.cancel,
                    color: Theme.of(context).primaryColor, size: 15),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  '${getMissedWeeksCount(monthNum)} weeks missed',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        //
        // -- first row -- //
        //
        if (widget.type != 'Skin')
          Text(getName(),
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        if (widget.type != 'Skin')
          SizedBox(
            height: 122,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.images![monthNum].weeks!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: Opacity(
                    opacity: isFrontSelected ? .2 : 1,
                    child: GestureDetector(
                        onTap: () {
                          if (selection1 ==
                              widget.images![monthNum].weeks![index]) {
                            setState(() {
                              selection1 = null;
                            });
                            return;
                          } else if (selection2 ==
                              widget.images![monthNum].weeks![index]) {
                            setState(() {
                              selection2 = null;
                            });
                            return;
                          }
                          if ((selection1 != null || selection2 != null) &&
                                  (selection2 == null || selection1 == null) ||
                              (selection1 != null || selection2 != null) &&
                                  (selection2 != null || selection1 != null)) {
                            setState(() {
                              topIndex = index;

                              isTopSelected = true;
                              if (isFrontSelected) isFrontSelected = false;
                              selection1 == null
                                  ? selection1 =
                                      widget.images![monthNum].weeks![index]
                                  : selection2 =
                                      widget.images![monthNum].weeks![index];
                            });
                          } else {
                            widget.images![monthNum].weeks![index].topImage!
                                        .isNotEmpty ||
                                    widget.images![monthNum].weeks![index]
                                            .topImage !=
                                        ''
                                ? Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                    final image = {
                                      'src': widget.images![monthNum]
                                          .weeks![index].topImage,
                                      'index': index
                                    };
                                    return FullImageView(image);
                                  }))
                                : {};
                          }
                        },
                        child: Stack(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: widget.images![monthNum].weeks![index]
                                          .topImage!.isNotEmpty ||
                                      widget.images![monthNum].weeks![index]
                                              .topImage !=
                                          ''
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: CachedNetworkImage(
                                        filterQuality: FilterQuality.low,
                                        imageUrl: widget.images![monthNum]
                                            .weeks![index].topImage!,
                                        imageBuilder: (context, imageProvider) {
                                          return Image(
                                            height: 121,
                                            width: 131,
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                        memCacheHeight: 121,
                                        memCacheWidth: 131,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const SizedBox(
                                          height: 121,
                                          width: 131,
                                        ),
                                      ),
                                    )
                                  : const SizedBox()),
                          widget.images![monthNum].weeks![index].topImage!
                                      .isNotEmpty ||
                                  widget.images![monthNum].weeks![index]
                                          .topImage !=
                                      ''
                              ? Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        topIndex = index;
                                        isTopSelected = true;
                                        if (isFrontSelected) {
                                          isFrontSelected = false;
                                        }
                                        selection1 == null
                                            ? selection1 = widget
                                                .images![monthNum].weeks![index]
                                            : selection2 = widget
                                                .images![monthNum]
                                                .weeks![index];
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 2),
                                      child: Icon(Icons.radio_button_off,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ))
                              : Container(),
                          if ((selection1 ==
                                      widget.images![monthNum].weeks![index] ||
                                  selection2 ==
                                      widget.images![monthNum].weeks![index]) &&
                              isTopSelected)
                            widget.images![monthNum].weeks![index].topImage!
                                        .isNotEmpty ||
                                    widget.images![monthNum].weeks![index]
                                            .topImage !=
                                        ''
                                ? Positioned(
                                    right: 10,
                                    top: 2,
                                    child: Icon(Icons.check_circle,
                                        color: Theme.of(context).primaryColor))
                                : Container(),
                          widget.images![monthNum].weeks![index].frontImage!
                                      .isNotEmpty ||
                                  widget.images![monthNum].weeks![index]
                                          .frontImage !=
                                      ''
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 25,
                                    width: 131,
                                    color: const Color.fromRGBO(0, 0, 0, 0.34),
                                    child: Row(
                                      children: [
                                        Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text('week ${index + 1}',
                                                  style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white)),
                                            )),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ])),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 5),
        //
        // -- second Row -- //
        //
        Text(getName(front: true),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        SizedBox(
          height: 122,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.images![monthNum].weeks!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Opacity(
                  opacity: isTopSelected ? .2 : 1,
                  child: GestureDetector(
                    onTap: () {
                      if (selection1 ==
                          widget.images![monthNum].weeks![index]) {
                        setState(() {
                          selection1 = null;
                        });
                        return;
                      } else if (selection2 ==
                          widget.images![monthNum].weeks![index]) {
                        setState(() {
                          selection2 = null;
                        });
                        return;
                      }
                      if ((selection1 != null || selection2 != null) &&
                              (selection2 == null || selection1 == null) ||
                          (selection1 != null || selection2 != null) &&
                              (selection2 != null || selection1 != null)) {
                        setState(() {
                          frontIndex = index;
                          frontMonth = monthNum;
                          isFrontSelected = true;
                          if (isTopSelected) isTopSelected = false;
                          selection1 == null
                              ? selection1 =
                                  widget.images![monthNum].weeks![index]
                              : selection2 =
                                  widget.images![monthNum].weeks![index];
                        });
                      } else {
                        widget.images![monthNum].weeks![index].frontImage!
                                    .isNotEmpty ||
                                widget.images![monthNum].weeks![index]
                                        .frontImage !=
                                    ''
                            ? Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                                final image = {
                                  'src': widget.images![monthNum].weeks![index]
                                      .frontImage,
                                  'index': index
                                };
                                return FullImageView(image);
                              }))
                            : {};
                      }
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          children: [
                            widget.images![monthNum].weeks![index].frontImage!
                                        .isNotEmpty ||
                                    widget.images![monthNum].weeks![index]
                                            .frontImage !=
                                        ''
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: CachedNetworkImage(
                                      filterQuality: FilterQuality.low,
                                      imageUrl: widget.images![monthNum]
                                          .weeks![index].frontImage!,
                                      imageBuilder: (context, imageProvider) {
                                        return Image(
                                          height: 121,
                                          width: 131,
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      memCacheHeight: 121,
                                      memCacheWidth: 131,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Container(
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
                                  )
                                : const SizedBox(),
                            widget.images![monthNum].weeks![index].frontImage!
                                        .isNotEmpty ||
                                    widget.images![monthNum].weeks![index]
                                            .frontImage !=
                                        ''
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          frontIndex = index;
                                          frontMonth = monthNum;
                                          isFrontSelected = true;
                                          if (isTopSelected) {
                                            isTopSelected = false;
                                          }
                                          selection1 == null
                                              ? selection1 = widget
                                                  .images![monthNum]
                                                  .weeks![index]
                                              : selection2 = widget
                                                  .images![monthNum]
                                                  .weeks![index];
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10, top: 2),
                                        child: Icon(Icons.radio_button_off,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ))
                                : Container(),
                            if ((selection1 ==
                                        widget
                                            .images![monthNum].weeks![index] ||
                                    selection2 ==
                                        widget
                                            .images![monthNum].weeks![index]) &&
                                isFrontSelected)
                              widget.images![monthNum].weeks![index].frontImage!
                                          .isNotEmpty ||
                                      widget.images![monthNum].weeks![index]
                                              .frontImage !=
                                          ''
                                  ? Positioned(
                                      right: 10,
                                      top: 2,
                                      child: Icon(Icons.check_circle,
                                          color:
                                              Theme.of(context).primaryColor))
                                  : Container(),
                            widget.images![monthNum].weeks![index].frontImage!
                                        .isNotEmpty ||
                                    widget.images![monthNum].weeks![index]
                                            .frontImage !=
                                        ''
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: 25,
                                      width: 131,
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.34),
                                      child: Row(
                                        children: [
                                          Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text('week ${index + 1}',
                                                    style: const TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white)),
                                              )),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        )),
                  ),
                ),
              );
            },
          ),
        ),
        sBox(h: 2)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Progress Gallery',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              'Select any 2 pictures from top or front view to compare',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.images!.length,
              itemBuilder: (context, index) {
                return widget.images![index].weeks!.any((element) =>
                            element.topImage?.isNotEmpty == true ||
                            element.frontImage?.isNotEmpty == true) ==
                        true
                    ? monthSection(monthNum: index)
                    : const SizedBox();
              },
            ),
          ),
          sBox(h: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          if (selection1 != null &&
              selection2 != null &&
              selection1 != selection2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProgressComparisonPage(
                          images1: selection1!,
                          images2: selection2!,
                          front: isFrontSelected,
                        )));
            Timer(const Duration(seconds: 1), () {
              setState(() {
                selection2 = null;
                selection1 = null;
                isTopSelected = false;
                isFrontSelected = false;
              });
            });
          }
          if (selection1 == null ||
              selection2 == null ||
              selection1 == selection2) {
            Fluttertoast.showToast(
                msg: 'Select 2 Pictures to Compare',
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
            'Compare',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
