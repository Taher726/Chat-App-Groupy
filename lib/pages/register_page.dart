import 'package:chatappgroupi/components/login_register_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void displayMessage(String message){
    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          title: Text(message),
        )
    );
  }

  void signUp() async{
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFee7b64),
        ),
      )
    );
    try{
      //Try creating User
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );

      //After creating the user, create a new document in cloud firestore called Users
      FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.uid).set({
        "email": emailController.text,
        "fullName": fullNameController.text,
        "groups": [],
        "bio": "Empty bio",
      });
      Navigator.pop(context);
    }
    on FirebaseAuthException catch (e){
      //Pop the circle
      Navigator.pop(context);
      //Show error
      displayMessage(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Groupy",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      "Create your account now to chat and explore",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Image.asset("assets/login1.png"),
                    const SizedBox(height: 25,),
                    MyTextField(
                      text: "Full Name",
                      obscureText: false,
                      controller: fullNameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20,),
                    MyTextField(
                      text: "Email",
                      obscureText: false,
                      controller: emailController,
                      icon: Icons.mail,
                    ),
                    const SizedBox(height: 20,),
                    MyTextField(
                      text: "Password",
                      obscureText: true,
                      controller: passwordController,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 20,),
                    MyButton(
                      onTap: signUp,
                      text: "Sign Up",
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                        ),
                        const SizedBox(width: 5,),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login now",
                            style: TextStyle(
                              fontWeight:FontWeight.bold,
                              color: Color(0xFFee7b64),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
