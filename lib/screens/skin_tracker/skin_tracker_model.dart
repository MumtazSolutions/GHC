import '../../models/entities/monthly_progress_images.dart';

class SkinTrackerModel {
  String? reviewStatus;
  num? overallSkinHealth;
  num? skinScoreBefore;
  List<SkinConditions>? conditions = [];
  ProgressTracker? images;
  List<Goals>? skinGoals = [];
  List<Conditions>? userConditionsHistory = List.empty(growable: true);

  SkinTrackerModel(
      {this.reviewStatus = '',
      this.overallSkinHealth,
      this.skinScoreBefore,
      this.conditions,
      this.skinGoals,
      this.images,
      this.userConditionsHistory});

  SkinTrackerModel.fromJson(Map<String, dynamic> parsedJson, type) {
    reviewStatus = parsedJson['reviewStatus'];
    overallSkinHealth = parsedJson['overallSkinScore'];
    skinScoreBefore = parsedJson['previousSkinScore'];
    images = ProgressTracker.fromJson(parsedJson, type);
    if (parsedJson['skinConditions'] != null ||
        parsedJson['skinConditions'] != []) {
      parsedJson['skinConditions'].forEach((condition) {
        conditions!.add(SkinConditions.fromJson(condition));
      });
    } else {
      conditions = [];
    }
    if (parsedJson['userSkinGoals'] != null ||
        parsedJson['userSkinGoals'] != []) {
      parsedJson['userSkinGoals'].forEach((goal) {
        skinGoals!.add(Goals.fromJson(goal));
      });
    } else {
      skinGoals = [];
    }
  }
}

class SkinConditions {
  String? id;
  String? name;
  String? type;
  String? shortName;
  String? image;
  num? score;

  SkinConditions(
      {this.name, this.type, this.shortName, this.image, this.id, this.score});

  SkinConditions.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson.containsKey('_id')) {
      id = parsedJson['_id'];
    } else {
      id = parsedJson['condition'];
    }

    name = parsedJson['value'];
    shortName = parsedJson['alias'];
    type = parsedJson['type'];
    image = parsedJson['icon'];
    score = parsedJson['score'];
  }
}

class Conditions {
  String? id;
  String? name;
  String? type;
  String? shortName;
  String? image;

  Conditions({this.name, this.type, this.shortName, this.image, this.id});

  Conditions.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['_id'];
    name = parsedJson['value'];
    shortName = parsedJson['alias'];
    type = parsedJson['type'];
    image = parsedJson['icon'];
  }
}

class Goals {
  String? id;
  String? name;
  String? type;
  String? shortName;
  String? image;

  Goals({this.name, this.type, this.shortName, this.image, this.id});

  Goals.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['_id'];
    name = parsedJson['value'];
    shortName = parsedJson['alias'];
    type = parsedJson['type'];
    image = parsedJson['icon'];
  }
}

class UserSkinGoals {
  List<String> conditions = [];
  List<String> goals = [];
}
