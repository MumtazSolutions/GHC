import 'package:flutter/material.dart';
import 'package:fstore/common/constants.dart';
import 'package:fstore/routes/flux_navigate.dart';
import 'package:fstore/screens/progress/progress_image.dart';
import 'package:intl/intl.dart';

class ProgressImagesMonthly extends StatefulWidget {

  List?  monthlyImages = [];
  ProgressImagesMonthly ({ Key? key, this.monthlyImages }): super(key: key);

  @override
  ProgressImagesMonthlyState createState() => ProgressImagesMonthlyState();
}


class ProgressImagesMonthlyState extends State<ProgressImagesMonthly> {

  List progressImages = [];

  List<Widget> _monthlyImages(List images) {
    List<Widget> _images = List<Widget>.generate(images.length, (int index) {
      return GestureDetector(
        onTap: () {
          FluxNavigate.pushNamed(
              RouteList.weeklyprogress,
              arguments: images[index].images,
            );
        },
        child: images.isNotEmpty==true ?  ProgressImage(
          img_location: images[index].images[0].file,
          img_month: index,
          img_caption: DateFormat('dd-MM-yyyy').format(images[index].images[0].date).toString(),
        ) : Container(),
      );
    } );
    return _images;
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _monthlyImages(widget.monthlyImages!),
      ),
    );
  }
  
}