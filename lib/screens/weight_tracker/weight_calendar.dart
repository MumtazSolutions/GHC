import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../models/progress/progress_tracking_model.dart';

final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
  equals: isSameDay,
  hashCode: getHashCode,
);

class WeightCalendarPage extends StatefulWidget {
  final bool firstTime;
  const WeightCalendarPage({Key? key, this.firstTime = false})
      : super(key: key);

  @override
  _WeightCalendarPageState createState() => _WeightCalendarPageState();
}

class _WeightCalendarPageState extends State<WeightCalendarPage> {
  double _value = 0;
  ScrollController? _controller;
  double _scrollPosition = 0.0;
  List a = [];
  var weightData = Provider.of<ProgressTrackingVM>(Get.context!, listen: false);

  bool canClick = true;

  List eves1 = [
    DateTime(2021, 12, 2),
    DateTime(2021, 12, 3),
    DateTime(2021, 12, 4),
    DateTime(2021, 12, 5),
    DateTime(2021, 12, 9),
    DateTime(2021, 12, 10),
    DateTime(2021, 12, 12),
    DateTime(2021, 12, 13),
    DateTime(2021, 12, 14),
    DateTime(2021, 12, 15),
  ];

  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    // _selectedEvents.dispose();
    super.dispose();
  }

  // final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
  //   equals: isSameDay,
  //   hashCode: getHashCode,
  // );

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  _scrollListener() {
    setState(() {
      _scrollPosition = _controller?.position.pixels ?? 0;
    });
  }

  Widget weightPicker() {
    a.clear();
    for (int i = 0; i < 9; i++) {
      a.add('assets/images/scale.png');
    }
    return SizedBox(
        height: SizeConfig.blockSizeVertical! * 19,
        width: SizeConfig.screenWidth,
        child: Center(
          child: Stack(
            children: [
              Image.asset('assets/images/weightScale1.png'),
              Positioned(
                top: SizeConfig.safeBlockVertical! * 2,
                left: SizeConfig.safeBlockHorizontal! * 35.5,
                child: Text((_scrollPosition / 10).toStringAsFixed(1) + ' Kg',
                    style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: SizeConfig.safeBlockVertical! * 7,
                left: SizeConfig.safeBlockHorizontal! * 45,
                child: Image.asset('assets/images/scaleMarker.png'),
              ),
              Positioned(
                top: SizeConfig.blockSizeVertical! * 4.5,
                right: SizeConfig.blockSizeHorizontal! * 7,
                left: SizeConfig.blockSizeHorizontal! * 2,
                bottom: 0,
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: a.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: SizeConfig.blockSizeVertical! * 40,
                      child: Image.asset(a[index]),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    // for (var d in eves1) {
    //   _selectedDays.add(d);
    // }

    _controller = ScrollController();
    _controller?.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller?.jumpTo(500);
    });
  }

  // ignore: always_declare_return_types
  checkNext(day) {
    var i =
        _selectedDays.toList().indexWhere((element) => element.day == day.day);
    return _selectedDays
                .toList()[i + 1]
                .difference(_selectedDays.toList()[i])
                .inDays >
            1
        ? true
        : false;
  }

  // ignore: always_declare_return_types
  checklast(day) {
    var i =
        _selectedDays.toList().indexWhere((element) => element.day == day.day);
    return _selectedDays
                .toList()[i]
                .difference(_selectedDays.toList()[i - 1])
                .inDays >
            1
        ? true
        : false;
  }

  matchDay(d) {
    return DateFormat.yMMMMd().format(DateTime.parse(d)) ==
            DateFormat.yMMMMd().format(DateTime.now())
        ? true
        : false;
  }

  @override
  Widget build(BuildContext context) {
    for (var d in weightData?.weightTracker?.weightHistory?.date ?? []) {
      if (weightData?.weightTracker?.weightHistory?.actualWeight?.first != 0 &&
          matchDay(d) == false) {
        _selectedDays.add(DateTime.parse(d));
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Weight Calendar',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.black,
            size: SizeConfig.blockSizeVertical! * 2,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                // padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TableCalendar(
                      calendarBuilders: CalendarBuilders(
                        todayBuilder: (context, date, _) {
                          return Container(
                            child: Center(child: Text(date.day.toString())),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30))),
                          );
                        },
                        selectedBuilder: (context, date, _) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: date.day == DateTime.now().day
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30))
                                    : _selectedDays.toList().last.day ==
                                            date.day
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            bottomLeft: Radius.circular(30))
                                        : _selectedDays.toList().first.day ==
                                                date.day
                                            ? const BorderRadius.only(
                                                topRight: Radius.circular(30),
                                                bottomRight:
                                                    Radius.circular(30))
                                            : const BorderRadius.only(
                                                topRight: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(0)),
                                color: Colors.blue[100]),
                            child: Center(child: Text(date.day.toString())),
                          );
                        },
                      ),
                      // ignore: unnecessary_lambdas
                      selectedDayPredicate: (day) {
                        // Use values from Set to mark multiple days as selected
                        return _selectedDays.contains(day);
                      },
                      // onDaySelected: _onDaySelected,
                      // ignore: unnecessary_lambdas
                      eventLoader: (day) {
                        return _getEventsForDay(day);
                      },
                      headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      currentDay: DateTime.now(),
                      focusedDay: DateTime.now(),
                    ),
                    sBox(h: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 4,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.blue[200],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          sBox(w: 2),
                          const Text(
                            'Streaks',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          sBox(w: 10),
                          Container(
                            width: 10,
                            height: 22,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle
                                // borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                          ),
                          sBox(w: 2),
                          const Text(
                            'Missed',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    sBox(h: 2),
                  ],
                )),
            sBox(h: 2),
            weightPicker()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            if (canClick) {
              canClick = false;
              setState(() async {
                if (DateFormat.yMMMd().format(DateTime.parse(weightData
                            .weightTracker?.weightHistory?.date?.first)) !=
                        DateFormat.yMMMd().format(DateTime.now()) &&
                    widget.firstTime != true) {
                  await weightData.postDailyWeight(
                      context: context,
                      weight: double.parse(
                          (_scrollPosition / 10).toStringAsFixed(1)));
                  await Provider.of<ProgressTrackingVM>(context, listen: false)
                      .fetchImages()
                      .then((value) {
                    canClick = true;
                    Navigator.of(context).pop();
                  });
                } else {
                  await Fluttertoast.showToast(
                      msg: 'Already Updated For Today!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white);
                }
              });
            }
          },
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

// List eves = [
//   DateTime.utc(2021, 12, 1),
//   DateTime.utc(2021, 12, 6),
//   DateTime.utc(2021, 12, 7),
//   DateTime.utc(2021, 12, 8),
//   DateTime.utc(2021, 12, 11),
// ];

createMissingEvents() {
  var month = DateTime.now().month;
  var year = DateTime.now().year;
  var daysPassed = DateTime.now().difference(DateTime(year, month, 1)).inDays;

  List days = [];
  for (int i = 1; i <= daysPassed; i++) {
    print(DateTime.utc(year, month, i));
    // days.add(DateTime.utc(year, month, i));
    if (!_selectedDays.contains(DateTime(year, month, i))) {
      days.add(DateTime.utc(year, month, i));
    }
  }
  return days;
}

List eves = createMissingEvents();

final _kEventSource = { for (var item in List.generate(eves.length, (index) => index)) DateTime.utc(eves[item].year, eves[item].month, eves[item].day) : List.generate(1, (index) => Event('Event $item | ${index + 1}')) }
  ..addAll({});

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
