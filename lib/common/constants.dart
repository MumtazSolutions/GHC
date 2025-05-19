import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../generated/l10n.dart';
import '../models/index.dart' show ProductVariation;
import '../services/dependency_injection.dart';
import '../services/service_config.dart';
import 'common_widgets.dart';
import 'config.dart';
import 'sizeConfig.dart';

export 'package:inspireui/extensions.dart';
export 'package:inspireui/inspireui.dart' show printLog, eventBus;
export 'package:inspireui/utils.dart';

export 'theme/colors.dart';

part 'constants/date_time_format_constants.dart';
part 'constants/events.dart';
part 'constants/general.dart';
part 'constants/icons.dart';
part 'constants/images.dart';
part 'constants/layouts.dart';
part 'constants/loading.dart';
part 'constants/local_storage_key.dart';
part 'constants/route_list.dart';
part 'constants/slider.dart';
part 'constants/vendors.dart';
Column circularMarker({value, text, context}) {
  return Column(children: [
    SizedBox(
      height: SizeConfig.blockSizeVertical !* 7,
      width: SizeConfig.blockSizeVertical !* 7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: double.parse(value.toString()) / 100,
            strokeWidth: 14,
            backgroundColor: const Color(0xff145986),
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 19.0,
                color: Color(0xff145986),
              ),
            ),
          )
        ],
      ),
    ),
    sBox(h: 2),
    Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Color.fromRGBO(11, 72, 112, 1),
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    )
  ]);
}


Column circularHealthMarker({value, text, context}) {
  return Column(children: [
    SizedBox(
      height: SizeConfig.blockSizeVertical !* 10,
      width: SizeConfig.blockSizeVertical !* 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: double.parse(value.toString()) / 100,
            strokeWidth: 14,
            backgroundColor: const Color(0xff145986),
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 19.0,
                color: Color(0xff145986),
              ),
            ),
          )
        ],
      ),
    ),
    sBox(h: 2),
    // Text(
    //   text,
    //   textAlign: TextAlign.left,
    //   style: TextStyle(
    //     color: Color.fromRGBO(11, 72, 112, 1),
    //     fontFamily: 'Roboto',
    //     fontSize: 16,
    //     fontWeight: FontWeight.normal,
    //   ),
    // )
  ]);
}
