import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'package:table_calendar/table_calendar.dart';

class ManagerCalenderView extends StatefulWidget {
  
  final List allEvents;
  const ManagerCalenderView({ Key? key, required this.allEvents }) : super(key: key);

  @override
  State<ManagerCalenderView> createState() => _ManagerCalenderViewState();
}

class _ManagerCalenderViewState extends State<ManagerCalenderView> {

  List filteredEvents = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    filterTasksOnDate();
  }

  void filterTasksOnDate(){
    filteredEvents.clear();
    for(int i=0; i< widget.allEvents.length; i++)
    {
      DateTime taskDate = DateFormat("dd-MM-yyyy").parse(widget.allEvents[i]['postDate'].toString());
      if(taskDate.day == _selectedDay.day && taskDate.month == _selectedDay.month && taskDate.year == _selectedDay.year) {
        setState(() {
          filteredEvents.add(widget.allEvents[i]);          
        });
      }
    }
  }

  void addEventToCalender(Map task){
    DateTime taskStartDate = DateFormat("dd-MM-yyyy").parse(task['postDate']);

    final Event event = Event(
      title: task['postName'],
      description: task['postDescription'],
      location: '',
      startDate: taskStartDate,
      endDate: taskStartDate,
    );
    Add2Calendar.addEvent2Cal(event);
  }
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.appThemeColor,
        title: Text('Calender View', style: TextStyle(color: Colors.white, fontSize: SizeConfig.fontSize*2.2),),
        elevation: 0,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            TableCalendar(
              calendarFormat: _calendarFormat,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration : BoxDecoration(
                  color: Constants.appThemeColor,
                  shape: BoxShape.circle
                )
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  filterTasksOnDate();
                });
              },
            ),

            (filteredEvents.isEmpty) ? Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*10, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Center(
                  child: Text(
                    'No Events Found',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                      color: Colors.grey[400]!
                    ),
                  ),
                ),
              ),
            ) : Expanded(
              child: Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (_, i) {
                      if(filteredEvents[i]['postType'] == "0")
                        return taskCell(filteredEvents[i], i);
                      else
                        return announcementCell(filteredEvents[i], i);
                    },
                    shrinkWrap: true,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
  
  Widget announcementCell (Map task, int index){
    return GestureDetector(
      onTap: () async {
        // if(!Constants.appUser.isMember)
        // {
        //   dynamic result = await Get.to(EditPost(postDetail: task));
        //   if(result != null)
        //     getAllPosts();
        // }
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
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1),
                      height: SizeConfig.blockSizeVertical * 5.5,
                      width: SizeConfig.blockSizeHorizontal*90,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.appThemeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                        onPressed: (){
                          addEventToCalender(task);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Add to Calendar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.fontSize * 1.5,
                              fontWeight: FontWeight.bold
                            ),
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

  Widget taskCell (Map task, int index){
    return GestureDetector(
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

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1),
                      height: SizeConfig.blockSizeVertical * 5.5,
                      width: SizeConfig.blockSizeHorizontal*90,
                      child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.appThemeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                        onPressed: (){
                          addEventToCalender(task);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Add to Calendar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.fontSize * 1.5,
                              fontWeight: FontWeight.bold
                            ),
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