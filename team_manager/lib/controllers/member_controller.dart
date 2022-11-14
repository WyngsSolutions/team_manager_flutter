// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, invalid_return_type_for_catch_error, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:team_manager/controllers/app_controller.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

class MemberController {

  final firestoreInstance = FirebaseFirestore.instance;

  Future getAllMyPosts(List postsList) async {
    try {
      dynamic result = await firestoreInstance.collection("posts")
      .where('postType', isEqualTo: '0')
      .where('created_for_userId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map post = result.data();
          post['postId'] = result.id;
          postsList.add(post);
        });
        return true;
      });

      if (result)
      {
        if(postsList.length>1) //SORT BY TIME
        {
          postsList.sort((a,b) {
            var adate = a['addedTime'];
            var bdate = b['addedTime'];
            return bdate.compareTo(adate);
          });
        }

        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['ProjectsList'] = postsList;
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future updateTaskStatus(Map taskDetail) async {
    try {      
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("posts").doc(taskDetail['postId']).update({
        'postStatus' : 'Completed',
      }).then((_) async {
        print("success!");
        //MANAGER POST
        AppUser managerUser = AppUser();
        managerUser.userId = taskDetail['created_by_id'];
        AppController().sendGeneralNotificationToUser(managerUser ,"${taskDetail['postName']}", "The task have been marked completed");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return null;
      });

      if (result != null)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Place cannot be added at this time. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //SEARCH
  // Future searchDonor(List donorsList, int bloodGroup) async {
  //   try {
  //     String bloodType = Constants.bGroups[bloodGroup];
  //     dynamic result = await firestoreInstance.collection("donors")
  //     .where('bloodGroup', isEqualTo: bloodType)
  //     .get().then((value) {
  //     value.docs.forEach((result) 
  //     {
  //         print(result.data);
  //         Map donor = result.data();
  //         donor['donorId'] = result.id;
  //         donorsList.add(donor);
  //       });
  //       return true;
  //     });

  //     if (result)
  //     {
  //       if(donorsList.length>1) //SORT BY TIME
  //       {
  //         donorsList.sort((a,b) {
  //           var adate = a['name'];
  //           var bdate = b['name'];
  //           return bdate.compareTo(adate);
  //         });
  //       }

  //       Map finalResponse = <dynamic, dynamic>{}; //empty map
  //       finalResponse['Status'] = "Success";
  //       finalResponse['DonorsList'] = donorsList;
  //       return finalResponse;
  //     }
  //     else
  //     {
  //       Map finalResponse = <dynamic, dynamic>{}; //empty map
  //       finalResponse['Error'] = "Error";
  //       finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
  //       return finalResponse;
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //     return setUpFailure();
  //   }
  //}

  Future getAllManagerAnnoucements(List posts) async {
    try {
      Map memberDetail = await getMemberDetailWhereEmail(Constants.appUser.email);
      dynamic result = await firestoreInstance.collection("posts")
      .where('postType', isEqualTo: '1')
      .where('created_by_id', isEqualTo: memberDetail['created_by_id'])
      .get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map post = result.data();
          post['postId'] = result.id;
          posts.add(post);
        });
        return true;
      });

      if (result)
      {
        if(posts.length>1) //SORT BY TIME
        {
          posts.sort((b,a) {
            var adate = a['addedTime'];
            var bdate = b['addedTime'];
            return bdate.compareTo(adate);
          });
        }

        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['Announcements'] = posts;
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllMyAnnoucement(List posts) async {
    try {
      dynamic result = await firestoreInstance.collection("member_announcements")
      .where('created_by_userId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map post = result.data();
          post['announcementId'] = result.id;
          posts.add(post);
        });
        return true;
      });

      if (result)
      {
        if(posts.length>1) //SORT BY TIME
        {
          posts.sort((b,a) {
            var adate = a['addedTime'];
            var bdate = b['addedTime'];
            return bdate.compareTo(adate);
          });
        }

        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['Announcements'] = posts;
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future memberPostAnnouncement(String postType, String postTitle, String postDescription, String postDate) async {
    try {
      Map memberDetail = await getMemberDetailWhereEmail(Constants.appUser.email);
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("member_announcements")
      .add({
        'postType': postType,
        'postName': postTitle,
        'postDate': postDate,
        'postDescription': postDescription,
        'postStatus' : "Pending",
        'created_by_userId' : Constants.appUser.userId,
        'created_by_userEmail' : Constants.appUser.email,
        'user_manager_Id' : memberDetail['created_by_id'],
        'addedTime' : FieldValue.serverTimestamp()
      }).then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return null;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  static Future<dynamic> getMemberDetailWhereEmail(String email) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("team_members")
    .where('memberEmail', isEqualTo: email)
    .get()
    .then((value) async {
      Map memberData = value.docs[0].data();
      return memberData;
    }).catchError((error) {
      print("Failed to add user: $error");
      return {};
    });
  }

  Future sendChatNotificationToUser(AppUser user) async {
    try {
      Map<String, String> requestHeaders = {
        "Content-type": "application/json", 
        "Authorization" : "Basic ${Constants.oneSignalRestKey}"
      };

      //if(user.oneSignalUserId.isEmpty)
      user = await AppUser.getUserDetailByUserId(user.userId);
      var url = 'https://onesignal.com/api/v1/notifications';
      final Uri _uri = Uri.parse(url);
      //String json = '{ "include_player_ids" : ["${user.oneSignalUserID}"], "app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Message"}, "contents" : {"en" : "You have a message from ${Constants.appUser.fullName}"}, "data" : { "userID" : "${Constants.appUser.userID}" } }';
      String json = '{ "include_player_ids" : ["${user.oneSignalUserId}"] ,"app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Request"},"contents" : {"en" : "You have received a request message from ${Constants.appUser.userName}"}}';
      Response response = await post(_uri, headers: requestHeaders, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    
      if (response.statusCode == 200) {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server at this time. Please try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  Map setUpFailure() {
    Map finalResponse = <dynamic, dynamic>{}; //empty map
    finalResponse['Status'] = "Error";
    finalResponse['ErrorMessage'] = "Please try again later. Server is busy.";
    return finalResponse;
  }
}
