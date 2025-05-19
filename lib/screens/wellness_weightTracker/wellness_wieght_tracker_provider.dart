import 'dart:convert' as convert;
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../env.dart';
import 'wellness_weight_tracker_model.dart';

class WellnessWeightTrackerProvider with ChangeNotifier {
  WeightTrackingModel? weightTrackingModel;

  Future<bool> setHeightWeight(
      {String? userId, num? height, num? weight}) async {
    try {
      // var data = <MonthlyProgressImages>[];
      var uri = Uri.parse('$apiUrl/progress/setHeightWeight');
      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
            'height': height,
            'weight': weight,
          }),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('SETHEIGHTANDWEIGHTISDONE');
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      notifyListeners();
      return true;
    }
  }

  Future getWeightData(String? userId) async {
    weightTrackingModel = null;
    try {
      var uri = Uri.parse('$apiUrl/progress/getWeightHistory');

      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
            // 'type': type,
          }),
          headers: {'Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      log('this is my status code in wieght  ${response.statusCode}}');
      if (response.statusCode != 200 || response == null) {
        return 'error';
      }
      if (response.statusCode == 200) {
        log('this is my data in wieght ${body['data']}');
        weightTrackingModel = WeightTrackingModel.fromJson(body);
        log('this is my data bmi ${weightTrackingModel!.data!.bmi}}');
        notifyListeners();
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          notifyListeners();
          throw Exception(error[0]);
        } else {
          notifyListeners();
          throw Exception('Cannot fetch data');
        }
      }
    } catch (e) {
      notifyListeners();
    }
  }
}
