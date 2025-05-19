import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../frameworks/progress/progress_service.dart';
import '../../screens/skin_tracker/skin_tracker_model.dart';
import '../../services/index.dart';
import '../entities/monthly_progress_images.dart';
import '../entities/user.dart';
import 'weight_tracker_model.dart';

class ProgressTrackingVM extends ChangeNotifier {
  final Services _service = Services();
  ProgressTracker? tracker;

  bool isloading = false;
  String? message;
  bool isImageUploading = false;
  User? user;
  bool isValidDate = true;
  List categories = [];
  String? type;
  int? weight;
  int? month;
  WeightTrackerModel? weightTracker;
  SkinTrackerModel? skinData;
  List<Conditions> conditions = [];
  List<Goals> goals = [];
  bool hairp = false, weightp = false, beardp = false, skinp = false;
  bool bedTime = false;
  TabController? tabController;
  int currentTabIndex = 0;
  final navigators = <int, GlobalKey<NavigatorState>>{};

  void onTapTabBar(index) {
    if (currentTabIndex == index) {
      navigators[tabController?.index ?? 0]!
          .currentState
          ?.popUntil((r) => r.isFirst);
    }
    currentTabIndex = index;
  }

  ProgressTrackingVM() {
    fetchCategories();
    getUser();
    fetchConditionsAndGoals();
  }

  void setCategory(String category) async {
    type = category;
    isloading = true;
    notifyListeners();
    getUser();
  }

  void getUser() async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;

      if (ready) {
        final json = storage.getItem(kLocalKey['userInfo']!);
        if (json != null) {
          user = User.fromLocalJson(json);
          final userInfo = await _service.api.getUserInfo(user!.cookie);
          if (userInfo != null) {
            userInfo.isSocial = user!.isSocial;
            user = userInfo;
          }
        } else {
          user = null;
        }
      }
      await fetchImages();
      if (type == 'Weight Loss') {
        await fetchWeightData();
      }
    } catch (err) {
      printLog(err);
    }
  }

  dynamic fetchCategories() async {
    try {
      printLog('[Category] getCategories');
      isloading = true;
      notifyListeners();
      categories = await ProgressService().fetchProgressCategories();
      if (categories == null) {
        categories = [];
      }
      message = null;
      isloading = false;
      notifyListeners();
      return categories;
    } catch (err, _) {
      debugPrintStack();
      isloading = false;
      message = 'There is an issue with the app during request the data, please contact admin for fixing the issues $err';
      log(err.toString());
      notifyListeners();
    }
  }

  Future fetchImages() async {
    log('fetching images....');
    if (user == null) {
      printLog('user is null');
      tracker = null;
      notifyListeners();
      isloading = false;
      return;
    }
    log('category :::::: $type');

    tracker = await ProgressService().fetchMonthlyImages(user!.id, type);

    notifyListeners();

    if (type == 'Weight Loss') {
      weightTracker = await ProgressService().getWeightData(user!.id);
      notifyListeners();
    }

    skinData = await ProgressService().returnSkinData(user!.id, type);
    if (type == 'Skin') {
      tracker = await ProgressService().getSkinData(user!.id, type);
      notifyListeners();
    }
    // tracker ??= await ProgressService().fetchMonthlyImages(user!.id, type);
    await checkIfValidUploadDate();
    isloading = false;
    notifyListeners();
    return tracker;
  }

  Future<void> addProgress({file, weight, Function? response}) async {
    isImageUploading = true;
    notifyListeners();
    var result =
        await ProgressService().addNewprogress(file, user!.id, type, weight);
    await fetchImages();
    response!(result);
    isImageUploading = false;
    notifyListeners();
  }

  Future<void> checkIfValidUploadDate() async {
    isValidDate =
        await ProgressService().checkForValidUploadDate(user!.id, type);
  }

  Future<bool> uploadUserPics({frontImg, topImg}) async {
    isImageUploading = true;
    notifyListeners();
    unawaited(ProgressService().uploadPics(
        type: type, userId: user!.id, frontImage: frontImg, topImage: topImg));
    isImageUploading = false;
    notifyListeners();
    return true;
  }

  ///
  /// weight tracker functions
  ///

  Future<void> postHeightWeight({height, weight, context}) async {
    var progress = Provider.of<ProgressTrackingVM>(context, listen: false);
    await ProgressService().setHeightWeight(
        userId: progress.user!.id, height: height, weight: weight);

    /// TODO: assert fetch Function (get) for updating values
    weightTracker = await ProgressService().getWeightData(progress.user!.id);

    notifyListeners();
  }

  Future<void> createGoal({goalWeight, timeline, context}) async {
    var progress = Provider.of<ProgressTrackingVM>(context, listen: false);
    await ProgressService().setWeightGoal(
        weightGoal: goalWeight, timeline: timeline, userId: progress.user!.id);

    /// TODO: assert fetch Function (get) for updating values
    weightTracker = await ProgressService().getWeightData(progress.user!.id);
    notifyListeners();
  }

  var uuser;
  Future<void> postDailyWeight({weight, context}) async {
    var progress = Provider.of<ProgressTrackingVM>(context, listen: false);

    await ProgressService()
        .createWeight(userId: progress.user!.id, weight: weight);

    /// TODO: assert fetch Function (get) for updating values
    weightTracker = await ProgressService().getWeightData(progress.user!.id);
    notifyListeners();
  }

  Future fetchWeightData() async {
    weightTracker = await ProgressService().getWeightData(user?.id ?? '');
    // isloading = false;
    notifyListeners();
    return true;
  }

  ///
  /// skin tracker functions
  ///

  Future fetchConditionsAndGoals() async {
    // ignore: omit_local_variable_types
    List cg = [];
    cg = await ProgressService().returnGoalsAndConditions();
    conditions = cg.first;
    goals = cg.last;
    notifyListeners();
  }

  Future getWeightProgressData() async {
    isloading = true;
    notifyListeners();
    weightTracker = await ProgressService().getWeightData(user!.id);
    isloading = false;
    notifyListeners();
  }
}
