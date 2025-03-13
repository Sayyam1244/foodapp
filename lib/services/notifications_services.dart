import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServies {
  static final NotificationServies _notificationServies =
      NotificationServies._internal();
  factory NotificationServies() {
    return _notificationServies;
  }

  NotificationServies._internal();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> permission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'our_notification_channel',
    'our channel',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );
//AIzaSyCNOwAsoA8vCB-bzW_0Sk_sIay_a8NBeIo
  Future<void> setupFlutterNotifications() async {
    permission();
    //
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.subscribeToTopic('all');
    log('fcmToken: $fcmToken');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    //
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    //
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        log('message');
        // ontapNotification(
        //     message: jsonDecode(details.payload!),
        //     context: navigatorKey.currentContext);
      },
    );
    // FirebaseMessaging.onBackgroundMessage(registerBackgroundMessage);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    //
    FirebaseMessaging.onMessage.listen(
      (event) async {
        //
        showFlutterNotification(event);
      },
    );
  }

  Future<void> showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          playSound: true,
          message.notification?.android?.channelId ?? '',
          channel.name,
          channelDescription: channel.description,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static ontapNotification(
      {required Map<String, dynamic> message, BuildContext? context}) {}

//   ontapNotificationHandlers() async {
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (initialMessage != null) {
//       ontapNotification(
//           message: initialMessage.data, context: navigatorKey.currentContext);
//     } else {
//       print("initialMessage is Empty ${initialMessage?.messageId ?? ''}");
//     }
//     FirebaseMessaging.onMessageOpenedApp.listen(
//       (event) {
//         print('bg $event');
//         ontapNotification(
//             message: event.data, context: navigatorKey.currentContext);
//       },
//     );
//   }
}
