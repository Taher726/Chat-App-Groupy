import 'package:chatappgroupi/components/list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOutTap;
  final String profileName;
  const MyDrawer({super.key, required this.onProfileTap, required this.onSignOutTap, required this.profileName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Padding(
            padding:const EdgeInsets.only(top: 50), // Add padding to the top of the Icon
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Add padding around the icon to make it circular
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[700],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20), // Add spacing between Icon and profile name
                Text(
                  profileName, // Replace with actual profile name
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25,),
          MyListTile(
            text: "H O M E",
            onTap: () => Navigator.pop(context),
            icon: Icons.home,
          ),
          MyListTile(
            text: "P R O F I L E",
            onTap: onProfileTap,
            icon: Icons.person,
          ),
          MyListTile(
            text: "L O G O U T",
            onTap: onSignOutTap,
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }
}
