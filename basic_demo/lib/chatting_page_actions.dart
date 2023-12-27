import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'demo_widgets/default_dialogs.dart';

List<Widget>? demoAppBarActions(BuildContext context, String id, ZIMConversationType type) {
  return type == ZIMConversationType.peer
      ? peerChatCallButtons(context, id, type)
      : [GroupPagePopupMenuButton(groupID: id)];
}

List<Widget> peerChatCallButtons(
  BuildContext context,
  String id,
  ZIMConversationType type,
) {
  return [
    for (final isVideoCall in [true, false])
      ZegoSendCallInvitationButton(
        iconSize: const Size(40, 40),
        buttonSize: const Size(50, 50),
        isVideoCall: isVideoCall,
        resourceID: 'zego_data',
        invitees: [ZegoUIKitUser(id: id, name: ZIMKit().getConversation(id, type).value.name)],
        onPressed: (String code, String message, List<String> errorInvitees) {
          onCallInvitationSent(context, code, message, errorInvitees);
        },
      )
  ];
}

void onCallInvitationSent(BuildContext context, String code, String message, List<String> errorInvitees) {
  var log = '';
  if (errorInvitees.isNotEmpty) {
    log = "User doesn't exist or is offline: ${errorInvitees[0]}";
    if (code.isNotEmpty) {
      log += ', code: $code, message:$message';
    }
  } else if (code.isNotEmpty) {
    log = 'code: $code, message:$message';
  }
  if (log.isEmpty) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(log)),
  );
}

class GroupPagePopupMenuButton extends StatefulWidget {
  const GroupPagePopupMenuButton({Key? key, required this.groupID}) : super(key: key);

  final String groupID;

  @override
  State<GroupPagePopupMenuButton> createState() => _GroupPagePopupMenuButtonState();
}

class _GroupPagePopupMenuButtonState extends State<GroupPagePopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ZIMKit().queryGroupOwner(widget.groupID),
      builder: (context, ZIMGroupMemberInfo? owner, _) {
        final imGroupOwner = owner?.userID == ZIMKit().currentUser()?.baseInfo.userID;
        return PopupMenuButton(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          position: PopupMenuPosition.under,
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'Add Member',
                child: const ListTile(leading: Icon(Icons.group_add), title: Text('Add User', maxLines: 1)),
                onTap: () => showDefaultAddUserToGroupDialog(context, widget.groupID),
              ),
              if (imGroupOwner)
                PopupMenuItem(
                  value: 'Remove Member',
                  child: const ListTile(leading: Icon(Icons.group_remove), title: Text('Remove User', maxLines: 1)),
                  onTap: () => showDefaultRemoveUserFromGroupDialog(context, widget.groupID),
                ),
              PopupMenuItem(
                value: 'Member List',
                child: const ListTile(leading: Icon(Icons.people), title: Text('Member List', maxLines: 1)),
                onTap: () => showDefaultGroupMemberListDialog(context, widget.groupID),
              ),
              PopupMenuItem(
                value: 'Leave Group',
                child: const ListTile(leading: Icon(Icons.logout), title: Text('Leave Group', maxLines: 1)),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text('Do you want to leave this group?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ZIMKit().leaveGroup(widget.groupID);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (imGroupOwner)
                PopupMenuItem(
                  value: 'Disband Group',
                  child: const ListTile(leading: Icon(Icons.close), title: Text('Disband Group', maxLines: 1)),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text('Do you want to disband this group?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ZIMKit().disbandGroup(widget.groupID);
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ];
          },
        );
      },
    );
  }
}
