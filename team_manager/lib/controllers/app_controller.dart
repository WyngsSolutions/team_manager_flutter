// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, invalid_return_type_for_catch_error, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:http/http.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

class AppController {

  final firestoreInstance = FirebaseFirestore.instance;

  //SIGN UP
  Future signUpUser(String userName, String email, String password, bool isMember) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user?.uid);
      AppUser newUser = AppUser(
        userId: userCredential.user!.uid,
        email: email,
        userName: userName,
        isMember: isMember,
        password: password,
      );
      dynamic resultUser = await newUser.signUpUser(newUser);
      if (resultUser != null) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] ="User cannot signup at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        finalResponse['ErrorMessage'] = "No user found for that email";
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        finalResponse['ErrorMessage'] = "Wrong password provided for that user";
      }
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //SIGN IN
  Future signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.user!.uid);
       AppUser newUser = AppUser(
        userId: userCredential.user!.uid,
        email: email,
        userName: '',
        isMember: false,
        password: password,
      );
      dynamic resultUser = await AppUser.getLoggedInUserDetail(newUser);
      if (resultUser != null)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        return finalResponse;
      }
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "User cannot login at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        finalResponse['ErrorMessage'] = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        finalResponse['ErrorMessage'] =
            "The account already exists for that email";
      } else {
        finalResponse['ErrorMessage'] = e.code;
      }
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //FORGOT PASSWORD
  Future forgotPassword(String email) async {
    try {
      String result = "";
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: email).then((_) async {
        result = "Success";
      }).catchError((error) {
        result = error.toString();
        print("Failed emailed : $error");
      });

      if (result == "Success") {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = result;
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.code;
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //EDIT USER NAME
  Future editUserProfile() async {
    final firestoreInstance = FirebaseFirestore.instance;
    try {
      dynamic result = await firestoreInstance.collection("users").doc(Constants.appUser.userId).update({
        //'cryptos': Constants.appUser.cryptos,
      }).then((_) async {
        print("success!");
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
        finalResponse['ErrorMessage'] = "User profile picture cannot be updated at this time. Try again later";
        return finalResponse;
      }    
    }
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }  
  }

  //SIGN IN
  Future addPost(String postType, String postName, String postDescription, String postDate, Map? member) async {
    try {      
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("posts").add({
        'postType': postType,
        'postDate' : postDate,
        'postName': postName,
        'postStatus' : 'Pending',
        'postDescription': postDescription,
        'members': (postType == "1") ? {} : member,
        'created_by_email' : Constants.appUser.email,
        'created_by_id' : Constants.appUser.userId,
        'created_for_userId' : (postType == "1") ? '' : member!['memberUserId'],
        'addedTime' : FieldValue.serverTimestamp()
      }).then((_) async {
        print("success!");
        if(postType != "1")
        {
          //MEMBER POST
          AppUser memberUser = AppUser();
          memberUser.userId = member!['memberUserId'];
          sendGeneralNotificationToUser(memberUser ,"Task Assigned", "You have been assigned a task");
        }
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

  Future editPost(Map postDetail, String postType, String postName, String postDescription, Map? member) async {
    try {      
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("posts")
      .doc(postDetail['postId']).update({
        'postType': postType,
        'postName': postName,
        'postDescription': postDescription,
        'members': (postType == "1") ? {} : member,
      }).then((_) async {
        print("success!");
        if(postType != "1")
        {
          //MEMBER POST
          AppUser memberUser = AppUser();
          memberUser.userId = member!['memberUserId'];
          sendGeneralNotificationToUser(memberUser ,"Task Updated", "${postDetail['postName']} has been updated");
        }
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

  Future deletePost(Map postDetail) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("posts").
        doc(postDetail['postId']).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
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
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Error'] = "Error";
      finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
      return finalResponse;
    }
  }

  Future<String> uploadFile(File uploadImage) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + basename(uploadImage.path);
    final _firebaseStorage = FirebaseStorage.instance;
    //Upload to Firebase
    var snapshot = await _firebaseStorage.ref().child("member_pictures").child(fileName).putFile(File(uploadImage.path));
    var downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future getAllPosts(List postsList) async {
    try {
      dynamic result = await firestoreInstance.collection("posts")
      .where('postType', isEqualTo: '0')
      .where('created_by_id', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map donor = result.data();
          donor['postId'] = result.id;
          if(donor['userId'] != Constants.appUser.userId)
            postsList.add(donor);
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

  Future getAllAnnoucements(List posts) async {
    try {
      dynamic result = await firestoreInstance.collection("posts")
      .where('postType', isEqualTo: '1')
      .where('created_by_id', isEqualTo: Constants.appUser.userId)
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

  //TEAM MEMBERS
  Future addTeamMember(String memberName, String memberPhone, String memberEmail, String memberPassword, File? memberPicture) async {
    try {
      // //UPLOAD ON FIREBASE
      String userImage1FirebasePath = "";
      if(memberPicture != null)
        userImage1FirebasePath = await uploadFile(memberPicture);
      
      dynamic resultSignup = await AppController().signUpUser(memberName, memberEmail, memberPassword, true);
      if (resultSignup['Status'] == "Success")
      {
        AppUser appUser = resultSignup['User'];
        final firestoreInstance = FirebaseFirestore.instance;
        dynamic result = await firestoreInstance.collection("team_members").add({
          'memberUserId' : appUser.userId,
          'memberName': memberName,
          'memberPhone': memberPhone,
          'memberEmail': memberEmail,
          'memberPassword': memberPassword,
          'memberPhotoUrl': userImage1FirebasePath,
          'created_by_email' : Constants.appUser.email,
          'created_by_id' : Constants.appUser.userId,
          'addedTime' : FieldValue.serverTimestamp()
        }).then((_) async {
          print("success!");
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
          finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
          return finalResponse;
        }
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = resultSignup['ErrorMessage'];
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllTeamMembers(List members) async {
    try {
      dynamic result = await firestoreInstance.collection("team_members")
      .where('created_by_id', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map post = result.data();
          post['memberId'] = result.id;
          members.add(post);
        });
        return true;
      });

      if (result)
      {
        if(members.length>1) //SORT BY TIME
        {
          members.sort((b,a) {
            var adate = a['addedTime'];
            var bdate = b['addedTime'];
            return bdate.compareTo(adate);
          });
        }

        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['Members'] = members;
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

  //
  Future getAllMyMemberAnnoucements(List posts) async {
    try {
      dynamic result = await firestoreInstance.collection("member_announcements")
      .where('user_manager_Id', isEqualTo: Constants.appUser.userId)
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

  Future updateAnnoucementStatus(Map taskDetail, String status) async {
    try {      
      final firestoreInstance = FirebaseFirestore.instance;
      dynamic result = await firestoreInstance.collection("member_announcements")
      .doc(taskDetail['announcementId'])
      .update({
        'postStatus' : '$status',
      }).then((_) async {
        print("success!");
        //ADD as announcement
        if(status == "Approved")
          await addPost("1", taskDetail['postName'], taskDetail['postDescription'],taskDetail['postDate'], {});
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

  Future addPostRatingForUser(Map postDetail, double rating ,String review) async {
    try {   
      dynamic result = await firestoreInstance.collection("user_post_reviews").add({
        'postName': postDetail['postName'],
        'userId': postDetail['members']['memberUserId'],
        'userEmail': postDetail['members']['memberEmail'],
        'userName': postDetail['members']['memberName'],
        'reviewAddedTime' : FieldValue.serverTimestamp(),
        'rating' : rating,
        'review' : review,
        'reviewAddedByUserId' : Constants.appUser.userId
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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

  Future getAllMyReviews(List allReviews, String userId) async {
    try {
      dynamic result = await firestoreInstance.collection("user_post_reviews")
      .where('userId', isEqualTo: userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['commentId'] = result.id;
          allReviews.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allReviews.sort((a, b) => a['reviewAddedTime'].toDate().compareTo(b['reviewAddedTime'].toDate()));
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

  // 'postType': postType,
  // 'postDate' : postDate,
  // 'postName': postName,
  // 'postStatus' : 'Pending',
  // 'postDescription': postDescription,
  // 'members': (postType == "1") ? {} : member,
  // 'created_by_email' : Constants.appUser.email,
  // 'created_by_id' : Constants.appUser.userId,
  // 'created_for_userId' : (postType == "1") ? '' : member!['memberUserId'],
  // 'addedTime' : FieldValue.serverTimestamp()

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

  Future sendGeneralNotificationToUser(AppUser user, String msgTitle, String msgText) async {
    try {
      Map<String, String> requestHeaders = {
        "Content-type": "application/json", 
        "Authorization" : "Basic ${Constants.oneSignalRestKey}"
      };

      //if(user.oneSignalUserId.isEmpty)
      user = await AppUser.getUserDetailByUserId(user.userId);
      var url = 'https://onesignal.com/api/v1/notifications';
      final Uri _uri = Uri.parse(url);
      String json = '{ "include_player_ids" : ["${user.oneSignalUserId}"] ,"app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "$msgTitle"},"contents" : {"en" : "$msgText"}}';
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
