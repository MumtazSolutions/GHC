class WaterTrackerModel {
  Data? data;

  WaterTrackerModel({this.data});

  WaterTrackerModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? year;
  int? totalYearlyIntake;
  num? yearlyAvgIntake;
  Monthly? monthly;
  int? glassesIntakeToday;
  int? goalGlasses;
  int? overIntake;
  int? weight;
  List<MonthsData>? monthsData;
  int? daysInMonth;
  int? weeksInMonth;

  Data(
      {this.year,
      this.totalYearlyIntake,
      this.yearlyAvgIntake,
      this.monthly,
      this.glassesIntakeToday,
      this.goalGlasses,
      this.overIntake,
      this.weight,
      this.monthsData,
      this.daysInMonth,
      this.weeksInMonth});

  Data.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    totalYearlyIntake = json['totalYearlyIntake'];
    yearlyAvgIntake = json['yearlyAvgIntake'];
    monthly =
        json['monthly'] != null ? new Monthly.fromJson(json['monthly']) : null;
    glassesIntakeToday = json['glassesIntakeToday'];
    goalGlasses = json['goalGlasses'];
    overIntake = json['overIntake'];
    weight = json['weight'];
    if (json['monthsData'] != null) {
      monthsData = <MonthsData>[];
      json['monthsData'].forEach((v) {
        monthsData!.add(new MonthsData.fromJson(v));
      });
    }
    daysInMonth = json['daysInMonth'];
    weeksInMonth = json['weeksInMonth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['year'] = year;
    data['totalYearlyIntake'] = totalYearlyIntake;
    data['yearlyAvgIntake'] = yearlyAvgIntake;
    if (monthly != null) {
      data['monthly'] = monthly!.toJson();
    }
    data['glassesIntakeToday'] = glassesIntakeToday;
    data['goalGlasses'] = goalGlasses;
    data['overIntake'] = overIntake;
    data['weight'] = weight;
    if (monthsData != null) {
      data['monthsData'] = monthsData!.map((v) => v.toJson()).toList();
    }
    data['daysInMonth'] = daysInMonth;
    data['weeksInMonth'] = weeksInMonth;
    return data;
  }
}

class Monthly {
  int? weeksInMonth;
  int? monthNumber;
  String? monthName;
  int? totalMonthlyIntake;
  num? monthlyAvgIntake;
  List<Weekly>? weekly;

  Monthly(
      {this.weeksInMonth,
      this.monthNumber,
      this.monthName,
      this.totalMonthlyIntake,
      this.monthlyAvgIntake,
      this.weekly});

  Monthly.fromJson(Map<String, dynamic> json) {
    weeksInMonth = json['weeksInMonth'];
    monthNumber = json['monthNumber'];
    monthName = json['monthName'];
    totalMonthlyIntake = json['totalMonthlyIntake'];
    monthlyAvgIntake = json['monthlyAvgIntake'];
    if (json['weekly'] != null) {
      weekly = <Weekly>[];
      json['weekly'].forEach((v) {
        weekly!.add(new Weekly.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['weeksInMonth'] = weeksInMonth;
    data['monthNumber'] = monthNumber;
    data['monthName'] = monthName;
    data['totalMonthlyIntake'] = totalMonthlyIntake;
    data['monthlyAvgIntake'] = monthlyAvgIntake;
    if (weekly != null) {
      data['weekly'] = weekly!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Weekly {
  int? weekNumber;
  int? totalWeeklyIntake;
  num? weeklyAvgIntake;
  List<Daily>? daily;
  bool? currentWeek;

  Weekly(
      {this.weekNumber,
      this.totalWeeklyIntake,
      this.weeklyAvgIntake,
      this.daily,
      this.currentWeek});

  Weekly.fromJson(Map<String, dynamic> json) {
    weekNumber = json['weekNumber'];
    totalWeeklyIntake = json['totalWeeklyIntake'];
    weeklyAvgIntake = json['weeklyAvgIntake'];
    if (json['daily'] != null) {
      daily = <Daily>[];
      json['daily'].forEach((v) {
        daily!.add(new Daily.fromJson(v));
      });
    }
    currentWeek = json['currentWeek'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['weekNumber'] = weekNumber;
    data['totalWeeklyIntake'] = totalWeeklyIntake;
    data['weeklyAvgIntake'] = weeklyAvgIntake;
    if (daily != null) {
      data['daily'] = daily!.map((v) => v.toJson()).toList();
    }
    data['currentWeek'] = currentWeek;
    return data;
  }
}

class Daily {
  String? dayName;
  int? dayOfMonth;
  int? waterIntake;

  Daily({this.dayName, this.dayOfMonth, this.waterIntake});

  Daily.fromJson(Map<String, dynamic> json) {
    dayName = json['dayName'];
    dayOfMonth = json['dayOfMonth'];
    waterIntake = json['waterIntake'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dayName'] = dayName;
    data['dayOfMonth'] = dayOfMonth;
    data['waterIntake'] = waterIntake;
    return data;
  }
}

class MonthsData {
  String? monthName;
  int? totalMonthlyIntake;
  num? monthlyAvgIntake;

  MonthsData({this.monthName, this.totalMonthlyIntake, this.monthlyAvgIntake});

  MonthsData.fromJson(Map<String, dynamic> json) {
    monthName = json['monthName'];
    totalMonthlyIntake = json['totalMonthlyIntake'];
    monthlyAvgIntake = json['monthlyAvgIntake'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['monthName'] = monthName;
    data['totalMonthlyIntake'] = totalMonthlyIntake;
    data['monthlyAvgIntake'] = monthlyAvgIntake;
    return data;
  }
}
