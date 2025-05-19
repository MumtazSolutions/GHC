// // To parse this JSON data, do
// //
// //     final sleepTrackerModel = sleepTrackerModelFromJson(jsonString);

// import 'dart:convert';

// SleepTrackerModel sleepTrackerModelFromJson(String str) => SleepTrackerModel.fromJson(json.decode(str));

// String sleepTrackerModelToJson(SleepTrackerModel data) => json.encode(data.toJson());

// class SleepTrackerModel {
//     Data data;

//     SleepTrackerModel({
//         required this.data,
//     });

//     factory SleepTrackerModel.fromJson(Map<String, dynamic> json) => SleepTrackerModel(
//         data: Data.fromJson(json["data"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "data": data.toJson(),
//     };
// }

// class Data {
//     int year;
//     int totalYearlySleep;
//     double avgYearlySleep;
//     Monthly monthly;
//     int totalSleepToday;
//     int weight;
//     bool bedTime;
//     int sleepGoal;
//     int sleeplessness;
//     int oversleep;
//     List<MonthsDatum> monthsData;
//     int daysInMonth;
//     int weeksInMonth;

//     Data({
//         required this.year,
//         required this.totalYearlySleep,
//         required this.avgYearlySleep,
//         required this.monthly,
//         required this.totalSleepToday,
//         required this.weight,
//         required this.bedTime,
//         required this.sleepGoal,
//         required this.sleeplessness,
//         required this.oversleep,
//         required this.monthsData,
//         required this.daysInMonth,
//         required this.weeksInMonth,
//     });

//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         year: json["year"],
//         totalYearlySleep: json["totalYearlySleep"],
//         avgYearlySleep: json["avgYearlySleep"]?.toDouble(),
//         monthly: Monthly.fromJson(json["monthly"]),
//         totalSleepToday: json["totalSleepToday"],
//         weight: json["weight"],
//         bedTime: json["bedTime"],
//         sleepGoal: json["sleepGoal"],
//         sleeplessness: json["sleeplessness"],
//         oversleep: json["oversleep"],
//         monthsData: List<MonthsDatum>.from(json["monthsData"].map((x) => MonthsDatum.fromJson(x))),
//         daysInMonth: json["daysInMonth"],
//         weeksInMonth: json["weeksInMonth"],
//     );

//     Map<String, dynamic> toJson() => {
//         "year": year,
//         "totalYearlySleep": totalYearlySleep,
//         "avgYearlySleep": avgYearlySleep,
//         "monthly": monthly.toJson(),
//         "totalSleepToday": totalSleepToday,
//         "weight": weight,
//         "bedTime": bedTime,
//         "sleepGoal": sleepGoal,
//         "sleeplessness": sleeplessness,
//         "oversleep": oversleep,
//         "monthsData": List<dynamic>.from(monthsData.map((x) => x.toJson())),
//         "daysInMonth": daysInMonth,
//         "weeksInMonth": weeksInMonth,
//     };
// }

// class Monthly {
//     int weeksInMonth;
//     int monthNumber;
//     String monthName;
//     int totalMonthlySleep;
//     int avgMonthlySleep;
//     List<Weekly> weekly;

//     Monthly({
//         required this.weeksInMonth,
//         required this.monthNumber,
//         required this.monthName,
//         required this.totalMonthlySleep,
//         required this.avgMonthlySleep,
//         required this.weekly,
//     });

//     factory Monthly.fromJson(Map<String, dynamic> json) => Monthly(
//         weeksInMonth: json["weeksInMonth"],
//         monthNumber: json["monthNumber"],
//         monthName: json["monthName"],
//         totalMonthlySleep: json["totalMonthlySleep"],
//         avgMonthlySleep: json["avgMonthlySleep"],
//         weekly: List<Weekly>.from(json["weekly"].map((x) => Weekly.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "weeksInMonth": weeksInMonth,
//         "monthNumber": monthNumber,
//         "monthName": monthName,
//         "totalMonthlySleep": totalMonthlySleep,
//         "avgMonthlySleep": avgMonthlySleep,
//         "weekly": List<dynamic>.from(weekly.map((x) => x.toJson())),
//     };
// }

// class Weekly {
//     int weekNumber;
//     int totalWeeklySleep;
//     double avgWeeklySleep;
//     List<Daily> daily;
//     bool? currentWeek;

//     Weekly({
//         required this.weekNumber,
//         required this.totalWeeklySleep,
//         required this.avgWeeklySleep,
//         required this.daily,
//         this.currentWeek,
//     });

//     factory Weekly.fromJson(Map<String, dynamic> json) => Weekly(
//         weekNumber: json["weekNumber"],
//         totalWeeklySleep: json["totalWeeklySleep"],
//         avgWeeklySleep: json["avgWeeklySleep"]?.toDouble(),
//         daily: List<Daily>.from(json["daily"].map((x) => Daily.fromJson(x))),
//         currentWeek: json["currentWeek"],
//     );

//     Map<String, dynamic> toJson() => {
//         "weekNumber": weekNumber,
//         "totalWeeklySleep": totalWeeklySleep,
//         "avgWeeklySleep": avgWeeklySleep,
//         "daily": List<dynamic>.from(daily.map((x) => x.toJson())),
//         "currentWeek": currentWeek,
//     };
// }

// class Daily {
//     String dayName;
//     int dayOfMonth;
//     int totalSleep;

//     Daily({
//         required this.dayName,
//         required this.dayOfMonth,
//         required this.totalSleep,
//     });

//     factory Daily.fromJson(Map<String, dynamic> json) => Daily(
//         dayName: json["dayName"],
//         dayOfMonth: json["dayOfMonth"],
//         totalSleep: json["totalSleep"],
//     );

//     Map<String, dynamic> toJson() => {
//         "dayName": dayName,
//         "dayOfMonth": dayOfMonth,
//         "totalSleep": totalSleep,
//     };
// }

// class MonthsDatum {
//     String monthName;
//     int totalMonthlySleep;
//     double monthlyAvgSleep;

//     MonthsDatum({
//         required this.monthName,
//         required this.totalMonthlySleep,
//         required this.monthlyAvgSleep,
//     });

//     factory MonthsDatum.fromJson(Map<String, dynamic> json) => MonthsDatum(
//         monthName: json["monthName"],
//         totalMonthlySleep: json["totalMonthlySleep"],
//         monthlyAvgSleep: json["monthlyAvgSleep"]?.toDouble(),
//     );

//     Map<String, dynamic> toJson() => {
//         "monthName": monthName,
//         "totalMonthlySleep": totalMonthlySleep,
//         "monthlyAvgSleep": monthlyAvgSleep,
//     };
// }
