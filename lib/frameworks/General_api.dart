import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../common/constants.dart';
import '../env.dart';

class GeneralApis {
  Future pincodeCheck({String? pincode, List? products}) async {
    try {
      var uri = Uri.parse('$apiUrl/device/pincode');
      final data =
          '{"pincode": "$pincode", "brand":"Mars", "products": ${products?.map((e) => e).toList()}}';
      print(data);
      var response = await http
          .post(uri, body: data, headers: {'Content-Type': 'application/json'});
      print(response.statusCode);
      print(response.body);
      final body = convert.jsonDecode(response.body);
      print(response.statusCode);
      if (response.statusCode != 200 || response == null) {
        print('Returning error in device pincode');
        return 'error';
      }

      if (response.statusCode == 200) {
        return body['message'];
      } else {
        return body;
      }
    } catch (e) {
      printLog(e.toString());
    }
  }
}
