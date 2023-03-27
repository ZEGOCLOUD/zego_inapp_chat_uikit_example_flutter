import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

import 'package:zego_zimkit_demo/home_page_popup.dart';

class ZIMKitDemoHomePage extends StatelessWidget {
  const ZIMKitDemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [HomePagePopupMenuButton()],
        ),
        body: ZIMKitConversationListView(
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                  appBarActions: conversation.type == ZIMConversationType.peer
                      ? [
                          for (final isVideoCall in [true, false])
                            ZegoSendCallInvitationButton(
                              iconSize: const Size(40, 40),
                              buttonSize: const Size(50, 50),
                              isVideoCall: isVideoCall,
                              invitees: [ZegoUIKitUser(id: conversation.id, name: conversation.name)],
                              onPressed: (String code, String message, List<String> errorInvitees) {
                                onCallInvitationSent(context, code, message, errorInvitees);
                              },
                            ),
                        ]
                      : [],
                );
              },
            ));
          },
        ),
      ),
    );
  }

  void onCallInvitationSent(BuildContext context, String code, String message, List<String> errorInvitees) {
    late String log;
    if (errorInvitees.isNotEmpty) {
      log = "User doesn't exist or is offline: ${errorInvitees[0]}";
      if (code.isNotEmpty) {
        log += ', code: $code, message:$message';
      }
    } else if (code.isNotEmpty) {
      log = 'code: $code, message:$message';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(log)),
    );
  }
}
