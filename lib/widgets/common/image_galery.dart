/// This class is customize from - https://github.com/fluttercandies/extended_image

import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Image;

class ImageGalery extends StatelessWidget {
  final List images;
  final int index;

  const ImageGalery({required this.images,required this.index});

  @override
  Widget build(BuildContext context) {
    return PicSwiper(
      index,
      images.map((image) => PicSwiperItem(image, des: '')).toList(),
    );
  }
}

class PicSwiperItem {
  String picUrl;
  String des;

  PicSwiperItem(this.picUrl, {this.des = ''});
}

class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;

  const PicSwiper(this.index, this.pics);

  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper>
    with SingleTickerProviderStateMixin {
  var rebuildIndex = StreamController<int>.broadcast();
  var rebuildSwiper = StreamController<bool>.broadcast();
  AnimationController? _animationController;
  Animation<double>? _animation;
  VoidCallback? animationListener;

  List<double> doubleTapScales = <double>[1.0, 2.0];

  int? currentIndex;
  bool _showSwiper = true;

  @override
  void initState() {
    currentIndex = widget.index;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    _animationController?.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      shadowColor: Colors.transparent,
      child: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return ExtendedImageSlidePage(
            slideAxis: SlideAxis.both,
            slideType: SlideType.onlyImage,
            onSlidingPage: (state) {
              var showSwiper = !state.isSliding;
              if (showSwiper != _showSwiper) {
                _showSwiper = showSwiper;
                rebuildSwiper.add(_showSwiper);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ExtendedImageGesturePageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var item = widget.pics[index].picUrl;
                    Widget image = ExtendedImage.network(
                      item,
                      fit: BoxFit.contain,
                      enableSlideOutPage: true,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (state) {
                        var initialScale = 1.0;

                        if (state.extendedImageInfo != null &&
                            state.extendedImageInfo?.image != null) {
                          initialScale = _initalScale(
                              size: Size(
                                  constraints.maxWidth, constraints.maxHeight),
                              initialScale: initialScale,
                              imageSize: Size(
                                  state.extendedImageInfo?.image.width
                                      .toDouble()??0,
                                  state.extendedImageInfo?.image.height
                                      .toDouble()??0));
                        }
                        return GestureConfig(
                            inPageView: true,
                            initialScale: initialScale,
                            maxScale: max(initialScale, 5.0),
                            animationMaxScale: max(initialScale, 5.0),
                            //you can cache gesture state even though page view page change.
                            //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                            cacheGesture: false);
                      },
                      onDoubleTap: (ExtendedImageGestureState state) {
                        var pointerDownPosition = state.pointerDownPosition;
                        var begin = state.gestureDetails?.totalScale;
                        double end;

                        //remove old
                        _animation?.removeListener(animationListener!);

                        //stop pre
                        _animationController?.stop();

                        //reset to use
                        _animationController?.reset();

                        if (begin == doubleTapScales[0]) {
                          end = doubleTapScales[1];
                        } else {
                          end = doubleTapScales[0];
                        }

                        animationListener = () {
                          //print(_animation.value);
                          state.handleDoubleTap(
                              scale: _animation?.value,
                              doubleTapPosition: pointerDownPosition);
                        };
                        _animation = _animationController
                            ?.drive(Tween<double>(begin: begin, end: end));

                        _animation?.addListener(animationListener!);

                        _animationController?.forward();
                      },
                    );

                    return image;
                  },
                  itemCount: widget.pics.length,
                  onPageChanged: (int index) {
                    currentIndex = index;
                    rebuildIndex.add(index);
                  },
                  controller: ExtendedPageController(initialPage: currentIndex??0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  //physics: ClampingScrollPhysics(),
                ),
                StreamBuilder<bool>(
                  builder: (c, d) {
                    if (d.data == null || d.hasError) return Container();

                    return Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: MySwiperPlugin(
                          widget.pics, currentIndex!, rebuildIndex),
                    );
                  },
                  initialData: true,
                  stream: rebuildSwiper.stream,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  double _initalScale({Size? imageSize, Size? size, double? initialScale}) {
    var n1 = int.parse(imageSize?.height.toString()??'0') / int.parse(imageSize?.width.toString()??'0');
    var n2 = int.parse(size?.height .toString()??'0')/ int.parse(size?.width .toString()??'0');
    if (n1 > n2) {
      final fittedSizes = applyBoxFit(BoxFit.contain, imageSize??const Size(2, 2), size??const Size(2, 2));
      //final Size sourceSize = fittedSizes.source;
      var destinationSize = fittedSizes.destination;
      return int.parse(size?.width .toString()??'0')/ destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final fittedSizes = applyBoxFit(BoxFit.contain, imageSize??const Size(2, 2), size??const Size(2, 2));
      //final Size sourceSize = fittedSizes.source;
      var destinationSize = fittedSizes.destination;
      return int.parse(size?.height.toString()??'0') / destinationSize.height;
    }

    return initialScale??0;
  }
}

class MySwiperPlugin extends StatelessWidget {
  final List<PicSwiperItem> pics;
  final int index;
  final StreamController<int> reBuild;

  const MySwiperPlugin(this.pics, this.index, this.reBuild);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, data) {
        return DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Container(
            height: 50.0,
            width: double.infinity,
            color: Colors.black87,
            child: Row(
              children: <Widget>[
                Container(
                  width: 10.0,
                ),
                Text(
                  '${data.data !+ 1}',
                ),
                Text(
                  ' / ${pics.length}',
                ),
                Expanded(
                    child: Text(pics[int.parse(data.data.toString())].des,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white))),
                Container(
                  width: 10.0,
                ),
              ],
            ),
          ),
        );
      },
      initialData: index,
      stream: reBuild.stream,
    );
  }
}
