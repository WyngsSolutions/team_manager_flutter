// ignore_for_file: invalid_return_type_for_catch_error, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AppUser {
  
  String userId = "";
  String userName = "";
  String email = "";
  String password = "";
  bool isMember = false;
  String userPicture = "";
  String oneSignalUserId = "";

  AppUser({this.userId ="", this.userName="" , this.email="", this.password="", this.isMember = false, this.userPicture = "", this.oneSignalUserId = ""});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    AppUser user = AppUser(
      userId: json['userId'],
      userName : json['userName'],
      email : json['email'],
      userPicture: (json['userPicture'] == null) ? "" : json['userPicture'],
      oneSignalUserId: (json['oneSignalUserId'] == null) ? "" : json['oneSignalUserId'],
      isMember: (json['isMember'] == null) ? "" : json['isMember'],
    );
    return user;
  }

  Future saveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("UserId", userId);
    prefs.setString("UserName", userName);
    prefs.setString("UserEmail", email);
    prefs.setString("userPicture", userPicture);
    prefs.setString("oneSignalUserId", oneSignalUserId);
    prefs.setBool("isMember", isMember);
  }

  static Future<AppUser> getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppUser user = AppUser();
    user.userId = prefs.getString("UserId") ?? "";
    user.userName = prefs.getString("UserName") ?? "";
    user.email = prefs.getString("UserEmail") ?? "";    
    user.userPicture = prefs.getString("userPicture") ?? "";
    user.oneSignalUserId = prefs.getString("oneSignalUserId") ?? "";  
    user.isMember = prefs.getBool('isMember') ?? false;
    return user;
  }

  static Future deleteUserAndOtherPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future saveOneSignalUserID(String oneSignalId)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("OneSignalUserId", oneSignalId);
  }

  static Future getOneSignalUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("OneSignalUserId") ?? "";
  }

  ///*********FIRESTORE METHODS***********\\\\
  Future<dynamic> signUpUser(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(user.userId).set({
      'userId': user.userId,
      'userName': user.userName,
      'email': user.email,
      'userPicture' : user.userPicture,
      'oneSignalUserId' : '',
      'isMember' : user.isMember
    }).then((_) async {
      print("success!");
      await user.saveUserDetails();
      return user;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  static Future<dynamic> getLoggedInUserDetail(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(user.userId)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.data()!);
      userTemp.userId = user.userId;
      userTemp.password = user.password;
      await userTemp.saveUserDetails();
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  Future<dynamic> updateOneSignalToken(String oneSignalUserId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users")
    .doc(Constants.appUser.userId).update({
      'oneSignalUserId': oneSignalUserId,
    }).then((_) async {
      print("success!");
      return true;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  static Future<dynamic> getUserDetailByUserId(String userId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('userId', isEqualTo: userId)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      userTemp.userId = userId;
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> getUserDetailByUserEmail(String email) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('email', isEqualTo: email)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      userTemp.userId = value.docs[0].id;
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }
}
