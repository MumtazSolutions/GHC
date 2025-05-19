import '../../screens/skin_tracker/skin_tracker_model.dart';

class ProgressImage {
  String? id;
  String? user;
  String? file;
  DateTime? date;
  double? weight;

  ProgressImage({
    this.id,
    this.user,
    this.file,
    this.date,
  });

  ProgressImage.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['_id'];
    user = parsedJson['user'];
    file = parsedJson['file'];
    date = DateTime.parse(parsedJson['createdAt']);
    weight = parsedJson['measurements'] != null
        ? double.parse(parsedJson['measurements']['weight'])
        : null;
  }
}

class ProgressWeek {
  String? weekNumValue;
  String? weekNum;
  String? topImage;
  String? frontImage;
  DateTime? date;
  bool? currentWeek;
  double? weight;
  List<SkinConditions>? conditions = [];
  String? reviewStatus;
  num? weekOverallScore;
  String? doctorNote;

  ProgressWeek(
      {this.weekNum,
      this.topImage,
      this.frontImage,
      this.date,
      this.currentWeek,
      this.conditions,
      this.reviewStatus,
      this.weekOverallScore,
      this.doctorNote,
      this.weekNumValue});

  ProgressWeek.fromJson(Map<String, dynamic> parsedJson, type) {
    currentWeek = parsedJson['currentWeek'];
    weekNumValue = parsedJson['weekNumberValue'].toString();
    weekNum = parsedJson['weekNumber'].toString();
    topImage = parsedJson['weekImages']['topImage'];
    frontImage = parsedJson['weekImages']['frontImage'];
    reviewStatus = parsedJson['weekImages']['status'];
    doctorNote = parsedJson['weekImages']['doctorNote'];
    if (type == 'Skin') {
      weekOverallScore = parsedJson['weekImages']['overallScore'];
    }
    if (type == 'Skin') {
      if (parsedJson['condition'] != null || parsedJson['condition'] != []) {
        parsedJson['condition'].forEach((c) {
          conditions!.add(SkinConditions.fromJson(c));
        });
      }
    }

    date = parsedJson['weekImages']['uploadDate'] != ''
        ? DateTime.parse(parsedJson['weekImages']['uploadDate'])
        : DateTime.now();
    weight = parsedJson['measurements'] != null
        ? double.parse(parsedJson['measurements']['weight'])
        : null;
  }
}
