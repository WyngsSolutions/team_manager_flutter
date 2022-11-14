// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/app_user.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';
import '../member_screens/member_home_screen.dart';
import '../sign_in/sign_in.dart';

class SplashScreen extends StatefulWidget {
  
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      checkIfUserSaved();
    });
  }

  void checkIfUserSaved() async {
    Constants.appUser = await AppUser.getUserDetail();
    if(Constants.appUser.email.isNotEmpty)
    {
      Constants.appUser = await AppUser.getLoggedInUserDetail(Constants.appUser);
      if(!Constants.appUser.isMember)
        Get.offAll(HomeScreen(defaultPage: 0,));
      else
        Get.offAll(MemberHomeScreen(defaultPage: 0,));
    }
    else
    {
      Get.offAll(SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Constants.appThemeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*10),
              height: SizeConfig.blockSizeVertical *25,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Image.asset('assets/team.png'),
            ),
          ]
        ),
      )
    );
  }
}
