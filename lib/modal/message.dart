import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String senderName;
  final String senderId;
  final String message;
  final Timestamp timeStamp;

  Message({ required this.senderName, required this.senderId, required this.message, required this.timeStamp });

  Map<String, dynamic> toMap(){
    return {
      "senderId": senderId,
      "senderName": senderName,
      "message": message,
      "timeStamp": timeStamp,
    };
  }
}