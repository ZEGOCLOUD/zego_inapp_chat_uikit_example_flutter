import 'package:flutter/material.dart';

import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:zego_zimkit_demo/login_page.dart';
import 'package:zego_zimkit_demo/secret.dart';

void main() {
  ZIMKit().init(
    appID: YourSecret.appID, // your appid
    appSign: YourSecret.appSign, // your appSign
  );
  runApp(const ZIMKitDemo());
}

class ZIMKitDemo extends StatelessWidget {
  const ZIMKitDemo({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zego IMKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ZIMKitDemoLoginPage(),
    );
  }
}
