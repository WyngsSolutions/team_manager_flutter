// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../home_screen/home_screen.dart';

class EditPost extends StatefulWidget {
  final Map postDetail;
  const EditPost({ Key? key, required this.postDetail}) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {

  int postType = 0;
  TextEditingController postName = TextEditingController();
  TextEditingController postDescription = TextEditingController();
  Map? selectedMember;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    postType = int.parse(widget.postDetail['postType']);
    postName.text = widget.postDetail['postName'];
    postDescription.text = widget.postDetail['postDescription'];
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
        selectedMember = membersList.firstWhere((element) => element['memberUserId'] == widget.postDetail['created_for_userId']);
      });
    } 
    else 
    {
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  void editPostPressed() async {
    if (postName.text.isEmpty)
      Constants.showDialog("Please enter post name");
    else if (postDescription.text.isEmpty)
      Constants.showDialog("Please enter post description");
    else if (postType == 0 && selectedMember == null)
      Constants.showDialog("Please assign post member");
    else 
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
      dynamic result = await AppController().editPost(widget.postDetail, postType.toString(), postName.text, postDescription.text, selectedMember);
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

  void deletePostPressed() async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().editPost(widget.postDetail, postType.toString(), postName.text, postDescription.text, selectedMember);
    EasyLoading.dismiss();     
    if (result['Status'] == "Success")
      Get.offAll(HomeScreen(defaultPage: 0,));
    else 
      Constants.showDialog(result['ErrorMessage']);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text(
          'Edit Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize*2.2
          ),
        ),
        actions: [
          if(widget.postDetail['postStatus'] == "Completed" && widget.postDetail['postType'] == "0")
          IconButton(
            onPressed: showUserRatingDialog,
            icon: Icon(Icons.star)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
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
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 7,
              width: SizeConfig.blockSizeHorizontal*42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.appThemeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
                onPressed: editPostPressed,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.fontSize * 2.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical * 7,
              width: SizeConfig.blockSizeHorizontal*42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: Constants.appThemeColor
                  )
                ),
                onPressed: deletePostPressed,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Delete',
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
    );
  }

  void showUserRatingDialog() {
    TextEditingController feedback = TextEditingController();
    double userRating = 5;
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Center(child: Text('Rate User')),
        content: Container(
          width: SizeConfig.blockSizeHorizontal*90,
          child: MediaQuery.removePadding(
            removeTop: true,
            removeBottom: true,
            context: context,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: SizeConfig.blockSizeHorizontal*8,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                      userRating = rating;
                    },
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[400]!
                    )
                  ),
                  child: Center(
                    child: TextField(
                      controller: feedback,
                      minLines: 1,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Any feedback',
                        border: InputBorder.none
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              Get.back();
              enterUserPostRating(userRating,feedback.text);
            },
            child: Text('Submit')
          )
        ],
      )
    );
  } 

  Future<void> enterUserPostRating(double rating, String review) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().addPostRatingForUser(widget.postDetail, rating, review);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
      Get.back(result: true);
      Constants.showDialog('Your review has been added successfully');
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }
}