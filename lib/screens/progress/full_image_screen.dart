import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class FullImageView extends StatelessWidget {
  final image;

  FullImageView(this.image);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Week ${image['index'] + 1}',
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Center(
              child: Column(children: [
            Expanded(
                child: Hero(
                    tag: 'imageHero${image['index']}',
                    child: PhotoView(
                        imageProvider: CachedNetworkImageProvider(image['src']))
                    // child: PhotoView(
                    //   child: CachedNetworkImage(
                    //     imageUrl: image['src'],
                    //     imageBuilder: (context, imageProvider) {
                    //       return Image(
                    //         height: MediaQuery.of(context).size.height - 100,
                    //         width: MediaQuery.of(context).size.width,
                    //         image: imageProvider,
                    //         fit: BoxFit.cover,
                    //       );
                    //     },
                    //     placeholder: (context, url) =>
                    //         const CircularProgressIndicator(),
                    //     errorWidget: (context, url, error) => const Icon(Icons.error),
                    //   ),
                    // ),
                    ))
          ]))),
    );
  }
}