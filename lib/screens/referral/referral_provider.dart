import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fstore/screens/referral/Model/referralBal_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'referral_code_model.dart';

class ReferralProvider with ChangeNotifier {
  ReferralCodeModel? referralCodeModel;
  int statusCode = 0;
  ReferralBalModel? referralBalModel;
  var shopifyUserId;
  bool phoneLength = false;

  var userPhone = '';

  Future createReferral({required String customerId}) async {
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/113.0',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate, br',
      'Content-Type': 'application/json',
      'Referer': 'https://ghc.health/',
      'Origin': 'https://ghc.health',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
      'Connection': 'keep-alive',
      'TE': 'trailers'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://s0huf507n4.execute-api.ap-south-1.amazonaws.com/production-mars/referral/createReferral'));
    request.body = json.encode({'customer_id': customerId.toString()});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      referralCodeModel = ReferralCodeModel.fromJson(
          json.decode(await response.stream.bytesToString()));
      return referralCodeModel!;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future updatePhoneNumber(
      {required String customerId, required String phoneNumber}) async {
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/113.0',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate, br',
      'Content-Type': 'application/json',
      'Referer': 'https://ghc.health/',
      'Origin': 'https://ghc.health',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
      'Connection': 'keep-alive',
      'TE': 'trailers'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://s0huf507n4.execute-api.ap-south-1.amazonaws.com/production-mars/shopify-user/updateData'));
    request.body = json.encode({
      'customer': customerId.toString(),
      'phoneNumber': phoneNumber.toString()
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('this is updated phone number' +
          await response.stream.bytesToString());
    } else {
      print('Error in updatd  phone number  ${response.reasonPhrase}');
    }
    notifyListeners();
  }

  Future getReferralBal({required String customerID}) async {
    print('it is ferching');
    var headers = {
      'User-Agent':
          'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/113.0',
      'Accept': 'application/json, text/plain, /',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate, br',
      'Content-Type': 'application/json',
      'Referer': 'https://ghc.health/',
      'Origin': 'https://ghc.health',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
      'Connection': 'keep-alive',
      'TE': 'trailers'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://s0huf507n4.execute-api.ap-south-1.amazonaws.com/production-mars/referral/checkBalance'));
    request.body = json.encode({'customer_id': customerID.toString()});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      referralBalModel = ReferralBalModel.fromJson(
          json.decode(await response.stream.bytesToString()));
      print('this is my data coming ${referralBalModel?.body?.balance}');
    } else {
      print('is there any error ');
      print(response.reasonPhrase);
    }
    notifyListeners();
  }

  Future redeemMoons(
      {required String customerId,
      required int moons,
      required String brand,
      required int PhoneNumber,
      required String email,
      required String name}) async {
    var url =
        'https://s0huf507n4.execute-api.ap-south-1.amazonaws.com/production-mars/referral/redeem';
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode({
      'customer_id': customerId.toString(),
      'redeem': moons,
      'brand': 'mars',
      'phone': PhoneNumber,
      'email': email,
      'name': name
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await getReferralBal(customerID: customerId);
    } else {
      print(response.reasonPhrase);
    }

    // var body = {
    //   "customer_id": customerId.toString(),
    //   "redeem": moons,
    //   "brand": "mars",
    //   "phone": PhoneNumber,
    //   "email": email,
    //   "name": name
    // };
    // var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    //
    // if (response.statusCode == 200) {
    //
    // } else {
    //   var message = jsonDecode(response.body);
    //   Get.snackbar('Error', message['error']);
    // }
  }

  Future getUserPhone({required String customerId}) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://s0huf507n4.execute-api.ap-south-1.amazonaws.com/production-mars/shopify-user/getUserPhone'));
    request.body = json.encode({'customer_id': customerId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String? data = await response.stream.bytesToString();
      userPhone = data.replaceAll('"', '');
    } else {
      userPhone = '';
      print(response.reasonPhrase);
    }
    notifyListeners();
  }
}
