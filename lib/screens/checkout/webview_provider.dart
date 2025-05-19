import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WebViewProvider with ChangeNotifier {
  Future createWalletCashback({
    required String customerId,
    required double orderSubtotalPrice,
    required int orderNumber,
  }) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://s0huf507n4.execute-api.ap-south-1.amazonaws.com/production-mars/referral/createWalletCashback'));
    request.body = json.encode({
      'customer_id': int.parse(customerId),
      'order_subtotal_price': orderSubtotalPrice,
      'order_number': orderNumber
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('this is m checkout response' +
          await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
