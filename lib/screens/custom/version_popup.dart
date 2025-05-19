// ignore_for_file: unused_local_variable, unused_field, unused_import, prefer_const_constructors, unnecessary_new, avoid_print, sized_box_for_whitespace, prefer_const_constructors_in_immutables, unused_element, unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatefulWidget {
  UpdateDialog({Key? key}) : super(key: key);

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: Container(
            height: h / 1.5,
            decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xffffff),
                borderRadius: new BorderRadius.all(new Radius.circular(32.0))),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox(width: 5),
                  const SizedBox(height: 10),
                  Center(
                    child: Image.asset('assets/images/versionUpdatePopup.png',
                        height: 120, width: 120),
                  ),
                  const SizedBox(height: 10),
                  Center(
                      child: Text(
                    'Time to Update!',
                    style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 15),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        'We have added some new\n features and made a few bug\n fixes to make your experience\n as smooth as possible. Please\n update to the latest version to proceed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            height: 1.4,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 45.0,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                minimumSize: Size(0, 50),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  //to set border radius to button
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                // LaunchReview.launch(
                                //   androidAppId: 'com.ghc.marsapp',
                                //   writeReview: false,
                                // );
                                StoreRedirect.redirect(
                                  androidAppId: 'com.ghc.marsapp',
                                );
                              },
                              child: Text(
                                'Update',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
