part of 'default_dialogs.dart';

Future<dynamic> showDefaultGroupMemberListDialog(BuildContext context, String groupID) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  ValueListenableBuilder(
                      valueListenable: ZIMKit().queryGroupMemberCount(groupID),
                      builder: (BuildContext context, int groupMemberCount, Widget? _) {
                        return Text(
                          'Member List($groupMemberCount)',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        );
                      }),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              ValueListenableBuilder(
                  valueListenable: ZIMKit().queryGroupMemberList(groupID),
                  builder: (BuildContext context, List<ZIMGroupMemberInfo> memberList, Widget? child) {
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const Divider(color: Colors.transparent),
                          scrollDirection: Axis.vertical,
                          itemCount: memberList.length,
                          itemBuilder: (context, index) {
                            final memberItem = memberList[index];
                            final memberItemIsMe = memberItem.userID == ZIMKit().currentUser()!.baseInfo.userID;
                            final memberItemName =
                                memberItem.memberNickname.isNotEmpty ? memberItem.memberNickname : memberItem.userName;
                            return GestureDetector(
                              onTap: () async {
                                debugPrint('click member: ${memberItem.userID}');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    CachedNetworkImage(
                                      width: 60,
                                      height: 60,
                                      imageUrl: memberItem.memberAvatarUrl.isEmpty
                                          ? 'https://robohash.org/${memberItem.userID}.png?set=set4'
                                          : memberItem.memberAvatarUrl,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder: (__, _, ___) =>
                                          CircleAvatar(child: Text(memberItemName[0])),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(children: [
                                            Text(memberItemName, maxLines: 1, overflow: TextOverflow.clip),
                                            Text(memberItem.memberRole == ZIMGroupMemberRole.owner ? '(Owner)' : ''),
                                            Text(memberItemIsMe ? '(Me)' : ''),
                                          ]),
                                          Text('ID:${memberItem.userID}'),
                                        ]),
                                  ]),
                                  Row(children: [
                                    ValueListenableBuilder(
                                      valueListenable: ZIMKit().queryGroupOwner(groupID),
                                      builder: (context, ZIMGroupMemberInfo? owner, _) {
                                        final imGroupOwner = owner?.userID == ZIMKit().currentUser()?.baseInfo.userID;
                                        if (!memberItemIsMe) {
                                          return PopupMenuButton(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            position: PopupMenuPosition.under,
                                            icon: const Icon(Icons.more_horiz),
                                            itemBuilder: (context) {
                                              return [
                                                if (imGroupOwner) ...[
                                                  PopupMenuItem(
                                                    child: const ListTile(
                                                        leading: Icon(Icons.group_remove), title: Text('Remove User')),
                                                    onTap: () =>
                                                        ZIMKit().removeUesrsFromGroup(groupID, [memberItem.userID]),
                                                  ),
                                                  PopupMenuItem(
                                                    child: const ListTile(
                                                        leading: Icon(Icons.group_remove),
                                                        title: Text('Transfer Group Owner')),
                                                    onTap: () =>
                                                        ZIMKit().transferGroupOwner(groupID, memberItem.userID),
                                                  ),
                                                ],
                                                PopupMenuItem(
                                                  child: const ListTile(
                                                      leading: Icon(Icons.chat), title: Text('Private Chat')),
                                                  onTap: () {
                                                    Navigator.pushReplacement(context,
                                                        MaterialPageRoute(builder: (context) {
                                                      return DemoCahttingMessageListPage(
                                                        conversationID: memberItem.userID,
                                                        conversationType: ZIMConversationType.group,
                                                      );
                                                    }));
                                                  },
                                                ),
                                              ];
                                            },
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    )
                                  ]),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
            ],
          ),
        );
      });
}
