import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'sizeConfig.dart';

Widget sBox({h = 0, w = 0}) {
  return h == 0
      ? SizedBox(width: SizeConfig.blockSizeHorizontal! * w)
      : SizedBox(height: SizeConfig.safeBlockVertical! * h);
}

int index = 0;
TargetFocus targetFocus(
    {key,
    identifier,
    text,
    circle = false,
    controller,
    List? targets,
    Function? func}) {
  return TargetFocus(
    identify: identifier,
    keyTarget: key,
    shape: circle ? ShapeLightFocus.Circle : ShapeLightFocus.RRect,
    alignSkip: Alignment.bottomRight,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        builder: (context, controller) {
          return Container(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                sBox(h: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (index < targets!.length - 1)
                      GestureDetector(
                        onTap: () => controller.skip(),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    sBox(w: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, foregroundColor: Colors.black),
                      onPressed: () {
                        controller.next();
                        index++;
                      },
                      child: Text(
                        index >= targets.length - 1 ? 'Done' : 'Next',
                        style: const TextStyle(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    ],
  );
}
