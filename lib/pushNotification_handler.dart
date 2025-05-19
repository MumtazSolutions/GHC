import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var screenName = 'home';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('Handling a background message ');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Application extends StatefulWidget {
  final Widget page;
  const Application({super.key, required this.page});
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  Future<void> requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
  }

  void getFcmToken() {
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint('fcm =  $token');
      // AppUser.myFcmToken = token!;
    });
  }

  Future<void> handlePushNavigation(Map data) async {
    debugPrint(' handlePushNavigation notification with type ');
  }

  Future<void> onInit() async {
    await requestPermissions();

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        log('msg: $message');
        _handleMessage(message);
      }
    });
    getFcmToken();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('test notification');
      debugPrint((message!.data['message_data']).toString());
      print((message!.data['message_data']).toString());
      RemoteNotification? notification = message.notification;

      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        unawaited(flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                priority: Priority.max,
                importance: Importance.max,
                icon: '@mipmap/launcher_icon',
              ),
            )));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    debugPrint('THIS IS MESSAGE');
    debugPrint(message.data.toString());
    await handlePushNavigation(message.data);
  }

  @override
  void didChangeDependencies() {
    onInit();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.page;
  }
}
