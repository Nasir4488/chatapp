
import 'package:chat_app/screens/auth/userCon.dart';
import 'package:chat_app/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserController userController=UserController();
  Future<UserCredential> signInWithGoogle() async {
    print("Nasir");
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var mq=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Wecome to Chat",style: TextStyle(fontWeight: FontWeight.normal),),
      ),
      body:Center(
        child:Column(
          children: [
            Container(
              color: Colors.grey,
              width: 120,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final userCredential = await signInWithGoogle();
                    if (userCredential.user != null) {
                      userController.create_user();
                      Get.to(()=>HomeScreen());
                    } else if(await(userController.userExists())) {
                      Get.to(()=>HomeScreen());
                    }
                  } catch (e) {
                    print('Error during Google sign-in: $e');
                  }
                },
                child: Text("Sign in with Google"),
              ),

            ),
          ],
        )
      )
    );
  }
}
