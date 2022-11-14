// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/member_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'member_add_annoucement.dart';

class MemberAnnouncementList extends StatefulWidget {
  const MemberAnnouncementList({ Key? key }) : super(key: key);

  @override
  State<MemberAnnouncementList> createState() => _MemberAnnouncementListState();
}

class _MemberAnnouncementListState extends State<MemberAnnouncementList> {
 
  List allMyAnnouncements = [];
  List announcementPending = [];
  List announcementApproved = [];
  List announcementRejected = [];
  int selectedList = 0;

  @override
  void initState() {
    super.initState();
    getAllMyAnnoucement();
  }

  void getAllMyAnnoucement() async {
    
    List projectsList = [];
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await MemberController().getAllMyAnnoucement(projectsList);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      setState(() {
        allMyAnnouncements = result['Announcements'];
        announcementPending = projectsList.where((element) => element['postStatus'] == "Pending").toList();
        announcementApproved = projectsList.where((element) => element['postStatus'] == "Approved").toList();
        announcementRejected = projectsList.where((element) => element['postStatus'] == "Rejected").toList();
      });
    } 
    else 
    {
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text(
          'My Annoucements Requests',
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
              margin: EdgeInsets.only(bottom: 10),
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
                      width: SizeConfig.blockSizeHorizontal*30,
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
                      width: SizeConfig.blockSizeHorizontal*30,
                      decoration: BoxDecoration(
                        color: (selectedList == 1) ? Constants.appThemeColor : Colors.white,
                        border: Border.all(
                          color: Constants.appThemeColor,
                          width: 0.5
                        )
                      ),
                      child: Center(
                        child: Text(
                          'Approved',
                          style: TextStyle(
                            color: (selectedList == 1) ? Colors.white : Constants.appThemeColor,
                            fontSize: SizeConfig.fontSize*2
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedList = 2;
                      });
                    },
                    child: Container(
                      height: SizeConfig.blockSizeVertical*5.5,
                      width: SizeConfig.blockSizeHorizontal*30,
                      decoration: BoxDecoration(
                        color: (selectedList == 2) ? Constants.appThemeColor : Colors.white,
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
                          'Rejected',
                          style: TextStyle(
                            color: (selectedList == 2) ? Colors.white : Constants.appThemeColor,
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
            (selectedList == 0) ? pendingListView() : (selectedList == 1) ? approvedListView() : rejectedListView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          dynamic result = await Get.to(AddAnnouncementRequest());
          if(result != null)
          {
            
          }
        },
        backgroundColor: Constants.appThemeColor,
        child: Icon(Icons.add),
      ),   
    );
  }

  Widget pendingListView(){
    return (announcementPending.isEmpty) ? Expanded(
      child: Container(
        child: Center(
          child: Text(
            'No Pending Announcement',
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
          itemCount: announcementPending.length,
          itemBuilder: (context, index){
            return taskCell(announcementPending[index], index);
          }
        ),
      ),
    );
  }

  Widget approvedListView(){
    return (announcementApproved.isEmpty) ? Expanded(
      child: Container(
        child: Center(
          child: Text(
            'No Approved Announcement',
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
          itemCount: announcementApproved.length,
          itemBuilder: (context, index){
            return taskCell(announcementApproved[index], index);
          }
        ),
      ),
    );
  }

  Widget rejectedListView(){
    return (announcementRejected.isEmpty) ? Expanded(
      child: Container(
        child: Center(
          child: Text(
            'No Rejected Announcement',
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
          itemCount: announcementRejected.length,
          itemBuilder: (context, index){
            return taskCell(announcementRejected[index], index);
          }
        ),
      ),
    );
  }

  Widget taskCell (Map task, int index){
    DateTime dateText = DateFormat('dd-MM-yyyy').parse(task['postDate']);
    String formatted = DateFormat('dd MMM yyyy').format(dateText);
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
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.9,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      child: Text(
                        formatted,
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.6,
                          color: Colors.black,
                          fontWeight: FontWeight.w500
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