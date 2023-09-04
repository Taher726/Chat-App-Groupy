import 'package:chatappgroupi/modal/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier{
  //Get instance of auth and current user
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //GET CURRENT USER NAME
  Future<String> getFullName() async{
    try{
      DocumentSnapshot userDocument = await _firebaseFirestore.collection("Users").doc(_firebaseAuth.currentUser!.uid).get();
      if(userDocument.exists){
        Map<String, dynamic> userData = userDocument.data() as Map<String, dynamic>;
        String userFullName = userData["fullName"];
        return userFullName;
      }
      else{
        return "User not found";
      }
    }
    catch (error){
      return "Error: $error";
    }
  }

  //SEND MESSAGE
  Future<void> sendMessage(String message, String groupId) async{
    //Get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserName = await getFullName();
    final Timestamp timestamp =Timestamp.now();
    //Create new message
    Message newMessage = Message(
      senderName: currentUserName,
      senderId: currentUserId,
      message: message,
      timeStamp: timestamp
    );

    //Construct a chat room if from groupid
    await _firebaseFirestore.collection("Groups").doc(groupId).collection("messages").add(newMessage.toMap());
  }

  //GET MESSAGE
  Stream<QuerySnapshot> getMessage(String groupId){
    return _firebaseFirestore.collection("Groups").doc(groupId).collection("messages").orderBy("timeStamp", descending: false).snapshots();
  }
}