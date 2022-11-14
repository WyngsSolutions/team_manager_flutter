// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_user.dart';

class Constants {
  static final Constants _singleton =  Constants._internal();
  static String appName = "KV TeamManager";
  static late AppUser appUser;
  static bool isUserOnline = false;
  static bool isFirstTimeAppLaunched = true;
  static late Function callBackFunction;
  //ONE SIGNAL
  static String oneSignalId = "23c22bd9-4152-4323-94a2-733444eeb1f4";
  static String oneSignalRestKey = "ZmI2MTE0NTYtZjEyOC00YjVlLTk3OWUtMjNjYTcxOWI3NDY2";
  //COLORS
  static Color appThemeColor = Color(0XFF3b5998);
  static Color secondaryColor = Color(0XFFdd8162);
  static Color tertiaryColor = Color(0xFF747474);
  //
  static String iosAppLink = "https://apps.apple.com/us/app/team-manager-manage-tasks/id6443617577";
  static String androidAppLink = "https://play.google.com/store/apps/details?id=com.kv.teammanager.app";
  
  factory Constants() {
    return _singleton;
  }

  Constants._internal();

  static void showDialog(String message) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(appName),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }  

  static Future<File> resizePhotoIfBiggerThen1mb(File image) async{
    try{
      String userImage = ""; 
      List<int> imageBytes = image.readAsBytesSync();
      print(imageBytes.length);
      double kbSize = imageBytes.length/1024;
      if(kbSize >1000)
      {
        double quantity = (100 * 1024000)/imageBytes.length;
        print(quantity);
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savePath = appDocDir.path + "/" + DateTime.now().millisecond.toString() + ".jpg";
        var result = await FlutterImageCompress.compressAndGetFile(
          image.absolute.path, savePath,
          quality: quantity.toInt(),
        );
        print(savePath);
        return result!;
      }
      else
        return image;
    }
    catch(e){
      return image;
    }
  }

  // static Future clearDocumentTempImages() async{
  //   try{
  //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //     dynamic a = appDocDir.list();
  //     print(a);
  //     appDocDir.deleteSync(recursive: true);
  //     dynamic b = appDocDir.list();
  //     print(b);
  //   }
  //   catch(e){
  //     return;
  //   }
  // }

  static void showTitleAndMessageDialog(String title, String message) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('$title', style: TextStyle(fontWeight: FontWeight.w700),),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }
}
