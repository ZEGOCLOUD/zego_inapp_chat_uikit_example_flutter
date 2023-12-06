import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'home_page.dart';
import 'main.dart';

const demoChannelID = 'your channel id';
const demoChannelName = 'your channel name';

class NotificationManager {
  factory NotificationManager() => instance;
  NotificationManager._internal();
  static NotificationManager instance = NotificationManager._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool isAppInBackground = false;
  int notificationID = 1;

  Future<void> init() async {
    ZIMKit().getOnMessageReceivedNotifier().addListener(_onMessageArrived);

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      const channel = AndroidNotificationChannel(
        demoChannelID,
        demoChannelName,
        description: 'your channel description',
        importance: Importance.high,
        enableVibration: true,
        showBadge: false,
        playSound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/notification_icon'),
        iOS: DarwinInitializationSettings(
            // requestSoundPermission: true,
            // requestBadgePermission: false,
            // requestAlertPermission: false,
            ),
      ),
      onDidReceiveNotificationResponse: onNotificationTappedBackground,
      onDidReceiveBackgroundNotificationResponse: onNotificationTappedBackground,
    );
  }

  Future<void> uninit() async {
    ZIMKit().getOnMessageReceivedNotifier().removeListener(_onMessageArrived);
  }

  Future<void> _onMessageArrived() async {
    final messages = ZIMKit().getOnMessageReceivedNotifier().value;
    if (messages == null) return;
    showNotifications(messages);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('cancelAllNotifications');
  }

  Future<void> showNotifications(ZIMKitReceivedMessages messages) async {
    messages.receiveMessages.forEach((message) async {
      var content = '[${message.type.name}]';
      if (ZIMKitMessageType.text == message.type) {
        content = message.textContent?.text ?? '';
      }

      var senderName = '';
      await ZIMKit().queryUser(message.info.senderUserID).then((ZIMUserFullInfo zimResult) {
        senderName = zimResult.baseInfo.userName;
      });

      await flutterLocalNotificationsPlugin.show(
        notificationID,
        senderName,
        content,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            demoChannelID,
            demoChannelName,
            channelDescription: 'your channel description',
            priority: Priority.high,
            importance: Importance.high,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode({'id': messages.id, 'typeIndex': messages.type.index}),
      );

      notificationID++;
    });
  }

  static void onNotificationTappedBackground(NotificationResponse response) {
    debugPrint('onNotificationTappedBackground ${response.payload}');
    NotificationManager().cancelAllNotifications();

    try {
      final Map payload = jsonDecode(response.payload!);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) {
            return demoMessageListPageID(
              navigatorKey.currentContext!,
              id: payload['id'],
              type: ZIMConversationType.values[payload['typeIndex']],
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('decode error $e');
    }
  }
}
