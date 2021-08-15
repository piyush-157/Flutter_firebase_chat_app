import 'package:firebase_chat_system/AfterLogin.dart';
import 'package:firebase_chat_system/ChatScreen.dart';
import 'package:firebase_chat_system/HomePage.dart';
import 'package:firebase_chat_system/LoadingScreen.dart';
import 'package:firebase_chat_system/LoginPage.dart';
import 'package:firebase_chat_system/Profile.dart';
import 'package:firebase_chat_system/WelcomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
      routes: {
        "HomePage": (BuildContext context) => HomePage(),
        "LoginPage": (BuildContext context) => LoginPage(),
        "WelcomePage": (BuildContext context) => WelcomePage(),
        "ChatScreen": (BuildContext context) => ChatScreen(),
        "Profile": (BuildContext context) => Profile(),
        "AfterLogin": (BuildContext context) => AfterLogin(),
      },
    );
  }
}

