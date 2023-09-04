import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final IconData icon;
  const MyListTile({super.key, required this.text, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Color(0xFFee7b64),
        ),
        onTap: onTap,
        title: Text(
          text,
          style: TextStyle(
              color: Color(0xFFee7b64)
          ),
        ),
      ),
    );
  }
}
