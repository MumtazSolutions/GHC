import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import '../../env.dart';
import 'sleep_tracking_model.dart';

class SleepTrackerProvider with ChangeNotifier {
  SleepTrackingModel? sleepTrackingModel;
  bool isLoading = false;
  bool bedTime = false;

  Future setSleepGoal(
      {required String userID,
      required int sleepGoal,
      required int overSleep,
      required int sleepLessNess}) async {
    isLoading = true;
    notifyListeners();
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('PATCH', Uri.parse('$apiUrl/progress/setSleepGoal'));
    request.body = convert.json.encode({
      'userId': userID,
      'sleepGoal': sleepGoal,
      'oversleep': overSleep,
      'sleeplessness': sleepLessNess
    });
    request.headers.addAll(headers);

    var response = await request.send();

    if (response.statusCode == 200) {
      log('success your goal has been saved');
      isLoading = false;
      notifyListeners();
    } else {
      log('failed to save your goal');
      isLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  Future getSleepData({required String userID}) async {
    // isLoading = true;
    // notifyListeners();
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('$apiUrl/progress/getSleepTracker'));
    request.body = convert.json.encode({'userId': userID});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    http.Response convertedResponse = await http.Response.fromStream(response);
    String responseBody = convertedResponse.body;
    final body = convert.jsonDecode(responseBody);

    if (response.statusCode == 200 && body['data'] != null) {
      sleepTrackingModel = SleepTrackingModel.fromJson(body);
      notifyListeners();
    } else {
      log('failed to get sleep data');
      // isLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  Future setBedTime(
      {required String userID,
      required DateTime dateTime,
      required bool bedTime}) async {
    String formattedDate = DateFormat('dd-MM-yy').format(dateTime);

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse('$apiUrl/progress/setBedTime'));
    request.body = jsonEncode({
      'userId': userID,
      'date': formattedDate,
      'bedTime': bedTime.toString()
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
      notifyListeners();
    }

    notifyListeners();
  }
}
