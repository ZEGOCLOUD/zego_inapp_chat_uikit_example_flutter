import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'constants.dart';
import 'login_page.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
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
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                  value: downloadProgress.progress,
                ),
                errorWidget: (_, url, error) => const Icon(Icons.person),
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
