import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../env.dart';
import 'water_tracker_model.dart';

class WaterTrackerProvider with ChangeNotifier {
  WaterTrackerModel? waterTrackingModel;
  bool isLoading = false;

  Future getUserWaterData(String? userId) async {
    waterTrackingModel = null;
    var uri = Uri.parse('$apiUrl/progress/getWaterTracker');

    var response = await http.post(uri,
        body: convert.jsonEncode({
          'user': userId,
        }),
        headers: {'Content-Type': 'application/json'});
    print(response.body);
    final body = convert.jsonDecode(response.body);

    if (response.statusCode != 200 || response == null) {
      print('Returning error in water data');
      notifyListeners();
    }

    if (response.statusCode == 200 && body['data'] != null) {
      waterTrackingModel = WaterTrackerModel.fromJson(body);
      print('Fetched user Water Data');
      notifyListeners();
    }
    notifyListeners();
  }

  Future addGlass({int? glasses, String? userId, DateTime? date}) async {
    var formattedDate = DateFormat('dd-M-yyyy').format(date!);
    var uri = Uri.parse('$apiUrl/progress/waterIntake');
    var response = await http.post(uri,
        body: convert.jsonEncode(
            {'user': userId, 'waterIntake': glasses, 'date': formattedDate}),
        headers: {'Content-Type': 'application/json'});
    print(response.statusCode);
    final body = convert.jsonDecode(response.body);

    if (response.statusCode != 200 || response == null) {
      print('Returning error in adding glass ');
      return 'error';
    }

    if (response.statusCode == 200) {
      print('Added glass for today');
    }
  }

  Future setWaterGoal(
      {int? goalGlasses, String? userId, int? overIntake, num? weight}) async {
    var uri = Uri.parse('$apiUrl/progress/setWaterGoal');

    var response = await http.patch(uri,
        body: convert.jsonEncode({
          'userId': userId,
          'goalGlasses': goalGlasses,
          'weight': weight,
          'overIntake': overIntake
        }),
        headers: {'Content-Type': 'application/json'});
    print(response.statusCode);
    final body = convert.jsonDecode(response.body);

    if (response.statusCode != 200 || response == null) {
      print('Returning error in setting water goal');
      return false;
    }

    if (response.statusCode == 200) {
      print('Successfully set water goal');
      return true;
    }
  }
}
