import 'dart:ui';
import 'package:flutter/material.dart';

class OverlayLoader extends StatelessWidget {
  const OverlayLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: const Opacity(
          opacity: 00,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
      ),
    );
  }
}
