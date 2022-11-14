// ignore_for_file: prefer_const_constructors
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:team_manager/models/app_user.dart';
import 'package:team_manager/screens/chat_screen/chat_screen.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../add_member/add_member.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({ Key? key }) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {

  List membersList = [];

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
      });
    } 
    else 
    {
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text('Members', style: TextStyle(color: Colors.white, fontSize: SizeConfig.fontSize*2.2),),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*5, vertical: SizeConfig.blockSizeVertical*1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*2),
                child: Text(
                  'All Members',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 2.2,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              (membersList.isEmpty) ? Expanded(
                child: Center(
                  child: Text(
                    'No Members Added',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: SizeConfig.fontSize*2.1
                    ),
                  ),
                )
              ) : 
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*0, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*0,0),
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: membersList.length,
                  itemBuilder: (context, index){
                    return memberCell(membersList[index], index);
                  }
                ),
              ),
            ),
          ],
        ),
      ),   
      floatingActionButton: (Constants.appUser.isMember) ? Container() : FloatingActionButton(
        onPressed: () async {
          dynamic result = await Get.to(AddMember());
          if(result != null)
          {
            
          }
        },
        backgroundColor: Constants.appThemeColor,
        child: Icon(Icons.add),
      ),   
    );
  }

  Widget memberCell (Map member, int index){
    return GestureDetector(
      onTap: (){
        //userProfileView(donor);
      },
      child: Container(
        height: SizeConfig.blockSizeVertical*11,
        //margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Constants.appThemeColor,
              width: 0.2
            )
          )
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal*3),
              height: SizeConfig.blockSizeVertical*8,
              width: SizeConfig.blockSizeVertical*8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: (member['memberPhotoUrl'].isEmpty) ? AssetImage('assets/user_bg.png') : CachedNetworkImageProvider(member['memberPhotoUrl']) as ImageProvider,
                  //image: AssetImage('assets/user_bg.png'),
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${member['memberName']}',
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize * 2.0,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0.5),
                    child: Text(
                      '${member['memberEmail']}',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                AppUser chatUser = await AppUser.getUserDetailByUserEmail(member['memberEmail']);               
                Get.to(ChatScreen(chatUser: chatUser));
              },
              child: Icon(Icons.chat, color: Constants.appThemeColor, size: SizeConfig.blockSizeVertical*3.2,)
            ),
            SizedBox(width: 5,),
            Icon(Icons.edit, color: Constants.appThemeColor, size: SizeConfig.blockSizeVertical*3.0,)
          ],
        ),
      ),
    );
  }
}