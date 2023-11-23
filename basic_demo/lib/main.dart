import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'constants.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'notification.dart';
import 'utils.dart';

/// define a navigator key
final navigatorKey = GlobalKey<NavigatorState>();

const int yourAppID = ;
const String yourAppSign = ;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final cacheUserID = prefs.get(cacheUserIDKey) as String? ?? '';
  if (cacheUserID.isNotEmpty) {
    currentUser.id = cacheUserID;
    currentUser.name = randomName(key: cacheUserID);
  }

  /// init ZIMKit
  await ZIMKit().init(
    appID: yourAppID /*input your AppID*/,
    appSign: yourAppSign /*input your AppSign*/,
    notificationConfig: ZegoZIMKitNotificationConfig(
      resourceID: 'zego_data_zim',
      androidNotificationConfig: ZegoZIMKitAndroidNotificationConfig(
        channelID: 'ZIM Message',
        channelName: 'Message',
        sound: 'message',
        icon: 'notification_icon',
      ),
    ),
  );

  /// set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ZegoUIKit().initLog().then((value) {
    /// style of offline call
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(const ZIMKitDemo());
  });

  NotificationManager().init();
}

class ZIMKitDemo extends StatefulWidget {
  const ZIMKitDemo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ZIMKitDemoState();
}

class ZIMKitDemoState extends State<ZIMKitDemo> {
  bool autoConnectSuccess = false;
  var autoConnectDoneNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    if (currentUser.id.isNotEmpty) {
      ZIMKit()
          .connectUser(
        id: currentUser.id,
        name: currentUser.name,
        avatarUrl: 'https://robohash.org/${currentUser.id}.png?set=set4',
      )
          .then((errorCode) async {
        autoConnectSuccess = errorCode == 0;
        autoConnectDoneNotifier.value = true;

        if (errorCode == 0) {
          onUserLogin(currentUser.id, currentUser.name);
        }
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ZIMKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: currentUser.id.isEmpty ? const ZIMKitDemoLoginPage() : autoConnectting(),
    );
  }

  Widget autoConnectting() {
    return ValueListenableBuilder<bool>(
      valueListenable: autoConnectDoneNotifier,
      builder: (context, connectDone, _) {
        if (connectDone) {
          return autoConnectSuccess ? const ZIMKitDemoHomePage() : const ZIMKitDemoLoginPage();
        }

        /// waiting for the result of auto connect
        return const Stack(
          children: [
            /// only just show,forbid to interact
            AbsorbPointer(absorbing: true, child: ZIMKitDemoLoginPage()),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// on App's user login
void onUserLogin(String id, String name) {
  /// initialized ZegoUIKitPrebuiltCallInvitationService
  /// when app's user is logged in or re-logged in
  /// We recommend calling this method as soon as the user logs in to your app.
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: yourAppID /*input your AppID*/,
    appSign: yourAppSign /*input your AppSign*/,
    userID: id,
    userName: name,
    plugins: [ZegoUIKitSignalingPlugin()],
    androidNotificationConfig: ZegoAndroidNotificationConfig(
      channelID: 'ZegoUIKit',
      channelName: 'Call Notifications',
      sound: 'notification',
      icon: 'notification_icon',
      messageChannelID: 'Message',
      messageChannelName: 'Message',
      messageSound: 'message',
      messageIcon: 'notification_icon',
    ),
  );
}

/// on App's user logout
void onUserLogout() {
  /// de-initialization ZegoUIKitPrebuiltCallInvitationService
  /// when app's user is logged out
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}
