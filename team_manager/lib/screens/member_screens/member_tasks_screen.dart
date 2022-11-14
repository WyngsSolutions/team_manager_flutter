// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import '../../controllers/member_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class MemberTasksScreen extends StatefulWidget {
  
  const MemberTasksScreen({ Key? key }) : super(key: key);

  @override
  State<MemberTasksScreen> createState() => _MemberTasksScreenState();
}

class _MemberTasksScreenState extends State<MemberTasksScreen> {
  
  List pendingList = [];
  List completedList = [];
  int selectedList = 0;

  @override
  void initState() {
    super.initState();
    getAllMyPosts();
  }

  void getAllMyPosts() async {
    List projectsList = [];
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await MemberController().getAllMyPosts(projectsList);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      setState(() {
        projectsList = result['ProjectsList'];
        pendingList = projectsList.where((element) => element['postStatus'] == "Pending").toList();
        completedList = projectsList.where((element) => element['postStatus'] != "Pending").toList();
      });
    } 
    else 
    {
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  void updateTaskStatus(Map taskDetail) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await MemberController().updateTaskStatus(taskDetail);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      getAllMyPosts();
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
        title: Text(
          'My Assigned Tasks',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize*2.2
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*5, vertical: SizeConfig.blockSizeVertical*2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: SizeConfig.blockSizeVertical*5,
              width: SizeConfig.blockSizeHorizontal*80,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedList = 0;
                      });
                    },
                    child: Container(
                      height: SizeConfig.blockSizeVertical*5.5,
                      width: SizeConfig.blockSizeHorizontal*45,
                      decoration: BoxDecoration(
                        color: (selectedList == 0 ) ? Constants.appThemeColor : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10)
                        ),
                        border: Border.all(
                          color: Constants.appThemeColor,
                          width: 0.5
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            color: (selectedList == 0) ? Colors.white : Constants.appThemeColor,
                            fontSize: SizeConfig.fontSize*2
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedList = 1;
                      });
                    },
                    child: Container(
                      height: SizeConfig.blockSizeVertical*5.5,
                      width: SizeConfig.blockSizeHorizontal*45,
                      decoration: BoxDecoration(
                        color: (selectedList == 1) ? Constants.appThemeColor : Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)
                        ),
                        border: Border.all(
                          color: Constants.appThemeColor,
                          width: 0.5
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: (selectedList == 1) ? Colors.white : Constants.appThemeColor,
                            fontSize: SizeConfig.fontSize*2
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //PENDING LIST
            (selectedList ==0) ? pendingListView() : completedListView(),
            

          ],
        ),
      ),
    );
  }

  Widget pendingListView(){
    return (pendingList.isEmpty) ? Expanded(
      child: Container(
        child: Center(
          child: Text(
            'No Pending Tasks',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: SizeConfig.fontSize*2.1
            ),
          ),
        )
      ),
    ) : Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*3, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*3,0),
        child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: pendingList.length,
        itemBuilder: (context, index){
          return taskCell(pendingList[index], index);
        }
      ),
      ),
    );
  }

  Widget completedListView(){
    return (completedList.isEmpty) ? Expanded(
      child: Container(
        child: Center(
          child: Text(
            'No Completed Tasks',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: SizeConfig.fontSize*2.1
            ),
          ),
        )
      ),
    ) : Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*3, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*3,0),
        child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: completedList.length,
        itemBuilder: (context, index){
          return taskCell(completedList[index], index);
        }
      ),
      ),
    );
  }

  Widget taskCell (Map task, int index){
    return GestureDetector(
      onTap: (){
        //userProfileView(donor);
      },
      child: Container(
        //height: SizeConfig.blockSizeVertical*11,
        //margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical*1.5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Constants.appThemeColor,
              width: 0.2
            )
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal*3),
              height: SizeConfig.blockSizeVertical*8,
              width: SizeConfig.blockSizeVertical*8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: (task['members']['memberPhotoUrl'].isEmpty) ? AssetImage('assets/user_bg.png') : CachedNetworkImageProvider(task['members']['memberPhotoUrl']) as ImageProvider,
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${task['postName']}',
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.9,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0.5),
                    child: Text(
                      '${task['postDescription']}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.6,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  if(selectedList == 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: (){
                        updateTaskStatus(task);
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0.5),
                        padding: EdgeInsets.symmetric(horizontal: 7,vertical: 4),
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Mark Complete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.fontSize * 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}