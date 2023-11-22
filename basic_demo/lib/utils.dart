import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

String randomName({
  String? key,
}) {
  final names = [
    'Aaliyah',
    'Abigail',
    'Addison',
    'Adrian',
    'Adriana',
    'Aiden',
    'Alanis',
    'Alexander',
    'Alexandra',
    'Alexis',
    'Allison',
    'Alondra',
    'Alyssa',
    'Amanda',
    'Amelia',
    'Andrea',
    'Andrew',
    'Angel',
    'Anna',
    'Anthony',
    'Aria',
    'Ariana',
    'Ashley',
    'Aspen',
    'Aubree',
    'Aubrey',
    'Aurora',
    'Austin',
    'Ava',
    'Avery',
    'Benjamin',
    'Bentley',
    'Brantley',
    'Braxton',
    'Brayden',
    'Brianna',
    'Bridger',
    'Brody',
    'Brooklyn',
    'Caleb',
    'Cameron',
    'Camila',
    'Carlos',
    'Caroline',
    'Carter',
    'Charles',
    'Charlotte',
    'Charlottte',
    'Chase',
    'Chloe',
    'Christian',
    'Christopher',
    'Claire',
    'Colton',
    'Connor',
    'Cooper',
    'Daniel',
    'David',
    'Diego',
    'Dylan',
    'Easton',
    'Eleanor',
    'Eli',
    'Elijah',
    'Elizabeth',
    'Ella',
    'Ellie',
    'Emily',
    'Emma',
    'Ethan',
    'Evan',
    'Evelyn',
    'Ezekiel',
    'Ezra',
    'Faith',
    'Gabriel',
    'Gabriela',
    'Gabriella',
    'Gavin',
    'Genesis',
    'Gianna',
    'Grace',
    'Grayson',
    'Hadley',
    'Hailey',
    'Hannah',
    'Harper',
    'Hazel',
    'Henry',
    'Hudson',
    'Hunter',
    'Ian',
    'Isaac',
    'Isabella',
    'Isaiah',
    'Jace',
    'Jack',
    'Jackson',
    'Jacob',
    'James',
    'Jaxon',
    'Jayden',
    'Jeremiah',
    'Jesus',
    'John',
    'Jose',
    'Joseph',
    'Joshua',
    'Josiah',
    'Juan',
    'Julia',
    'Julian',
    'Kamila',
    'Katherine',
    'Kayla',
    'Kaylee',
    'Kevin',
    'Khloe',
    'Kingston',
    'Landon',
    'Layla',
    'Leah',
    'Levi',
    'Liam',
    'Lillian',
    'Lily',
    'Lincoln',
    'Logan',
    'Lucas',
    'Lucy',
    'Luis',
    'Luke',
    'Lydia',
    'Madison',
    'Makayla',
    'Mary',
    'Mason',
    'Matthew',
    'Maya',
    'Mia',
    'Micah',
    'Michael',
    'Mila',
    'Naomi',
    'Natalie',
    'Nathan',
    'Nevaeh',
    'Nicholas',
    'Nicole',
    'Noah',
    'Nora',
    'Oakley',
    'Oliver',
    'Olivia',
    'Owen',
    'Paisley',
    'Paola',
    'Parker',
    'Piper',
    'Riley',
    'Robert',
    'Ruby',
    'Ryan',
    'Ryker',
    'Sadie',
    'Samantha',
    'Samuel',
    'Sarah',
    'Savannah',
    'Sawyer',
    'Scarlett',
    'Sebastian',
    'Serenity',
    'Skylar',
    'Sofia',
    'Sophia',
    'Taylor',
    'Theodore',
    'Tyler',
    'Valeria',
    'Victoria',
    'William',
    'Wyatt',
    'Ximena',
    'Yadiel',
    'Zoe',
    'Zoey'
  ];

  var nameIndex = Random().nextInt(names.length);
  if (key?.isNotEmpty ?? true) {
    var keyIndex = md5
        .convert(utf8.encode(key!))
        .toString()
        .replaceAll(RegExp(r'[^0-9]'), '');
    keyIndex = keyIndex.substring(keyIndex.length - 6);

    nameIndex = ((int.tryParse(keyIndex) ?? nameIndex) % names.length) + 1;
  }

  return names[nameIndex];
}

Future<String> getUniqueUserId() async {
  String? deviceID;
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final iosDeviceInfo = await deviceInfo.iosInfo;
    deviceID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    final androidDeviceInfo = await deviceInfo.androidInfo;
    deviceID = androidDeviceInfo.id; // unique ID on Android
  }

  if (deviceID != null && deviceID.length < 4) {
    if (Platform.isAndroid) {
      deviceID += '_android';
    } else if (Platform.isIOS) {
      deviceID += '_ios___';
    }
  }
  if (Platform.isAndroid) {
    deviceID ??= 'flutter_user_id_android';
  } else if (Platform.isIOS) {
    deviceID ??= 'flutter_user_id_ios';
  }

  final userID = md5
      .convert(utf8.encode(deviceID!))
      .toString()
      .replaceAll(RegExp(r'[^0-9]'), '');
  return userID.substring(userID.length - 6);
}
