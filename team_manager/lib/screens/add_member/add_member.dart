// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';

class AddMember extends StatefulWidget {
  const AddMember({ Key? key }) : super(key: key);

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
   
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  //Photo
  File? image;
  final ImagePicker picker = ImagePicker();

  @override
  void initState(){
    super.initState();
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,);
    if(pickedFile != null)
    {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  void addPressed() async {
    if (name.text.isEmpty)
      Constants.showDialog("Please enter name");
    else if (phone.text.isEmpty)
      Constants.showDialog("Please enter phone number");
    else if (email.text.isEmpty)
      Constants.showDialog("Please enter email address");
    else if (!GetUtils.isEmail(email.text))
      Constants.showDialog( "Please enter valid email address");
    else if (password.text.isEmpty)
      Constants.showDialog( "Please enter password");
    else {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().addTeamMember(name.text, phone.text, email.text, password.text, image);
      EasyLoading.dismiss();     
      if (result['Status'] == "Success")
      {
        Get.offAll(HomeScreen(defaultPage: 1,));
      }
      else 
      {
        //Fail Cases Show String
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text(
          'Add Team Member',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize*2.2
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*5, SizeConfig.blockSizeVertical*2, SizeConfig.blockSizeHorizontal*5,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            GestureDetector(
              onTap: getImageFromGallery,
              child: Center(
                child: Container(
                  height: SizeConfig.blockSizeVertical *16,
                  width: SizeConfig.blockSizeVertical *16,
                  margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical *1, top : SizeConfig.blockSizeVertical *2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: (image != null) ? FileImage(image!) : const AssetImage('assets/user_bg.png') as ImageProvider,
                      fit: BoxFit.cover
                    )
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical * 6.5,
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1
                )
              ),
              child: Center(
                child: TextField(
                  controller: name,
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    border: InputBorder.none
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical * 6.5,
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1
                )
              ),
              child: Center(
                child: TextField(
                  controller: phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: InputBorder.none
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical * 6.5,
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1
                )
              ),
              child: Center(
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: InputBorder.none
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical * 6.5,
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1
                )
              ),
              child: Center(
                child: TextField(
                  controller: password,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: InputBorder.none
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical * 7,
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4, left: 30, right: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.appThemeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
                onPressed: addPressed,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 2.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            )

          ],
        )
      ),
    );
  }
}