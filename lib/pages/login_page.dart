import 'package:chatappgroupi/components/login_register_button.dart';
import 'package:chatappgroupi/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final String email = "";
  final String password = "";
  final formKey = GlobalKey<FormState>();

  void displayMessage(String message){
    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          title: Text(message),
        )
    );
  }

  void signIn() async{
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Color(0xFFee7b64),
        ),
      )
    );
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
      );
      //Pop loading circle
      Navigator.pop(context);
    }
    on FirebaseAuthException catch (e){
      //Pop loading circle
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
                      "Login now to see what they are talking!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Image.asset("assets/login1.png"),
                    const SizedBox(height: 25,),
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
                      onTap: signIn,
                      text: "Sign In",
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Not a member?",
                        ),
                        const SizedBox(width: 5,),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Register now",
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
