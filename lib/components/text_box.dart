import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String sectionName;
  final String text;
  final void Function()? onTap;
  const MyTextBox({super.key, required this.sectionName, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFee7b64),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${sectionName} :",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
          Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          )
        ],
      ),
    );
  }
}
