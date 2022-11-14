// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_print, unused_local_variable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:team_manager/screens/calender_view/calender_view.dart';
import 'package:team_manager/screens/edit_post/edit_post.dart';
import '../../controllers/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../add_post/add_post.dart';
import '../announcement_requests/announcement_requests.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({ Key? key }) : super(key: key);

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  
  List projectsList = [];
  //Feature
  int currentIndex = 0;
  SwiperController swiperController = SwiperController();
  List annoucementsList = [];

  @override
  void initState() {
    super.initState();
    getAllPosts();
  }

  void getAllPosts() async {
    projectsList.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAllPosts(projectsList);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      setState(() {
        projectsList = result['ProjectsList'];
        getAllAnnoucements();
      });
    } 
    else {
      //Fail Cases Show String
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  void getAllAnnoucements() async {
    annoucementsList.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    dynamic result = await AppController().getAllAnnoucements(annoucementsList);
    EasyLoading.dismiss();     
    
    if (result['Status'] == "Success") 
    {
      setState(() {
        annoucementsList = result['Announcements'];
      });
    } 
    else {
      //Fail Cases Show String
      Constants.showDialog(result['ErrorMessage'],);
    }
  }

  ///******* UTIL METHOD ****************///
  void userProfileView(Map personDetail)async
  {
    // dynamic result = await showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   context: context,
    //   builder: (BuildContext bc){
    //     return UserDetailView(personDetail : personDetail);
    //   }
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fontSize*2.2
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Get.to(ManagerCalenderView(allEvents: annoucementsList + projectsList));
            },
            icon: Icon(Icons.calendar_month)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*2, SizeConfig.blockSizeHorizontal*2, SizeConfig.blockSizeVertical*2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
      
                if(annoucementsList.isNotEmpty)
                featuredAdView(),
      
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*2),
                  child: Text(
                    'All Assigned Tasks',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize * 2.2,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                (projectsList.isEmpty) ? Container(
                  height: (annoucementsList.isEmpty) ? SizeConfig.blockSizeVertical*70 : SizeConfig.blockSizeVertical*40,
                  child: Center(
                    child: Text(
                      'No Tasks Added',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: SizeConfig.fontSize*2.1
                      ),
                    ),
                  )
                ) : Container(
                  margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal*3, SizeConfig.blockSizeVertical*1, SizeConfig.blockSizeHorizontal*3,0),
                  child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: projectsList.length,
                  itemBuilder: (context, index){
                    return taskCell(projectsList[index], index);
                  }
                ),
              ),
            ],
          )
        ),
      ),
      floatingActionButton: (Constants.appUser.isMember) ? Container() : FloatingActionButton(
        onPressed: () async {
          dynamic result = await Get.to(AddPost());
          if(result != null)
          {

          }
        },
        backgroundColor: Constants.appThemeColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget taskCell (Map task, int index){
    return GestureDetector(
      onTap: () async {
        if(!Constants.appUser.isMember)
        {
          dynamic result = await Get.to(EditPost(postDetail: task));
          if(result != null)
            getAllPosts();
        }
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task['postName']}',
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.9,
                          color: Colors.black,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7,vertical: 4),
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                        '${task['postStatus']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.fontSize * 1.4,
                            color: Colors.white,
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
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0.5),
                      child: Text(
                        '${task['members']['memberName']}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 1.6,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
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

  Widget featuredAdView(){
    DateTime dateText = DateFormat('dd-MM-yyyy').parse(annoucementsList[currentIndex]['postDate']);
    String formatted = DateFormat('dd MMM yyyy').format(dateText);
    return Container(
      child : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*2, right: SizeConfig.blockSizeHorizontal*2, bottom: SizeConfig.blockSizeVertical*1.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Announcements',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 2.2,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),

                GestureDetector(
                  onTap: () async {
                    dynamic result = await Get.to(AnnouncementRequest());
                    getAllAnnoucements();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7,vertical: 4),
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                    'View Requests',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.7,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
          Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
            children: [        
              Container(
                //color: Colors.black,
                width: SizeConfig.blockSizeHorizontal * 100,
                height: SizeConfig.blockSizeVertical * 25,
                child: Swiper(
                  controller: swiperController,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if(!Constants.appUser.isMember)
                        {
                          dynamic result = await Get.to(EditPost(postDetail: annoucementsList[currentIndex]));
                          if(result != null)
                            getAllPosts();
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 0),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Constants.appThemeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children :[
                            Text(
                              annoucementsList[currentIndex]['postName'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize * 2.2,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*0.5),
                              child: Text(
                                annoucementsList[currentIndex]['postDescription'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 2.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1),
                              child: Text(
                                formatted,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.4,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                    );
                  },
                  onIndexChanged: (value){
                    print('index value = $value');
                    setState(() {
                      currentIndex = value;                      
                    });
                  },
                  autoplay: (annoucementsList.length == 1) ? false : true,
                  itemCount: annoucementsList.length,
                  scrollDirection: Axis.horizontal,
                  pagination: SwiperPagination(
                    alignment: Alignment.centerRight,
                    builder: SwiperPagination.rect
                  ),
                  control: SwiperControl(
                    color: Colors.transparent
                  ),
                ),
              ),
        
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 22),
                child: DotsIndicator(
                  dotsCount: annoucementsList.length,
                  position: currentIndex.toDouble(),
                  decorator: DotsDecorator(
                    activeColor: Colors.white,
                    color: Colors.grey[400]!,
                    size: Size.square(9.0),
                    activeSize: Size(18.0, 9.0),
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              )
            ]
          ),
        ],
      ),
    );
  }
}