import 'dart:math';

import 'package:chatappgroupi/components/my_drawer.dart';
import 'package:chatappgroupi/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

enum GroupFilter {
  All,
  Joined,
  Unjoined,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  GroupFilter filter = GroupFilter.All;
  //User
  final currentUser = FirebaseAuth.instance.currentUser!;
  //All users
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  String fullName = "";

  void goToProfilePage(){
    //Pop menu drawer
    Navigator.pop(context);
    //Go to profile page
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const ProfilePage()
    ));
  }

  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  Future<String> getUserFullName() async{
    try{
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).get();
      if(userSnapshot.exists){
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        String userFullName = userData["fullName"];
        return userFullName;
      }
      else{
        return "User not found";
      }
    }
    catch(error){
      return "Error: ${error}";
    }
  }

  String generateCustomGroupId(){
    String timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    String randomNumber = Random().nextInt(100000).toString();
    return '$timestamp-$randomNumber';
  }

  Future<void> addGroup() async{
    String groupName = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Create new group",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(
              color: const Color(0xFFee7b64),
              width: 2.0
            ),
          ),
          child: TextField(
            autofocus: true,
            style: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: "Group Name",
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onChanged: (value) {
              groupName = value;
            },
          ),
        ),
        actions: [
          //Cancel Button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFFee7b64)),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10.0))
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0
              ),
            ),
          ),
          //Create Button
          TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color(0xFFee7b64)),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10.0))
            ),
            onPressed: () => Navigator.of(context).pop(groupName),
            child: const Text(
              "Create",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0
              ),
            ),
          ),
        ],
      )
    );
    if(groupName.trim().length > 0){
      String groupId = generateCustomGroupId();
      String adminName = await getUserFullName();
      await FirebaseFirestore.instance.collection("Groups").doc(groupId).set({
        "groupName": groupName,
        "adminName": adminName,
        "adminUid": currentUser.uid,
        "members": [currentUser.uid],
      });
      await FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).update({
        "groups": FieldValue.arrayUnion([
          {"groupId": groupId, "groupName": groupName}
        ]),
      });
    }
  }

  Future<void> joinGroup(String groupId, String groupName) async{
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text(
          "Waiting to join th group"
        ),
        content: SingleChildScrollView(
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFee7b64),
            ),
          ),
        ),
      ),
    );
    try{
      //Get current user ID
      String uid = currentUser.uid;
      //Update the group's members field by adding the new member
      await FirebaseFirestore.instance.collection("Groups").doc(groupId).update({
        "members": FieldValue.arrayUnion([uid])
      });
      await FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "groups": FieldValue.arrayUnion([
          {"groupId": groupId, "groupName": groupName}
        ]),
      });
      Navigator.pop(context);
    }
    catch (error){
      Navigator.pop(context);
      print("Error joining group $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserFullName();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Groupy",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        actions: [
          PopupMenuButton<GroupFilter>(
            onSelected: (filter) {
              setState(() {
                this.filter = filter;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<GroupFilter>>[
              PopupMenuItem<GroupFilter>(
                value: GroupFilter.All,
                child: Text(
                    "All Groups",
                  style: TextStyle(
                    color: filter == GroupFilter.All ? Color(0xFFee7b64) : null
                  ),
                ),
              ),
              PopupMenuItem<GroupFilter>(
                value: GroupFilter.Joined,
                child: Text(
                  "Joined Groups",
                  style: TextStyle(
                    color: filter == GroupFilter.Joined ? Color(0xFFee7b64) : null
                  ),
                ),
              ),
              PopupMenuItem<GroupFilter>(
                value: GroupFilter.Unjoined,
                child: Text(
                  "Unjoined Groups",
                  style: TextStyle(
                      color: filter == GroupFilter.Unjoined ? Color(0xFFee7b64) : null
                  ),
                ),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      drawer: FutureBuilder<String>(
        future: getUserFullName(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }
          if(snapshot.hasError){
            return Text("Error: ${snapshot.error}");
          }
          return MyDrawer(
            onProfileTap: goToProfilePage,
            onSignOutTap: signOut,
            profileName: snapshot.data ?? "",
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Groups").snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Text("Error: ${snapshot.error}");
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<DocumentSnapshot> groups = snapshot.data!.docs;

          // Filter groups based on the selected filter
          if (filter == GroupFilter.Joined) {
            groups = groups.where((group) => group["members"].contains(currentUser.uid)).toList();
          } else if (filter == GroupFilter.Unjoined) {
            groups = groups.where((group) => !group["members"].contains(currentUser.uid)).toList();
          }
          return groups.length > 0 ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              final group = snapshot.data!.docs[index];
              return group["members"].contains(currentUser.uid) ? ListTile(
                leading: CircleAvatar(
                  child: Text(
                    group["groupName"].toString().substring(0,1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: const Color(0xFFee7b64),
                ),
                title: Text(
                  group["groupName"],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
                subtitle: FutureBuilder<String>(
                  future: getUserFullName(),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Join the conversation as ..."); // Display a loading message or a placeholder
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    String fullName = snapshot.data ?? "";
                    return Text("Join the conversation as $fullName");
                  },
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder:(context) => ChatPage(
                      groupName: group["groupName"],
                      groupId: group.id,
                    ),
                  ));
                },
              ) : ListTile(
                leading: CircleAvatar(
                child: Text(
                  group["groupName"].toString().substring(0,1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                backgroundColor: const Color(0xFFee7b64),
                ),
                title: Text(
                  group["groupName"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
                subtitle: FutureBuilder<String>(
                future: getUserFullName(),
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Join the conversation as ..."); // Display a loading message or a placeholder
                  }
                  if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                  }
                  String fullName = snapshot.data ?? "";
                  return Text("Join the conversation as $fullName");
                  },
                ),
                trailing: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(5.0)),
                    backgroundColor: MaterialStateProperty.all(Color(0xFFee7b64))
                  ),
                  onPressed: () async{
                    await joinGroup(group.id, group["groupName"]);
                  },
                  child: Text(
                    "Join",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ) : Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: IconButton(
                      onPressed: addGroup,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    backgroundColor: Colors.grey[600],
                  ),
                  SizedBox(height: 10,),
                  const Text(
                    "At the moment no group is available, tap on add icon to create a group.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              )
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addGroup,
        child: const Icon(
          Icons.add
        ),
        backgroundColor: const Color(0xFFee7b64),
      ),
    );
  }
}
