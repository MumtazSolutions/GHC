
class WeightTrackerModel {
  num? targetWeight;
  num? startingWeight;
  num? weight;
  num? height;
  num? bmi;
  num? trendsDay10;
  num? trendsDay20;
  WeightHistory? weightHistory;

  WeightTrackerModel(
      {this.targetWeight,
      this.startingWeight,
      this.weight,
      this.height,
      this.bmi,
      this.trendsDay10,
      this.trendsDay20,
      this.weightHistory});

  WeightTrackerModel.fromJson(Map<String, dynamic> parsedJson) {
    targetWeight = parsedJson['currentGoal'];
    startingWeight = parsedJson['firstWeight'];
    weight = parsedJson['currentWeight'];
    height = parsedJson['currentHeight'];
    bmi = parsedJson['bmi'];
    trendsDay10 = parsedJson['trends']['days10'];
    trendsDay20 = parsedJson['trends']['days21'];
    weightHistory = WeightHistory.fromJson(parsedJson);
  }
}

class WeightHistory {
  List? date = [];
  List? goalWeight = [];
  List? actualWeight = [];

  WeightHistory({this.date, this.goalWeight, this.actualWeight});

  WeightHistory.fromJson(Map<String, dynamic> parsedJson) {
    parsedJson['weightHistory'].forEach((w) {
      date!.add(w['createdAt']);
    });
    parsedJson['weightHistory'].forEach((w) {
      actualWeight!.add(w['weight']);
    });
    parsedJson['weightGoalHistory'].forEach((w) {
      goalWeight!.add(w['weight']);
    });
  }
}
