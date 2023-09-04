import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xFFee7b64),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            )
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
