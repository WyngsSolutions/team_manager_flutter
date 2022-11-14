// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isUser = true;

  @override
  void initState() {
    super.initState();
  }

  //LOGIN METHOD
  void signUpPressed() async {
    if (userName.text.isEmpty)
      Constants.showDialog("Please enter user name");
    else if (email.text.isEmpty)
      Constants.showDialog("Please enter email address");
    else if (!GetUtils.isEmail(email.text))
      Constants.showDialog( "Please enter valid email address");
    else if (password.text.isEmpty)
      Constants.showDialog( "Please enter password");
    else {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().signUpUser(userName.text, email.text, password.text, false);
      EasyLoading.dismiss();     
      if (result['Status'] == "Success")
      {
        Constants.appUser = result['User'];
        await Constants.appUser.saveUserDetails();
        Get.offAll(HomeScreen(defaultPage: 0,));
      }
      else 
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Constants.appThemeColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
              Container(
                height: SizeConfig.blockSizeVertical * 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Image.asset('assets/team.png'),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 8),
                child: Text(
                  'Fill the form to Signup',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.fontSize * 2.5,
                  ),
                ),
              ),

               Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6, top: SizeConfig.blockSizeVertical * 5),
                height: SizeConfig.blockSizeVertical * 7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                    controller: userName,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      prefixIcon: Icon(Icons.account_circle, color: Colors.grey,),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6, top: SizeConfig.blockSizeVertical * 3),
                height: SizeConfig.blockSizeVertical * 7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      prefixIcon: Icon(Icons.email, color: Colors.grey,),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6, top: SizeConfig.blockSizeVertical * 3),
                height: SizeConfig.blockSizeVertical * 7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: password,
                    obscureText: true,
                    style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey,),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),

              Container(
                height: SizeConfig.blockSizeVertical * 7,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  onPressed:signUpPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'SIGNUP',
                      style: TextStyle(
                        color: Constants.appThemeColor,
                        fontSize: SizeConfig.fontSize * 2.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}