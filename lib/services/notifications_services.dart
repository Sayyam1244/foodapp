import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helloworld/main.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/menu/menu_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationServies {
  // Singleton instance
  static final NotificationServies _notificationServies = NotificationServies._internal();
  factory NotificationServies() {
    return _notificationServies;
  }

  NotificationServies._internal();

  // Local notifications plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Request notification permissions
  Future<void> permission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Notification channel for Android
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'our_notification_channel', // Channel ID
    'our channel', // Channel name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  // Setup notifications
  Future<void> setupFlutterNotifications() async {
    permission(); // Request permissions

    // Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('FCM Token: $fcmToken');
    // Create notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        log('message');
        // Handle notification tap
        ontapNotification(message: jsonDecode(details.payload!), context: navigatorKey.currentContext);
      },
    );

    // Set foreground notification options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(
      (event) async {
        showFlutterNotification(event);
      },
    );
  }

  // Show local notification
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
      payload: jsonEncode(message.data), // Pass data as payload
    );
  }

  // Handle notification tap
  static ontapNotification({required Map<String, dynamic> message, BuildContext? context}) async {
    final uid = message['uid']; // Extract user ID from message
    final userRes = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userModel = UserModel.fromMap(userRes.data()!);

    // Navigate to BusinessMenuScreen
    Navigator.of(navigatorKey.currentContext!).push(
      MaterialPageRoute(
        builder: (context) => BusinessMenuScreen(userModel: userModel),
      ),
    );
  }
}

// Send bulk notifications to users
Future<void> sendBulkNotifications({
  required String title,
  required String subtitle,
  required String type,
  required String dynamicId,
}) async {
  const String url = 'https://us-central1-foodsaverapp-8fb2d.cloudfunctions.net/sendBulkNotifications';

  try {
    // Send POST request to notification endpoint
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'subtitle': subtitle,
        'type': type,
        'dynamicId': dynamicId,
        'uid': FirebaseAuth.instance.currentUser!.uid, // Current user ID
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}
