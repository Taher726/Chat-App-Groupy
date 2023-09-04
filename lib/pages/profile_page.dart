import 'package:chatappgroupi/components/my_drawer.dart';
import 'package:chatappgroupi/components/text_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //User
  final currentUser = FirebaseAuth.instance.currentUser!;
  //All users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async{
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Edit "+field,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0), // Adjust the radius as needed
            border: Border.all(
              color: const Color(0xFFee7b64),
              width: 2.0,
            ),
          ),
          child: TextField(
            autofocus: true,
            style: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: "Enter new ${field}",
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onChanged: (value){
              newValue = value;
            },
          ),
        ),
        actions: [
          //Cancel Button
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10.0)),
              backgroundColor: MaterialStateProperty.all(const Color(0xFFee7b64)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          //Save button
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5.0)),
              backgroundColor: MaterialStateProperty.all(const Color(0xFFee7b64)),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16
              ),
            ),
          ),
        ],
      ),
    );
    //Update firestore
    if(newValue.trim().length > 0){
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Profile Page",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).snapshots(),
        builder: (context, snapshot){
          //Get user data
          if(snapshot.hasData){
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                const SizedBox(height: 50,),
                //Profile Picture
                Container(
                  padding: const EdgeInsets.all(10), // Add padding around the icon to make it circular
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[700],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15,),
                Text(
                  userData["email"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700]
                  ),
                ),
                const SizedBox(height: 10,),
                MyTextBox(
                  sectionName: "Full Name",
                  text: userData["fullName"],
                  onTap: () => editField("fullName"),
                ),
                const SizedBox(height: 10,),
                MyTextBox(
                  sectionName: "Bio",
                  text: userData["bio"],
                  onTap: () => editField("bio"),
                ),
              ],
            );
          }
          else if (snapshot.hasError){
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
