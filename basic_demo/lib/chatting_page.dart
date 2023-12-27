import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'chatting_page_actions.dart';
import 'notification.dart';

class DemoCahttingMessageListPage extends StatefulWidget {
  const DemoCahttingMessageListPage({
    Key? key,
    required this.conversationID,
    required this.conversationType,
  }) : super(key: key);

  final String conversationID;
  final ZIMConversationType conversationType;

  @override
  State<DemoCahttingMessageListPage> createState() => _DemoCahttingMessageListPageState();
}

class _DemoCahttingMessageListPageState extends State<DemoCahttingMessageListPage> {
  List<StreamSubscription> sbuscriptions = [];

  // In the initState method, subscribe the event.
  @override
  void initState() {
    sbuscriptions = [
      if (widget.conversationType == ZIMConversationType.group)
        ZIMKit().getGroupStateChangedEventStream().listen(onGroupStateChangedEvent)
    ];
    // When on the chat page, the notification for that chat page is not displayed.
    NotificationManager().ignoreConversationID = widget.conversationID;
    super.initState();
  }

  // When the widget is disposed, please remember to cancel subscribe.
  @override
  void dispose() {
    for (final element in sbuscriptions) {
      element.cancel();
    }
    // After exiting the chat page, if the conversation continues to receive messages, the notification of the chat page needs to be displayed.
    NotificationManager().ignoreConversationID = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZIMKitMessageListPage(
      conversationID: widget.conversationID,
      conversationType: widget.conversationType,
      onMessageSent: (ZIMKitMessage message) {
        if (message.info.error != null) {
          debugPrint('onMessageSent error: ${message.info.error!.message}, ${message.info.error!.code}');
        } else {
          debugPrint('onMessageSent: ${message.type.name}');
        }
      },
      appBarActions: demoAppBarActions(context, widget.conversationID, widget.conversationType),
      onMessageItemLongPress: onMessageItemLongPress,
      messageListBackgroundBuilder: (context, defaultWidget) {
        return const ColoredBox(color: Colors.white);
      },
    );
  }

  Future<void> onGroupStateChangedEvent(ZIMKitEventGroupStateChanged event) async {
    debugPrint('getGroupStateChangedEventStream: $event');
    // If you need to automatically exit the page and delete a group
    // conversation that is already in the 'quit' state,
    // you can use this code here.

    // if ((event.groupInfo.baseInfo.id == widget.conversationID) && (event.state == ZIMGroupState.quit)) {
    //   debugPrint('app deleteConversation: $event');
    //   await ZIMKit().deleteConversation(widget.conversationID, widget.conversationType);
    //   if (mounted) {
    //     Navigator.pop(context);
    //   }
    // }
  }
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
        title: const Text('Confirm'),
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
