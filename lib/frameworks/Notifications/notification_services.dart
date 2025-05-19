import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

import '../../common/constants.dart';
import '../../env.dart';
import '../../models/entities/index.dart';
import '../../models/index.dart';

class NotificationServices {
  Future<void> CreateDevice(String deviceToken) async {
    try {
      var uri = Uri.parse('${apiUrl}device/createDevice');
      var response = await http.post(uri,
          body: convert.jsonEncode({'deviceId': deviceToken}),
          headers: {'content-type': 'application/json'});
      if (response.statusCode == 200) {
        printLog('Device Saved');
      } else if (response.statusCode == 400) {
        printLog('Device Already Saved');
      } else {
        printLog('Cannot Save Device');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> SaveUser(String deviceToken, User user) async {
    try {
      printLog('Saving Device and user details');
      var uri = Uri.parse('$apiUrl/device/saveUserDetails');
      var response = await http.post(uri,
          body: convert.jsonEncode({
            'deviceToken': deviceToken,
            'firstName': user.firstName,
            'lastName': user.lastName,
            'userId': user.id
          }),
          headers: {'content-type': 'application/json'});
      if (response.statusCode == 200) {
        printLog('User Details Saved');
      } else {
        throw Exception('Cannot save user details');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> UpdateUser(List topics, User user) async {
    try {
      printLog('Updating Device and user details');
      var uri = Uri.parse('${apiUrl}device/updateUserTopics');
      LocalStorage storage = LocalStorage('fstore');
      var token = await storage.getItem('token');
      var response = await http.patch(uri,
          body: convert.jsonEncode(
              {'topics': topics, 'token': token, 'userId': user.id}),
          headers: {'content-type': 'application/json'});
      if (response.statusCode == 200) {
        printLog('User Details updated');
      } else {
        throw Exception('Cannot update user details');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> UpdateCart(List items, User user) async {
    try {
      printLog('Updating Items in cart to the backend');
      var uri = Uri.parse('${apiUrl}device/updateCart');
      LocalStorage storage = LocalStorage('fstore');
      var token = await storage.getItem('token');
      var response = await http.post(uri,
          body: convert.jsonEncode({'items': items, 'token': token}),
          headers: {'content-type': 'application/json'});
      if (response.statusCode == 200) {
        printLog('cart updated');
      } else {
        throw Exception('Cannot update cart');
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> removeDevice(User user) async {
    try {
      printLog('Updating Items in cart to the backend');
      var uri = Uri.parse('${apiUrl}device/removeUserFromDevice');
      LocalStorage storage = LocalStorage('fstore');
      var token = await storage.getItem('token');
      printLog(token);
      var response = await http.post(uri,
          body: convert.jsonEncode({'userId': user.id, 'token': token}),
          headers: {'content-type': 'application/json'});
      if (response.statusCode == 200) {
        printLog('device deleted');
      } else {
        throw Exception('Cannot delete device');
      }
    } catch (e) {
      printLog(e);
    }
  }
}
