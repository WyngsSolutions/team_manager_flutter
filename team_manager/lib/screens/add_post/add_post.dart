// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team_manager/screens/members_list/members_list.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';

class AddPost extends StatefulWidget {
  
  const AddPost({ Key? key }) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {

  int postType = 0;
  TextEditingController postName = TextEditingController();
  TextEditingController postDescription = TextEditingController();
  Map? selectedMember;
  List membersList = [];
  final format = DateFormat("dd-MM-yyyy");
  TextEditingController postDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllMembers();
  }

  void getAllMembers() async {
    membersList.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAllTeamMembers(membersList);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      setState(() {
        membersList = result['Members'];
        if(membersList.isEmpty)
        {
          Get.offAll(HomeScreen(defaultPage: 1,));
          Constants.showDialog('Please add atleast 1 member first');
        }
      });
    } 
    else 
    {
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  void postPressed() async {
    if (postName.text.isEmpty)
      Constants.showDialog("Please enter post name");
    else if (postDescription.text.isEmpty)
      Constants.showDialog("Please enter post description");
    else if (postDate.text.isEmpty)
       Constants.showDialog("Please enter post date");
    else if (postType == 0 && selectedMember == null)
      Constants.showDialog("Please assign post member");
    else 
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().addPost(postType.toString(), postName.text, postDescription.text, postDate.text, selectedMember);
      EasyLoading.dismiss();     
      if (result['Status'] == "Success")
      {
        Get.offAll(HomeScreen(defaultPage: 0,));
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
          'Add Post',
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
            
            Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical *1, top : SizeConfig.blockSizeVertical *2),
              child: Row(
                children: [
                  Radio(
                    value: 0,
                    groupValue: postType,
                    onChanged: (val){
                      setState(() { 
                        postType=0;
                        postDescription.text = "";
                      });
                    },
                    activeColor: Constants.appThemeColor,
                  ),
                  Text(
                    'Member Post',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal*4,),
                  Radio(
                    value: 1,
                    groupValue: postType,
                    onChanged: (val){
                      setState(() { 
                        postType = 1;
                        postDescription.text = "";
                      });
                    },
                    activeColor: Constants.appThemeColor,
                  ),
                  Text(
                    'Annoucement',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.fontSize * 1.8,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              height: SizeConfig.blockSizeVertical * 6.5,
              //margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
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
                  controller: postName,
                  style: TextStyle(fontSize: SizeConfig.fontSize*1.8,),
                  decoration: InputDecoration(
                    hintText: 'Enter post name',
                    hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                    border: InputBorder.none
                  ),
                ),
              ),
            ),

            (postType == 0) ?
            Container(
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
                  controller: postDescription,
                  minLines: 8,
                  maxLines: null,
                  style: TextStyle(fontSize: SizeConfig.fontSize*1.8,),
                  decoration: InputDecoration(
                    hintText: 'Enter post description',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                  ),
                ),
              ),
            ) : Container(
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
                  controller: postDescription,
                  style: TextStyle(fontSize: SizeConfig.fontSize*1.8,),
                  minLines: 6,
                  maxLines: 6,
                  inputFormatters: [LengthLimitingTextInputFormatter(150)],
                  decoration: InputDecoration(
                    hintText: 'Enter post description',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                  ),
                ),
              ),
            ),

            Container(
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
                child: DateTimeField(
                  format: format,
                  controller: postDate,
                  resetIcon: const Icon(Icons.close, color: Colors.transparent,),
                  style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                    border: InputBorder.none,
                    hintText: 'Enter post date',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15)
                  ),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100)
                    );
                    if (date != null) {
                      return date;
                    } else {
                      return currentValue;
                    }
                  },
                ),
              ),
            ),

            if(postType == 0)
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
                child: DropdownButton<dynamic>(
                  value: selectedMember,
                  style: TextStyle(fontSize: SizeConfig.fontSize*1.8, color: Colors.black),
                  isExpanded: true,
                  underline: Container(),
                  hint: Text(
                    'Select member',
                    style: GoogleFonts.montserrat(
                      fontSize: SizeConfig.fontSize*1.8,
                    ),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedMember = newValue;
                    });
                  },
                  items: membersList.map((location) {
                    return DropdownMenuItem<dynamic>(
                      child: Text(location['memberName'], style: TextStyle(fontSize: SizeConfig.fontSize*1.8,),),
                      value: location,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        )
      ),
      bottomNavigationBar: Container(
        height: SizeConfig.blockSizeVertical * 7,
        margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.appThemeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            )
          ),
          onPressed: postPressed,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'POST',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.fontSize * 2.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      )
    );
  }
}