import 'package:flutter/material.dart';
import 'progress_image.dart';

class MonthlyProgressImages {
  int? month;
  List<ProgressImage>? images = [];

  MonthlyProgressImages({this.month, this.images});

  MonthlyProgressImages.fromJson(Map<String, dynamic> parsedJson) {
    month = parsedJson['_id'];
    for (var file in parsedJson['files']) {
      images!.add(ProgressImage.fromJson(file));
    }
    images!.sort((a, b) {
      return a.date!.compareTo(b.date!);
    });
  }
}

class ProgressTracker extends ChangeNotifier {
  String? type;
  String? presentWeek;
  String? totalWeeks;
  DateTime? startDate;
  DateTime? lastUpload;
  List<ProgressMonth>? months = [];

  ProgressTracker(
      {this.type,
      this.presentWeek,
      this.totalWeeks,
      this.lastUpload,
      this.months,
      this.startDate});

  ProgressTracker.fromJson(Map<String, dynamic> parsedJson, type) {
    var m = [];
    months!.clear();
    m.clear();
    type = parsedJson['type'];
    presentWeek = parsedJson['progressWeek'].toString();
    totalWeeks = parsedJson['totalWeeks'].toString();
    startDate = DateTime.parse(parsedJson['startDate']);
    if (type == 'Skin' && parsedJson['lastUploadDate'] != '') {
      lastUpload = DateTime.parse(parsedJson['lastUploadDate']);
    } else if (type == 'Skin' && parsedJson['lastUploadDate'] == '') {
      lastUpload = DateTime.parse(parsedJson['startDate']);
    }
    parsedJson['progress']['months'].forEach((ms) {
      months!.add(ProgressMonth.fromJson(ms, type));
    });
  }
}

class ProgressMonth {
  String? monthName;
  String? monthNumber;
  num? year;
  String? weeksInMonth;
  List<ProgressWeek>? weeks = [];

  ProgressMonth(
      {this.monthName,
      this.monthNumber,
      this.weeksInMonth,
      this.year,
      this.weeks});

  ProgressMonth.fromJson(Map<String, dynamic> parsedJson, type) {
    var w = <ProgressWeek>[];

    weeks!.clear();
    w.clear();
    monthName = parsedJson['monthName'];
    monthNumber = parsedJson['monthNumber'].toString();
    weeksInMonth = parsedJson['weeksInMonth'].toString();
    year = num.parse(parsedJson['year'].toString());
    parsedJson['weeks'].forEach((week) {
      weeks!.add(ProgressWeek.fromJson(week, type));
    });
  }
}
