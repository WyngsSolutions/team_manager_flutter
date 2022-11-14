// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:team_manager/controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class AnnouncementRequest extends StatefulWidget {
  const AnnouncementRequest({ Key? key }) : super(key: key);

  @override
  State<AnnouncementRequest> createState() => _AnnouncementRequestState();
}

class _AnnouncementRequestState extends State<AnnouncementRequest> {
  
  List allMyAnnouncements = [];
  List announcementPending = [];

  @override
  void initState() {
    super.initState();
    getAllMyMemberAnnoucements();
  }

  void getAllMyMemberAnnoucements() async {
    
    List projectsList = [];
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAllMyMemberAnnoucements(projectsList);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      setState(() {
        allMyAnnouncements = result['Announcements'];
        announcementPending = projectsList.where((element) => element['postStatus'] == "Pending").toList();
      });
    } 
    else 
    {
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

   void updateAnnoucementStatus(Map taskDetail, String status) async {
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().updateAnnoucementStatus(taskDetail, status);
    EasyLoading.dismiss();     
    if (result['Status'] == "Success") 
      getAllMyMemberAnnoucements();
    else 
      Constants.showDialog(result['ErrorMessage'],);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text(
          'Annoucements Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize*2.2
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*5, vertical: SizeConfig.blockSizeVertical*1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pendingListView(),
          ],
        ),
      ),   
    );
  }

  Widget pendingListView(){
    return (announcementPending.isEmpty) ? Expanded(
      child: Container(
        child: Center(
          child: Text(
            'No Announcement Requests',
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
                      Expanded(
                        child: Text(
                          '${task['postName']}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: SizeConfig.fontSize * 1.9,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
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

                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1.5), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: SizeConfig.blockSizeVertical * 5,
                          width: SizeConfig.blockSizeHorizontal*35,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.appThemeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                            ),
                            onPressed: (){
                              updateAnnoucementStatus(task, 'Approved');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Approve',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SizeConfig.fontSize * 1.5,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal*7,),
                        Container(
                          height: SizeConfig.blockSizeVertical * 5,
                          width: SizeConfig.blockSizeHorizontal*35,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              ),
                              side: BorderSide(
                                color: Constants.appThemeColor
                              )
                            ),
                            onPressed: (){
                              updateAnnoucementStatus(task, 'Rejected');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Reject',
                                style: TextStyle(
                                  color: Constants.appThemeColor,
                                  fontSize: SizeConfig.fontSize * 1.5,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
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