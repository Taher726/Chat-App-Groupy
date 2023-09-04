import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String text;
  final bool obscureText;
  final TextEditingController controller;
  final IconData icon;
  const MyTextField({super.key, required this.text, required this.obscureText, required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (val){
        if(val!.length < 6 && text=="Password"){
          return "Password must be at least 6 charachters";
        }
        else if(text=="Email"){
          return RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(val!)
              ? null
              : "Please enter a valid email";
        }
        else{
          return null;
        }
      },
      decoration: InputDecoration(
        labelText: text ,
        prefixIcon: Icon(
          icon,
          color: Color(0xFFee7b64),
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w300,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFee7b64),
            width: 2
          ),
        ),
        enabledBorder: OutlineInputBorder(
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
    );
  }
}
