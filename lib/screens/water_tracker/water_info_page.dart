import 'package:flutter/material.dart';
import '../../common/common_widgets.dart';

class WaterInfoPage extends StatelessWidget {
  const WaterInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 50,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ideal water intake',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            sBox(h: 2),
            Image.asset('assets/images/waterInfo.png'),
            sBox(h: 2),
            Image.asset('assets/images/waterTip1.png'),
          ],
        )));
  }
}
