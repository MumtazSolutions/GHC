import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  final String path;

  const ImageDialog({super.key, required this.path});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Image.network(
        path,
        fit: BoxFit.cover,
      ),
    );
  }
}
