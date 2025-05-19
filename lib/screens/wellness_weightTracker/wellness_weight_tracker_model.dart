/// data : {"weightHistory":[{"_id":"64a459c9814bb805144de317","user":"Z2lkOi8vc2hvcGlmeS9DdXN0b21lci82NTQxNzA0OTIxMzM2","createdAt":"2023-07-04T17:41:29.286Z","type":"Weight Loss","weight":80}],"weightGoalHistory":[{"_id":"","user":"Z2lkOi8vc2hvcGlmeS9DdXN0b21lci82NTQxNzA0OTIxMzM2","weight":0}],"currentGoal":0,"firstWeight":80,"currentWeight":80,"currentHeight":140,"trends":{"days10":0,"days21":0},"bmi":40.82}

class WeightTrackingModel {
  WeightTrackingModel({
      this.data,});

  WeightTrackingModel.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  Data? data;
WeightTrackingModel copyWith({  Data? data,
}) => WeightTrackingModel(  data: data ?? this.data,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }

}

/// weightHistory : [{"_id":"64a459c9814bb805144de317","user":"Z2lkOi8vc2hvcGlmeS9DdXN0b21lci82NTQxNzA0OTIxMzM2","createdAt":"2023-07-04T17:41:29.286Z","type":"Weight Loss","weight":80}]
/// weightGoalHistory : [{"_id":"","user":"Z2lkOi8vc2hvcGlmeS9DdXN0b21lci82NTQxNzA0OTIxMzM2","weight":0}]
/// currentGoal : 0
/// firstWeight : 80
/// currentWeight : 80
/// currentHeight : 140
/// trends : {"days10":0,"days21":0}
/// bmi : 40.82

class Data {
  Data({
      this.weightHistory, 
      this.weightGoalHistory, 
      this.currentGoal, 
      this.firstWeight, 
      this.currentWeight, 
      this.currentHeight, 
      this.trends, 
      this.bmi,});

  Data.fromJson(dynamic json) {
    if (json['weightHistory'] != null) {
      weightHistory = [];
      json['weightHistory'].forEach((v) {
        weightHistory?.add(WeightHistory.fromJson(v));
      });
    }
    if (json['weightGoalHistory'] != null) {
      weightGoalHistory = [];
      json['weightGoalHistory'].forEach((v) {
        weightGoalHistory?.add(WeightGoalHistory.fromJson(v));
      });
    }
    currentGoal = json['currentGoal'];
    firstWeight = json['firstWeight'];
    currentWeight = json['currentWeight'];
    currentHeight = json['currentHeight'];
    trends = json['trends'] != null ? Trends.fromJson(json['trends']) : null;
    bmi = json['bmi'];
  }
  List<WeightHistory>? weightHistory;
  List<WeightGoalHistory>? weightGoalHistory;
  num? currentGoal;
  num? firstWeight;
  num? currentWeight;
  num? currentHeight;
  Trends? trends;
  num? bmi;
Data copyWith({  List<WeightHistory>? weightHistory,
  List<WeightGoalHistory>? weightGoalHistory,
  num? currentGoal,
  num? firstWeight,
  num? currentWeight,
  num? currentHeight,
  Trends? trends,
  num? bmi,
}) => Data(  weightHistory: weightHistory ?? this.weightHistory,
  weightGoalHistory: weightGoalHistory ?? this.weightGoalHistory,
  currentGoal: currentGoal ?? this.currentGoal,
  firstWeight: firstWeight ?? this.firstWeight,
  currentWeight: currentWeight ?? this.currentWeight,
  currentHeight: currentHeight ?? this.currentHeight,
  trends: trends ?? this.trends,
  bmi: bmi ?? this.bmi,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (weightHistory != null) {
      map['weightHistory'] = weightHistory?.map((v) => v.toJson()).toList();
    }
    if (weightGoalHistory != null) {
      map['weightGoalHistory'] = weightGoalHistory?.map((v) => v.toJson()).toList();
    }
    map['currentGoal'] = currentGoal;
    map['firstWeight'] = firstWeight;
    map['currentWeight'] = currentWeight;
    map['currentHeight'] = currentHeight;
    if (trends != null) {
      map['trends'] = trends?.toJson();
    }
    map['bmi'] = bmi;
    return map;
  }

}

/// days10 : 0
/// days21 : 0

class Trends {
  Trends({
      this.days10, 
      this.days21,});

  Trends.fromJson(dynamic json) {
    days10 = json['days10'];
    days21 = json['days21'];
  }
  num? days10;
  num? days21;
Trends copyWith({  num? days10,
  num? days21,
}) => Trends(  days10: days10 ?? this.days10,
  days21: days21 ?? this.days21,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['days10'] = days10;
    map['days21'] = days21;
    return map;
  }

}

/// _id : ""
/// user : "Z2lkOi8vc2hvcGlmeS9DdXN0b21lci82NTQxNzA0OTIxMzM2"
/// weight : 0

class WeightGoalHistory {
  WeightGoalHistory({
      this.id, 
      this.user, 
      this.weight,});

  WeightGoalHistory.fromJson(dynamic json) {
    id = json['_id'];
    user = json['user'];
    weight = json['weight'];
  }
  String? id;
  String? user;
  num? weight;
WeightGoalHistory copyWith({  String? id,
  String? user,
  num? weight,
}) => WeightGoalHistory(  id: id ?? this.id,
  user: user ?? this.user,
  weight: weight ?? this.weight,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['user'] = user;
    map['weight'] = weight;
    return map;
  }

}

/// _id : "64a459c9814bb805144de317"
/// user : "Z2lkOi8vc2hvcGlmeS9DdXN0b21lci82NTQxNzA0OTIxMzM2"
/// createdAt : "2023-07-04T17:41:29.286Z"
/// type : "Weight Loss"
/// weight : 80

class WeightHistory {
  WeightHistory({
      this.id, 
      this.user, 
      this.createdAt, 
      this.type, 
      this.weight,});

  WeightHistory.fromJson(dynamic json) {
    id = json['_id'];
    user = json['user'];
    createdAt = json['createdAt'];
    type = json['type'];
    weight = json['weight'];
  }
  String? id;
  String? user;
  String? createdAt;
  String? type;
  num? weight;
WeightHistory copyWith({  String? id,
  String? user,
  String? createdAt,
  String? type,
  num? weight,
}) => WeightHistory(  id: id ?? this.id,
  user: user ?? this.user,
  createdAt: createdAt ?? this.createdAt,
  type: type ?? this.type,
  weight: weight ?? this.weight,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['user'] = user;
    map['createdAt'] = createdAt;
    map['type'] = type;
    map['weight'] = weight;
    return map;
  }

}