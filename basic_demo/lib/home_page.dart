import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'chat_page_actions.dart';
import 'popup_home_page.dart';

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
                return demoMessageListPage(context, conversation);
              },
            ));
          },
        ),
      ),
    );
  }
}

Widget demoMessageListPage(BuildContext context, ZIMKitConversation conversation) {
  return ZIMKitMessageListPage(
    conversationID: conversation.id,
    conversationType: conversation.type,
    onMessageSent: (ZIMKitMessage message) {
      if (message.info.error != null) {
        debugPrint(
            'onMessageSent error: ${message.info.error!.message}, ${message.info.error!.code}');
      } else {
        debugPrint('onMessageSent: ${message.type.name}');
      }
    },
    appBarActions: demoAppBarActions(context, conversation),
    onMessageItemLongPress: onMessageItemLongPress,
    messageListBackgroundBuilder: (context, defaultWidget) {
      return const ColoredBox(color: Colors.white);
    },
  );
}

Future<void> onMessageItemLongPress(
  BuildContext context,
  LongPressStartDetails details,
  ZIMKitMessage message,
  Function defaultAction,
) async {
  showCupertinoDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Confirme'),
        content: const Text('Delete or recall this message?'),
        actions: [
          CupertinoDialogAction(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              ZIMKit().deleteMessage([message]);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              ZIMKit().recallMessage(message).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Recall'),
          ),
        ],
      );
    },
  );
}
