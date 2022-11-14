
// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, avoid_print, use_key_in_widget_constructors
import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../chatlist_screen/chatlist_screen.dart';
import '../members_list/members_list.dart';
import '../project_list/project_list.dart';
import '../settings_screen/settings_screen.dart';
import 'member_requests.dart';
import 'member_tasks_screen.dart';
import 'members_projects_list.dart';

class MemberHomeScreen extends StatefulWidget {

  final int defaultPage;
  const MemberHomeScreen({required this.defaultPage});

  @override
  _MemberHomeScreenState createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
 
  int _pageIndex = 0;
  late PageController _pageController;
  bool isUserSignedIn = false;
  List<Widget> tabPages =[];
  //
  //*******ONE SIGNAL*******\\
  bool requireConsent = false;
  static String userId = "";

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.defaultPage;
    tabPages = [
      const MemebersProjectList(),
      const MemberTasksScreen(),
      const MemberAnnouncementList(),
      const ChatListScreen(),
      const SettingsScreen(),
    ];
    _pageController = PageController(initialPage: _pageIndex);
    initPlatformState();
  }

  ///******* INITIAL METHOD ****************///  
  Future<void> initPlatformState() async {

  //   OneSignal.shared.setRequiresUserPrivacyConsent(requireConsent);

  //   var settings = {
  //     OSiOSSettings.autoPrompt: false,
  //     OSiOSSettings.promptBeforeOpeningPushUrl: true
  //   };

  //   if(Platform.isIOS)
  //   {
  //     await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  //   }
    
  //   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  //     print(changes.to.status);
  //   });

  //   OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
  //       print('FOREGROUND HANDLER CALLED WITH: ${event}');
  //       /// Display Notification, send null to not display
  //       event.complete(null);
  //       // this.setState(() {_debugLabelString = "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  //       // //NotificationHandler.checkRecievedNotification(event.notification, context);
  //       // });
  //   });  

  //   OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
  //       print('FOREGROUND HANDLER CALLED WITH: ${event}');
  //       /// Display Notification, send null to not display
  //       event.complete(null);
  //       //this.setState(() {_debugLabelString = "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  //       //NotificationHandler.checkRecievedNotification(event.notification, context);
  //       Get.snackbar(
  //         Constants.appName,
  //         "${event.notification.body}",
  //         duration: const Duration(seconds: 3),
  //         animationDuration: const Duration(milliseconds: 800),
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Constants.appThemeColor,
  //         colorText: Colors.white,
  //       );
  //    // });
  //   });  

  //   OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
  //     print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
  //     //print("SUBSCRIPTION STATE CHANGED: ${changes.to.subscribed} -----  ${changes.to.pushToken} ----- ${changes.to.userId}");
  //     if(changes.to.userId!.isNotEmpty) {
  //       userId = changes.to.userId!;
  //       saveUserTokenOnServer();
  //     }
  //   });

  //   print(Constants.oneSignalId);
  //   await OneSignal.shared.setAppId(Constants.oneSignalId);
  //   //await OneSignal.shared.init(Constants.oneSignalId, iOSSettings: settings);
  //   //OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  //   var status = await OneSignal.shared.getDeviceState();
  //   if(status!.subscribed){
  //     userId = status.userId!;
  //     saveUserTokenOnServer();
  //   }
  // }

  // void saveUserTokenOnServer()async{
  //   print('Onesignal = $userId');
  //   if(Constants.appUser.email.isNotEmpty && Constants.appUser.oneSignalUserId.isEmpty)
  //   {
  //     Constants.appUser.oneSignalUserId = userId;
  //     AppUser().updateOneSignalToken(userId);
  //   }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _pageIndex = page;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _pageIndex = index;
    });

    _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: tabPages[_pageIndex],
      bottomNavigationBar: Container(
        height: (Platform.isIOS) ? SizeConfig.blockSizeVertical * 11 : SizeConfig.blockSizeVertical * 8,
        color: Colors.white,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _pageIndex,
          selectedItemColor: Constants.appThemeColor,
          unselectedItemColor: Colors.grey[300],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: SizeConfig.fontSize*1.6,
          selectedFontSize: SizeConfig.fontSize*1.6,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.7),
                child: Icon(Icons.home, size: SizeConfig.blockSizeVertical*3,)
              ),
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.7),
                child: Icon(Icons.list_alt, size: SizeConfig.blockSizeVertical*3,)
              ),
              label: 'My Tasks'
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.7),
                child: Icon(Icons.playlist_add_check_sharp, size: SizeConfig.blockSizeVertical*3,)
              ),
              label: 'My Requests'
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.7),
                child: Icon(Icons.chat, size: SizeConfig.blockSizeVertical*3,)
              ),
              label: 'Messages'
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.7),
                child: Icon(Icons.settings, size: SizeConfig.blockSizeVertical*3,)
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}