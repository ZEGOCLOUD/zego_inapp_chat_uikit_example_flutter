import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'chat_page_actions.dart';
import 'constants.dart';
import 'login_page.dart';
import 'main.dart';
import 'popup_home_page.dart';

class ZIMKitDemoHomePage extends StatefulWidget {
  const ZIMKitDemoHomePage({Key? key}) : super(key: key);

  @override
  State<ZIMKitDemoHomePage> createState() => _ZIMKitDemoHomePageState();
}

class _ZIMKitDemoHomePageState extends State<ZIMKitDemoHomePage> {
  var currentPageIndex = ValueNotifier<int>(0);
  var pages = <Widget>[];

  @override
  void initState() {
    super.initState();

    pages = [
      chatsPage(),
      profilePage(),
    ];
  }

  Widget chatsPage() {
    return ZIMKitConversationListView(
      onPressed: (context, conversation, defaultAction) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return demoMessageListPage(
              context,
              conversation,
            );
          },
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [HomePagePopupMenuButton()],
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: currentPageIndex,
          builder: (context, pageIndex, _) {
            return IndexedStack(index: pageIndex, children: pages);
          },
        ),
        // bottomNavigationBar: bottomNavigationBar(),
        bottomNavigationBar: ValueListenableBuilder(
            valueListenable: currentPageIndex,
            builder: (context, pageIndex, _) {
              return NavigationBar(
                selectedIndex: currentPageIndex.value,
                destinations: [
                  ValueListenableBuilder<int>(
                      valueListenable: ZIMKit().getTotalUnreadMessageCount(),
                      builder: (context, unreadMessageCount, _) {
                        return NavigationDestination(
                          icon: Badge.count(
                            count: unreadMessageCount,
                            isLabelVisible: unreadMessageCount > 0,
                            child: const Icon(Icons.home_outlined),
                          ),
                          selectedIcon: Badge.count(
                            count: unreadMessageCount,
                            isLabelVisible: unreadMessageCount > 0,
                            child: const Icon(Icons.home),
                          ),
                          label: 'Chats',
                        );
                      }),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Me',
                  ),
                ],
                onDestinationSelected: (index) => currentPageIndex.value = index,
              );
            }),
      ),
    );
  }

  Widget profilePage() {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            leading: SizedBox(
              height: 40,
              width: 40,
              child: CachedNetworkImage(
                imageUrl: 'https://robohash.org/${currentUser.id}.png?set=set4',
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(
                  value: downloadProgress.progress,
                ),
                errorWidget: (context, url, error) {
                  return const Icon(Icons.person);
                },
              ),
            ),
            title: Text(currentUser.name),
            subtitle: Text('ID:${currentUser.id}'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ZIMKit().disconnectUser();
              onUserLogout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ZIMKitDemoLoginPage(),
                  ),
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

Widget demoMessageListPage(
  BuildContext context,
  ZIMKitConversation conversation,
) {
  return ZIMKitMessageListPage(
    conversationID: conversation.id,
    conversationType: conversation.type,
    onMessageSent: (ZIMKitMessage message) {
      if (message.info.error != null) {
        debugPrint('onMessageSent error: ${message.info.error!.message}, ${message.info.error!.code}');
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

Widget demoMessageListPageID(
  BuildContext context, {
  required String id,
  ZIMConversationType type = ZIMConversationType.peer,
}) =>
    demoMessageListPage(
      context,
      ZIMKitConversation()
        ..type = type
        ..id = id,
    );
