class SleepTrackingModel {
  Data? data;

  SleepTrackingModel({this.data});

  SleepTrackingModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  num? year;
  num? totalYearlySleep;
  num? avgYearlySleep;
  Monthly? monthly;
  num? totalSleepToday;
  num? weight;
  bool? bedTime;
  num? sleepGoal;
  num? sleeplessness;
  num? oversleep;
  List<MonthsData>? monthsData;
  num? daysInMonth;
  num? weeksInMonth;

  Data(
      {this.year,
        this.totalYearlySleep,
        this.avgYearlySleep,
        this.monthly,
        this.totalSleepToday,
        this.weight,
        this.bedTime,
        this.sleepGoal,
        this.sleeplessness,
        this.oversleep,
        this.monthsData,
        this.daysInMonth,
        this.weeksInMonth});

  Data.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    totalYearlySleep = json['totalYearlySleep'];
    avgYearlySleep = json['avgYearlySleep'];
    monthly =
    json['monthly'] != null ? Monthly.fromJson(json['monthly']) : null;
    totalSleepToday = json['totalSleepToday'];
    weight = json['weight'];
    bedTime = json['bedTime'];
    sleepGoal = json['sleepGoal'];
    sleeplessness = json['sleeplessness'];
    oversleep = json['oversleep'];
    if (json['monthsData'] != null) {
      monthsData = <MonthsData>[];
      json['monthsData'].forEach((v) {
        monthsData!.add(MonthsData.fromJson(v));
      });
    }
    daysInMonth = json['daysInMonth'];
    weeksInMonth = json['weeksInMonth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['year'] = year;
    data['totalYearlySleep'] = totalYearlySleep;
    data['avgYearlySleep'] = avgYearlySleep;
    if (monthly != null) {
      data['monthly'] = monthly!.toJson();
    }
    data['totalSleepToday'] = totalSleepToday;
    data['weight'] = weight;
    data['bedTime'] = bedTime;
    data['sleepGoal'] = sleepGoal;
    data['sleeplessness'] = sleeplessness;
    data['oversleep'] = oversleep;
    if (monthsData != null) {
      data['monthsData'] = monthsData!.map((v) => v.toJson()).toList();
    }
    data['daysInMonth'] = daysInMonth;
    data['weeksInMonth'] = weeksInMonth;
    return data;
  }
}

class Monthly {
  num? weeksInMonth;
  num? monthNumber;
  String? monthName;
  num? totalMonthlySleep;
  num? avgMonthlySleep;
  List<Weekly>? weekly;

  Monthly(
      {this.weeksInMonth,
        this.monthNumber,
        this.monthName,
        this.totalMonthlySleep,
        this.avgMonthlySleep,
        this.weekly});

  Monthly.fromJson(Map<String, dynamic> json) {
    weeksInMonth = json['weeksInMonth'];
    monthNumber = json['monthNumber'];
    monthName = json['monthName'];
    totalMonthlySleep = json['totalMonthlySleep'];
    avgMonthlySleep = json['avgMonthlySleep'];
    if (json['weekly'] != null) {
      weekly = <Weekly>[];
      json['weekly'].forEach((v) {
        weekly!.add(Weekly.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['weeksInMonth'] = weeksInMonth;
    data['monthNumber'] = monthNumber;
    data['monthName'] = monthName;
    data['totalMonthlySleep'] = totalMonthlySleep;
    data['avgMonthlySleep'] = avgMonthlySleep;
    if (weekly != null) {
      data['weekly'] = weekly!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Weekly {
  num? weekNumber;
  num? totalWeeklySleep;
  num? avgWeeklySleep;
  List<Daily>? daily;
  bool? currentWeek;

  Weekly(
      {this.weekNumber,
        this.totalWeeklySleep,
        this.avgWeeklySleep,
        this.daily,
        this.currentWeek});

  Weekly.fromJson(Map<String, dynamic> json) {
    weekNumber = json['weekNumber'];
    totalWeeklySleep = json['totalWeeklySleep'];
    avgWeeklySleep = json['avgWeeklySleep'];
    if (json['daily'] != null) {
      daily = <Daily>[];
      json['daily'].forEach((v) {
        daily!.add(Daily.fromJson(v));
      });
    }
    currentWeek = json['currentWeek'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['weekNumber'] = weekNumber;
    data['totalWeeklySleep'] = totalWeeklySleep;
    data['avgWeeklySleep'] = avgWeeklySleep;
    if (daily != null) {
      data['daily'] = daily!.map((v) => v.toJson()).toList();
    }
    data['currentWeek'] = currentWeek;
    return data;
  }
}

class Daily {
  String? dayName;
  num? dayOfMonth;
  num? totalSleep;

  Daily({this.dayName, this.dayOfMonth, this.totalSleep});

  Daily.fromJson(Map<String, dynamic> json) {
    dayName = json['dayName'];
    dayOfMonth = json['dayOfMonth'];
    totalSleep = json['totalSleep'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dayName'] = dayName;
    data['dayOfMonth'] = dayOfMonth;
    data['totalSleep'] = totalSleep;
    return data;
  }
}

class MonthsData {
  String? monthName;
  num? totalMonthlySleep;
  num? monthlyAvgSleep;

  MonthsData({this.monthName, this.totalMonthlySleep, this.monthlyAvgSleep});

  MonthsData.fromJson(Map<String, dynamic> json) {
    monthName = json['monthName'];
    totalMonthlySleep = json['totalMonthlySleep'];
    monthlyAvgSleep = json['monthlyAvgSleep'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['monthName'] = monthName;
    data['totalMonthlySleep'] = totalMonthlySleep;
    data['monthlyAvgSleep'] = monthlyAvgSleep;
    return data;
  }
}
