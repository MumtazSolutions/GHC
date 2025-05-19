import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../../common/config.dart';
import '../../env.dart';
import 'answers_model.dart';
import 'categories_model.dart';
import 'get_following_model.dart';
import 'get_profile-model.dart';
import 'topicpost_model.dart';
import 'user_posts_model.dart';
import 'user_topics_model.dart';

class CommunityProvider with ChangeNotifier {
  Map<String, dynamic> categories = {};
  CategoriesModel questionModel = CategoriesModel();
  AnswersModel answersModel = AnswersModel();
  GetProfileModel getProfileModel = GetProfileModel();
  UserTopicsModel userTopics = UserTopicsModel();
  UserPostsModel userPosts = UserPostsModel();
  GetFollowingModel getFollowingModel = GetFollowingModel();
  CategoriesModel userTopicsModel = CategoriesModel();
  bool isinitialLoading = false;

  var userId;
  bool isLoading = false;
  List<String> filters = ['All', 'Questions', 'Your Questions', 'Latest'];
  int selectedindex = 0;
  String userSlug = '';
  List getPosts = [];
  List getTopics = [];
  List getAll = [];
  List<TopicPost> getAllData = [];
  String userName = '';
  String aboutMe = '';
  String userToken = '';
  String imgLink = '';

  Future fetchCategories() async {
    var url = Uri.parse('${Configurations.baseUrl}/api/categories');
    var headers = {
      'Cookie':
          'express.sid=s%3AefBNjipue0z5ZoO-xXyyLQ6UhlRugvK-.noP0iQvrt5P74%2BTMQYXpEXqbtMPw0dqzHtny05%2F%2FzdI; express.sid=s%3A8cuKA7u00oxGmQkxsFLEQ7WhNj9NMOjE.f5a5BtmU59OqRju9GQP9kYn794blhxV%2F0DQWhbdQAQ0; express.sid=s%3Ae19ufmtLNpUnFYQxCgW3JHuGMStBqGvD.eH3Dqh7y9pT3UR3Ei%2B6Zg1MTyzwMnLYl8jN6o7Vkt0U; express.sid=s%3A2208DNVPKyR8qTR74ZNNBcI8ZonTWjEf.TSGXU8Hnx9dPHBkEKx3Dyn3%2BBzXOKogyzW7xTSCo6a0'
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      categories = jsonDecode(response.body);
      return categories;
    } else {
      if (kDebugMode) {
        print('this is error here right in community provider');
        print(response.reasonPhrase);
      }
      notifyListeners();
    }
  }

  Future<CategoriesModel> fetchQuestion({int page = 1}) async {
    var headers = {
      'Cookie':
          'express.sid=s%3Ae19ufmtLNpUnFYQxCgW3JHuGMStBqGvD.eH3Dqh7y9pT3UR3Ei%2B6Zg1MTyzwMnLYl8jN6o7Vkt0U; express.sid=s%3A4w-YeON4Jka801rKukEeVxURfWlCPyyB.hCTYkCoV%2FrBMNyPkYOUtw7lkHfAdzqrN37c6d20j7nk'
    };
    var url =
        Uri.parse('${Configurations.baseUrl}/api/recent?lang=en-GB&page=$page');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      questionModel = CategoriesModel.fromJson(jsonDecode(response.body));

      return questionModel;
    } else {
      print(response.reasonPhrase);
      return questionModel;
    }
  }

  Future askQuestion(
      {required int cid,
      required String question,
      required List<String> tags,
      String? path,
      File? file}) async {
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    };

    var url = Uri.parse('${Configurations.baseUrl}/api/v3/topics');
    var body = json.encode({
      'cid': cid,
      'title': question,
      'content': 'Content not required',
      'tags': tags
    });

    var response = http.post(
      url,
      headers: headers,
      body: body,
    );

    await response
          .then(
            (value) => {
              notifyListeners(),
            },
          )
          .catchError(
            (onError) => {
              notifyListeners(),
              throw HttpException(onError)
            },
          );
  }

  Future askQuestionProduct(
      {required int cid,
      required String question,
      required List<String> tags,
      String? path,
      File? file}) async {
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
      'Cookie':
          'express.sid=s%3A6xviNXO-nEZLR9rSmdGNOGv-n_UeeWk2.oGc1MFWIHIneOsGd1gBNeDTzRKcvCiSJ3kAmaTJC0EI; express.sid=s%3A4w-YeON4Jka801rKukEeVxURfWlCPyyB.hCTYkCoV%2FrBMNyPkYOUtw7lkHfAdzqrN37c6d20j7nk'
    };
    var request = http.Request(
        'POST', Uri.parse('${Configurations.baseUrl}/api/v3/topics'));
    request.body = json.encode({
      'cid': cid,
      'title': question,
      'content': 'content not required',
      'tags': tags
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = jsonDecode(await response.stream.bytesToString());
      print(data['response']['tid']);
      if (path != null || path?.isEmpty == true) {
        // await uploadImage(path: path!  ,tid: data['response']['tid']);
      }
      print('question posted successfulyy');

      notifyListeners();
    } else {
      print(response.reasonPhrase);
      notifyListeners();
    }
  }

  Future uploadQuestionImage(
      {required String path, required int tid, required File img}) async {
    try {
      var headers = {
        'Authorization': 'Bearer $userToken',
        'Cookie':
            'express.sid=s%3At02j3cnjNOUR2P6N5S91ggd-TBtVTlYZ.KvySaRj8cGYpzpcUimKuKughrqxC6OWoc349p1H07HA; express.sid=s%3AIaR8GjfRS407Mv21oQZWRxAMiQxTAXvH.CHtfzyhDXRVojuufo67fmvs4rYCEEg%2BUY06CooWnikI'
      };
      var request = http.MultipartRequest('POST',
          Uri.parse('${Configurations.baseUrl}/api/v3/topics/$tid/thumbs'));

      if (img != null) {
        var stream = http.ByteStream(DelegatingStream.typed(img.openRead()));
        var length = await img.length();
        var multipartFile = http.MultipartFile('files', stream, length,
            filename: basename(img.path));

        request.files.add(multipartFile);
      }
      request.headers.addAll(headers);

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
          print('image uploaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('this is eror in image ${response.reasonPhrase}');
          print('this is error here in image ${response.statusCode}');
        }
      }
    } catch (e) {
      print('this is error in image $e');
    }
  }

  Future uploadImage({required String path}) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$apiUrl/progress/upload'));
    request.files.add(await http.MultipartFile.fromPath('image', path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('succceffuly image pisted');
      var data = jsonDecode(await response.stream.bytesToString());
      return data['data'];

      // print(data);
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<AnswersModel> getAnswers({required int id, int page = 1}) async {
    var headers = {
      'Cookie':
          'express.sid=s%3A4COsKECmVsMVcMQBjBw3IG0kptwCG4Cn.YLZ8ZxOLvO5f8eyBR70lFMCKpyjR%2BzTKtRpI5b5qtT4; express.sid=s%3Aa72WTtMyEV12nUUceYKfCt-zx_wz_HiP.tPg3XldTOe45NXZH6XAyUgr592yDGTueN3FEl0wU%2Bn8'
    };
    var url = Uri.parse(
        '${Configurations.baseUrl}/api/topic/$id?lang=en-GB&page=$page');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      answersModel = AnswersModel.fromJson(jsonDecode(response.body));
      notifyListeners();
      return answersModel;
    } else {
      print(response.reasonPhrase);
      notifyListeners();
      return answersModel;
    }
  }

  Future postAnswer({required int id, required String answer}) async {
    isLoading = true;
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
      'Cookie':
          'express.sid=s%3A4COsKECmVsMVcMQBjBw3IG0kptwCG4Cn.YLZ8ZxOLvO5f8eyBR70lFMCKpyjR%2BzTKtRpI5b5qtT4; express.sid=s%3Aa72WTtMyEV12nUUceYKfCt-zx_wz_HiP.tPg3XldTOe45NXZH6XAyUgr592yDGTueN3FEl0wU%2Bn8'
    };
    var url = Uri.parse('${Configurations.baseUrl}/api/v3/topics/$id');
    var body = json.encode({'content': answer});

    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print(response.body);
      print('Successfully posted');
    }
    else if (response.statusCode >= 400){
      throw HttpException(jsonDecode(response.body)['status']['message']);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future getProfile({required int id}) async {
    var url = Uri.parse('${Configurations.baseUrl}/api/user/uid/$id');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      getProfileModel = GetProfileModel.fromJson(jsonDecode(response.body));
      userSlug = getProfileModel.userslug ?? '';
      notifyListeners();
    } else {
      print(response.reasonPhrase);
      notifyListeners();
    }
  }

  Future<UserTopicsModel> getUserTopics({
    required String userName,
  }) async {
    var headers = {
      'Cookie':
          'express.sid=s%3Ah7TVYe9WA1j2B4G4A_hSXq0fBud2dDd3.gGqaDGzr9Xq4U2kST80I44PC1pgum9EPHfh%2FFlTNIis; express.sid=s%3AjzoytMGepprzAxFywRomgQGXBo7d8Zwu.RKPSTrqNFMlCi8L%2BstSiBUhp1cIyKNt9SUhjIzlbhig'
    };
    var url = Uri.parse('${Configurations.baseUrl}/api/user/$userSlug/topics');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      userTopicsModel = CategoriesModel.fromJson(jsonDecode(response.body));
      var allTopics = userTopicsModel.toJson();

      getTopics = allTopics['topics'];
      userTopics = UserTopicsModel.fromJson(allTopics);
      return userTopics;
    } else {
      print(response.reasonPhrase);
      return userTopics;
    }
  }

  Future<UserPostsModel> getUserPosts({required String username}) async {
    var url = Uri.parse('${Configurations.baseUrl}/api/user/$userSlug/posts');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> allPosts = jsonDecode(response.body);
      getPosts = allPosts['posts'];
      userPosts = UserPostsModel.fromJson(allPosts);
      return userPosts;
    } else {
      print(response.reasonPhrase);
      return userPosts;
    }
  }

  Future getSignUp({required String id}) async {
    var url = Uri.parse('$apiUrl/community/user/signup');
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({'userId': id});

    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      userId = data['data']['uid'];
      userToken = data['data']['token'];
      isLoading = false;
      notifyListeners();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getSignIn({required String id}) async {
    notifyListeners();
    var headers = {'Content-Type': 'application/json'};
    var url = Uri.parse('$apiUrl/community/user/signin');
    var body = json.encode({'userId': id});
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 409) {
      var data = jsonDecode(response.body);
      userId = data['data']['nodebbUserId'];
      userToken = data['data']['nodebbToken'];

      await getUserDetail(uid: userId);
    } else {
      await getSignUp(id: id).then((value) async {
        await checkUser(uid: int.parse(userId.toString()));
        await getSignIn(id: id);
      });
      print(response.reasonPhrase);
    }
  }

  void updatedList() {
    getAll = [];
    getAll = getPosts + getTopics;
    getAll.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    print('sorted array is getAll ${getAll.length}');

    for (var data in getAll) {
      if (data.containsKey('topic') == true) {
        print('this is my topic ${data['topic']}');
      }
    }
    // getAllData.forEach((element) {
    //   print('sroted Array after parsing ${element.title??''}');
    // });
  }

  Future getUserDetail({required int uid}) async {
    var url = Uri.parse('${Configurations.baseUrl}/api/user/uid/$uid');
    // var headers = {
    //   'Cookie':
    //       'express.sid=s%3A3TWxVsxypL5Pw7BfJ68CnAYhMjjWzoFK.Kx8eqTiaBIwmQqrSSsHhDjOcLwaBmZ6MOFbgkpQu324; express.sid=s%3AjzoytMGepprzAxFywRomgQGXBo7d8Zwu.RKPSTrqNFMlCi8L%2BstSiBUhp1cIyKNt9SUhjIzlbhig'
    // };
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      userName = data['username'];
      aboutMe = data['aboutme'];
      userSlug = data['userslug'];
      isinitialLoading = false;
      notifyListeners();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future checkUser({required int uid}) async {
    var url = Uri.parse('${Configurations.baseUrl}/api/v3/users/$uid');
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
      'Cookie':
          'express.sid=s%3Acg9Dp3iVro-WpyDSvghxrLs25v236kHY.vomeQnaQbLIiyjcRM5%2Bs1h3T70JFMGM71GHD%2F7HegYo; express.sid=s%3A-3miVRxoAcIuwhE7e4f6n_bZC2j8_iF8.UkXn4Xqgl2AhtpBP0Pq%2BvW0WBYLTZV%2Fzg2P7%2Bk%2BZVoQ; express.sid=s%3Aic2kyEwec-bjSI1dP_5n6a-Kgi076OEN.m0YpyqVrgQP2U6YlDymFAz67p6EBa051lFVF%2BWPuJls'
    };
    var body = json.encode({'aboutme': aboutMe});

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future followUser({required int uId}) async {
    var url = Uri.parse('${Configurations.baseUrl}/api/v3/users/$uId/follow');
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Cookie':
          'express.sid=s%3A79w9xLtqt_f5dDB8TQWdR9cGuTMWAL9o.pmpzmSGtPP3MGEHHqnpOFOtkBcZOtpp1fOBMxphdeYg; express.sid=s%3Ah5y6E3NMguFgWnD9Nu055gNsUWCytocm.h1EWAG8YLfvFG%2B0wnpegmJ2EoHEanxbcjyCh7HoY6c4'
    };
    var request = http.Request(
        'PUT', Uri.parse('${Configurations.baseUrl}/api/v3/users/$uId/follow'));

    request.headers.addAll(headers);

    var response = await http.put(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('successfuly Followed');
      print(response.body);
      notifyListeners();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future postVote({required int id}) async {
    var headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
      'Cookie':
          'express.sid=s%3AyaZgb4wLGggz2mP2BIVzru5PXiGzWA2m.ZnHsUg%2BZQt6rFYm085fTOmLtx3M30a89Cev8hX%2Bg32I; express.sid=s%3ABLA2Ks556vAEgcUBsNXVA-o7VeMb3pOo.xYVIepBipIsVG5m2re%2FuZiCb0ox5ji5zZYLtQQwiZRE'
    };
    var request = http.Request(
        'PUT', Uri.parse('${Configurations.baseUrl}/api/v3/posts/$id/vote'));
    request.body = json.encode({'delta': 1});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      notifyListeners();
    } else {
      var data = jsonDecode(await response.stream.bytesToString());

      Fluttertoast.showToast(
          msg: data['status']['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white);
      print(response.reasonPhrase);
    }
  }

  Future getFollowers({required String userName}) async {
    var headers = {
      'Cookie':
          'express.sid=s%3A79w9xLtqt_f5dDB8TQWdR9cGuTMWAL9o.pmpzmSGtPP3MGEHHqnpOFOtkBcZOtpp1fOBMxphdeYg; express.sid=s%3ABLA2Ks556vAEgcUBsNXVA-o7VeMb3pOo.xYVIepBipIsVG5m2re%2FuZiCb0ox5ji5zZYLtQQwiZRE'
    };
    var request = http.Request('GET',
        Uri.parse('${Configurations.baseUrl}/api/user/$userName/followers'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getFollowing({required String userName}) async {
    var headers = {
      'Cookie':
          'express.sid=s%3A79w9xLtqt_f5dDB8TQWdR9cGuTMWAL9o.pmpzmSGtPP3MGEHHqnpOFOtkBcZOtpp1fOBMxphdeYg; express.sid=s%3ABLA2Ks556vAEgcUBsNXVA-o7VeMb3pOo.xYVIepBipIsVG5m2re%2FuZiCb0ox5ji5zZYLtQQwiZRE'
    };
    var request = http.Request('GET',
        Uri.parse('${Configurations.baseUrl}/api/user/$userName/following'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      getFollowingModel = GetFollowingModel.fromJson(
          jsonDecode(await response.stream.bytesToString()));
      notifyListeners();
      // print(getFollowingModel);
    } else {
      print(response.reasonPhrase);
    }
  }
}
