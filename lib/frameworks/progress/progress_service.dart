import 'dart:async';
import 'dart:convert' as convert;
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../common/constants.dart';
import '../../env.dart';
import '../../models/entities/monthly_progress_images.dart';
import '../../models/progress/weight_tracker_model.dart';
import '../../screens/skin_tracker/skin_tracker_model.dart';

class ProgressService {
  Future fetchMonthlyImages(String? userId, String? type) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/fetchAllImages');

      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
            'type': type,
          }),
          headers: {'Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        printLog('fetchAllImages API called successfully');
        return ProgressTracker.fromJson(body, type);
      }
      if (response.statusCode != 200 || response == null) {
        printLog('error in fetchAllImages API');
        return 'error';
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Cannot fetch images');
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  // store pic api
  Future<String> addNewprogress(
      File file, String? userId, String? type, String? weight) async {
    try {
      printLog('Uploading Image');
      var uri = Uri.parse('$apiUrl/progress/upload');

      var request = http.MultipartRequest("POST", uri);
      var stream =
          http.ByteStream(DelegatingStream.typed(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: basename(file.path));

      request.files.add(multipartFile);

      var response = await http.Response.fromStream(await request.send());
      printLog(response.statusCode);
      final jsonData = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        printLog(jsonData['data']);
        return jsonData['data'];
      } else {
        throw Exception('Cannot Upload Image');
      }
    } catch (e) {
      printLog(e.toString());
      return '';
    }
  }

  Future<bool> uploadPics(
      {String? userId,
      String? type,
      String? frontImage,
      String? topImage}) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/v2/create');
      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
            'type': type,
            'top': topImage,
            'front': frontImage,
          }),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      log(body['data']);
      return true;
    } catch (e) {
      printLog(e.toString());
      return false;
    }
  }

  Future<bool> checkForValidUploadDate(String? userId, String? type) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/isValidDate');
      var response = await http.post(uri,
          body: convert.jsonEncode({'user': userId, 'type': type}),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      printLog(body['data']);
      return body['data'];
    } catch (e) {
      printLog(e.toString());
      return true;
    }
  }

  // This API is to fetch progress categories Beard, Weight Loss, Hair and Skin
  Future<List> fetchProgressCategories() async {
    try {
      var uri = Uri.parse('$apiUrl/progressCategory/fetchCategories');
      var response =
          await http.get(uri, headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      log('Progress categories fetched successfully');
      return body['data'];
    } catch (e) {
      printLog('error in fetchCategories API:${e.toString()}');
      return [];
    }
  }

  Future getWeightData(String? userId) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/getWeightHistory');

      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
          }),
          headers: {'Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode != 200 || response == null) {
        return 'error';
      }
      if (response.statusCode == 200) {
        return WeightTrackerModel.fromJson(body['data']);
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Cannot fetch data');
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  ///----------------------
  /// weight tracker apis ///
  ///----------------------

// intial upload of weight and height
  Future<bool> setHeightWeight(
      {String? userId, num? height, num? weight}) async {
    try {
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
        printLog('setHeightWeight API called successfully');
        return true;
      } else {
        printLog(body['data']);
        return false;
      }
    } catch (e) {
      printLog(e.toString());
      return true;
    }
  }

//set weight goal
  Future<bool> setWeightGoal(
      {String? userId, num? timeline, num? weightGoal}) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/setWeightGoal');
      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
            'weight': weightGoal,
          }),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      printLog('setWeightGoal API called successfully');
      return body['data'];
    } catch (e) {
      printLog(e.toString());
      return true;
    }
  }

// daily update of weight
  Future<bool> createWeight({String? userId, num? weight}) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/v2/create');
      var response = await http.post(uri,
          body:
              '{"user":"$userId","type":"Weight Loss","measurements":{"weight":"$weight"}}',
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      printLog(body['data']);
      return body['data'];
    } catch (e) {
      printLog(e.toString());
      return true;
    }
  }

  ///----------------------
  /// skin tracker apis ///
  ///----------------------

  Future<List> getUserSkinHistory(String userId) async {
    var uri = Uri.parse('$apiUrl/progress/getUserGoal/$userId');
    var response = await http.get(uri);
    final body = convert.jsonDecode(response.body);
    if (response.statusCode != 200 || response == null) {
      print('Returning error in User Skin History');
      return ([]).cast<Conditions>();
    }
    if (response.statusCode == 200) {
      print('Succefully fetched user progress History ');
      var cList = <Conditions>[];

      body['data']['skinGoalHistory']['conditions'].forEach((c) {
        cList.add(Conditions.fromJson(c));
      });
      return cList;
    } else {
      List error = body['error'];
      if (error != null && error.isNotEmpty) {
        throw Exception(error[0]);
      } else {
        throw Exception('Cannot fetch data');
      }
    }
  }

  Future getSkinData(String? userId, type) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/getSkinDataV2');

      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
          }),
          headers: {'Content-Type': 'application/json'});

      final body = convert.jsonDecode(response.body);
      if (response.statusCode != 200 || response == null) {
        return 'error';
      }

      if (response.statusCode == 200) {
        print('Fetched Skin Images');
        var sData = ProgressTracker.fromJson(body, type);
        return sData;
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Cannot fetch data');
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  Future returnSkinData(String? userId, type) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/getSkinDataV2');

      var response = await http.post(uri,
          body: convert.jsonEncode({
            'user': userId,
          }),
          headers: {'Content-Type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode != 200 || response == null) {
        printLog('error in getSkinDataV2 API');
        return 'error';
      }

      if (response.statusCode == 200) {
        printLog('getSkinDataV2 API called successfully');
        return SkinTrackerModel.fromJson(body, type);
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Cannot fetch data');
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  Future<List> returnGoalsAndConditions() async {
    try {
      var uri = Uri.parse('$apiUrl/progressCategory/getGoalOptionsByCategory');
      var response = await http.get(uri);
      printLog(response.statusCode);
      printLog(response.body);
      final body = convert.jsonDecode(response.body);
      printLog(response.statusCode);
      if (response.statusCode != 200 || response == null) {
        printLog('Returning error in fetching conditions and goals ');
        return ['error'];
      }

      if (response.statusCode == 200) {
        printLog('Fetched all the Goals And Conditions');
        var cList = <Conditions>[];
        var gList = <Goals>[];

        body['data']['goals'].forEach((goal) {
          gList.add(Goals.fromJson(goal));
        });
        body['data']['conditions'].forEach((goal) {
          cList.add(Conditions.fromJson(goal));
        });

        return [cList, gList];
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Cannot fetch data');
        }
      }
    } catch (e) {
      printLog(e.toString());
      return [];
    }
  }

  Future<bool> addConditionsGoals(
      {String? userId, List? conditions, List? goals, String? type}) async {
    try {
      var uri = Uri.parse('$apiUrl/progress/setUserGoal');
      printLog(convert.jsonEncode({
        'userId': userId,
        'type': type,
        'conditions': conditions,
        'goals': goals,
      }));
      var response = await http.patch(uri,
          body: convert.jsonEncode({
            'userId': userId,
            'type': type,
            'conditions': conditions,
            'goals': goals,
          }),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('successfully added points and goals');
      } else {
        print(body['data']);
      }
      return true;
    } catch (e) {
      printLog(e.toString());
      return true;
    }
  }
}
