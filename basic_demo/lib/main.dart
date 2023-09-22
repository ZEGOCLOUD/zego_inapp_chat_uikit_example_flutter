import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'login_page.dart';

const YourAppID = ;
const YourAppSign = ;

void main() {
  /// 1.1 init ZIMKit
  ZIMKit().init(
    appID: YourAppID, // your appid
    appSign: YourAppSign, // your appSign
  );

  /// 1.2 define a navigator key
  final navigatorKey = GlobalKey<NavigatorState>();

  /// 1.3: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  runApp(ZIMKitDemo(navigatorKey));
}

class ZIMKitDemo extends StatelessWidget {
  const ZIMKitDemo(this.navigatorKey, {Key? key}) : super(key: key);

  final GlobalKey<NavigatorState>? navigatorKey;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ZIMKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ZIMKitDemoLoginPage(),
    );
  }
}

/// on App's user login
void onUserLogin(String id, String name) {
  /// 2.1. initialized ZegoUIKitPrebuiltCallInvitationService
  /// when app's user is logged in or re-logged in
  /// We recommend calling this method as soon as the user logs in to your app.
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: YourAppID /*input your AppID*/,
    appSign: YourAppSign /*input your AppSign*/,
    userID: id,
    userName: name,
    plugins: [ZegoUIKitSignalingPlugin()],
  );
}

/// on App's user logout
void onUserLogout() {
  /// 2.2. de-initialization ZegoUIKitPrebuiltCallInvitationService
  /// when app's user is logged out
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}
