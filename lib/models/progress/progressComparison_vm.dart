import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../env.dart';
import '../user_model.dart';

class ProgressComparisonVm with ChangeNotifier {
  Future collectFeedback(
      String feedback,
      BuildContext context,
      var rating,
      var categoryType,
      var weeks,
      var image1,
      var image2,
      var image1Date,
      var image2Date) async {
    var userID = Provider.of<UserModel>(context, listen: false);
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse('${apiUrl}progress/feedback'));
    request.body = json.encode({
      'userId': userID.user!.id,
      'feedback_comment': feedback,
      'feedback_rating': rating,
      'category_name': categoryType,
      'image1': image1,
      'image2': image2,
      'no_of_weeks': weeks,
      'image1_date': image1Date.toString(),
      'image2_date': image2Date.toString()
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('feedback api success');
      // print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
