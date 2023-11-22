import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'constants.dart';
import 'home_page.dart';
import 'main.dart';
import 'utils.dart';

class ZIMKitDemoLoginPage extends StatefulWidget {
  const ZIMKitDemoLoginPage({Key? key}) : super(key: key);

  @override
  State<ZIMKitDemoLoginPage> createState() => _ZIMKitDemoLoginPageState();
}

class _ZIMKitDemoLoginPageState extends State<ZIMKitDemoLoginPage> {
  /// Users who use the same callID can in the same call.
  final userID = TextEditingController(text: 'user_id');
  final userName = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    getUniqueUserId().then((_userID) async {
      setState(() {
        userID.text = _userID;
        userName.text = randomName(key: _userID);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: userID,
                        decoration: const InputDecoration(labelText: 'user ID'),
                      ),
                      TextFormField(
                        controller: userName,
                        decoration: const InputDecoration(labelText: 'user name'),
                      ),
                      const SizedBox(height: 20),
                      loginButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () async {
        await ZIMKit()
            .connectUser(
          id: userID.text,
          name: userName.text,
          avatarUrl: 'https://robohash.org/${userID.text}.png?set=set4',
        )
            .then((errorCode) async {
          if (errorCode == 0) {
            /// cache login user info
            final prefs = await SharedPreferences.getInstance();
            prefs.setString(cacheUserIDKey, userID.text);
            currentUser.id = userID.text;
            currentUser.name = userName.text;

            onUserLogin(userID.text, userName.text);
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ZIMKitDemoHomePage(),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'login failed, errorCode: $errorCode',
                  ),
                ),
              );
            }
          }
        });
      },
      child: const Text('login'),
    );
  }
}
