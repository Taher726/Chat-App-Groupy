import 'package:chatappgroupi/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  const ChatPage({super.key, required this.groupName, required this.groupId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();

  void sendMessage() async{
    if(messageController.text.isNotEmpty){
      await chatService.sendMessage(messageController.text, widget.groupId);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GroupInfo(
                    groupId: widget.groupId
                ),
              ));
            }
          ),
        ],
      ),
      body: Column(
        children: [
          //Messages
          Expanded(
            child: _buildMessageList(),
          ),
          //User Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                //Text Field
                Expanded(child:
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter Message...",
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFee7b64),
                          width: 2
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFFee7b64),
                            width: 2
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFFee7b64),
                            width: 2
                        ),
                      ),
                    ),
                  ),
                ),
                //Icon
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFFee7b64),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
  Widget _buildMessageList(){
    return StreamBuilder(
      stream: chatService.getMessage(widget.groupId),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text("Error: ${snapshot.error}");
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const CircularProgressIndicator(
            color: Color(0xFFee7b64),
          );
        }
        return  ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignement =(data["senderId"] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignement,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            data["senderName"],
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5,),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: (data["senderId"] == _firebaseAuth.currentUser!.uid) ? BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)) : BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
              color: const Color(0xFFee7b64),
            ),
            child: Text(
              data["message"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16
              ),
            ),
          ),
        ],
      ),
    );
  }
}
