import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  const GroupInfo({super.key, required this.groupId});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

Future<String> getFullName(String userId) async{
  try{
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(userId).get();
    if(documentSnapshot.exists){
      Map<String, dynamic> user = documentSnapshot.data() as Map<String, dynamic>;
      String userFullName = user["fullName"];
      return userFullName;
    }
    else{
      return "User not found";
    }
  }
  catch(error){
    return "Error: $error";
  }
}

class _GroupInfoState extends State<GroupInfo> {

  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  void exitGroup(BuildContext context, String currentUser) async{
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFee7b64),
          ),
        )
    );
    try{
      final groupDocRef = FirebaseFirestore.instance.collection("Groups").doc(widget.groupId);

      //Remove current user from members list of the group
      await groupDocRef.update({
        "members": FieldValue.arrayRemove([currentUser])
      });

      //Remove the group from joined groups of user
      final userDocRef = FirebaseFirestore.instance.collection("Users").doc(currentUser);
      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        List<dynamic> joinedGroups = List<dynamic>.from(userData['groups'] ?? []);
        joinedGroups.removeWhere((group) => group['groupId'] == widget.groupId); // Remove the group by ID

        // Update the user's document with the modified joinedGroups list
        await userDocRef.update({
          'groups': joinedGroups,
        });
      }

      //Pop the loading circle
      Navigator.pop(context);

      //Go back to home page
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    catch(error){
      print("Error exiting group: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Info"),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        actions: [
          IconButton(
            onPressed: () => exitGroup(context, currentUser),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("Groups").doc(widget.groupId).snapshots(),
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text("Error: ${snapshot.error}");
            }
            if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator(
                color: Color(0xFFee7b64),
              );
            }
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            List<String> members = List<String>.from(data['members'] ?? []);
            return Column(
              children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: const Color(0xffffad9f),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            data["groupName"].toString().substring(0,1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          backgroundColor: const Color(0xFFee7b64),
                        ),
                        title: Text(
                          "Group: ${data["groupName"]}",
                        ),
                        subtitle: Text(
                          "Admin: ${data["adminName"]}",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (builder, index){
                      return ListTile(
                        leading: CircleAvatar(
                          child: FutureBuilder<String>(
                            future: getFullName(members[index]),
                            builder: (context, snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text("T"); // Display a loading message or a placeholder
                              }
                              if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }
                              String fullName = snapshot.data ?? "";
                              return Text(
                                fullName.substring(0,1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              );
                            },
                          ),
                          backgroundColor: const Color(0xFFee7b64),
                        ),
                        title: FutureBuilder<String>(
                          future: getFullName(members[index]),
                          builder: (context, snapshot){
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("User Name"); // Display a loading message or a placeholder
                            }
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }
                            String fullName = snapshot.data ?? "";
                            return Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                        subtitle: Text(members[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
