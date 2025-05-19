import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProgressImage extends StatelessWidget {
  final String? img_location;
  final int? img_month;
  final String? img_caption;

  const ProgressImage({this.img_location, this.img_month, this.img_caption});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
          child: SizedBox(
        width: 161,
        height: 121,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            filterQuality: FilterQuality.low,
            height: 121,
            
            imageUrl: img_location!,
            imageBuilder: (context, imageProvider) {
              return Image(
                height: 121,
                width: 161,
                image: imageProvider,
                fit: BoxFit.fitWidth,
              );
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
            // placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      )
          // child: Container(
          //   // height: 121,
          //   // width: 161,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       Text(
          //         'Month' + ' ' + (img_month + 1).toString(),
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 15,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //       SizedBox(height: 10),
          //       Container(
          //         width: 161,
          //         height: 121,
          //         child: ClipRRect(
          //           borderRadius: BorderRadius.circular(5),
          //           child: CachedNetworkImage(
          //             imageUrl: img_location,
          //             imageBuilder: (context, imageProvider) {
          //               return Image(
          //                 height: 121,
          //                 width: 161,
          //                 image: imageProvider,
          //                 fit: BoxFit.cover,
          //               );
          //             },
          //             progressIndicatorBuilder:
          //                 (context, url, downloadProgress) => Container(
          //               height: 50,
          //               width: 50,
          //               child: Center(
          //                 child: CircularProgressIndicator(
          //                     value: downloadProgress.progress),
          //               ),
          //             ),
          //             // placeholder: (context, url) => const CircularProgressIndicator(),
          //             errorWidget: (context, url, error) =>
          //                 const Icon(Icons.error),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          ),
    );
  }
}
