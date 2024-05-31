import 'package:chat_app/screens/auth/loginScreen.dart';
import 'package:chat_app/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'firebase_options.dart';
void main() async{
  await Hive.initFlutter();
  var box=Hive.openBox("mybox");
  var box1=Hive.openBox("myProfile");
  var ourmessage=Hive.openBox("chat");
  var yourmessage=Hive.openBox("yourchat");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var auth=FirebaseAuth.instance;
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 1,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  auth.currentUser==null?LoginScreen():HomeScreen(),
    );
  }
}
