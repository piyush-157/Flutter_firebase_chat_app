import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  // ignore: non_constant_identifier_names
  CheckPrefs() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("isLogin"))
    {
      Future.delayed(Duration(seconds: 1), () {
        if(prefs.getBool("isLogin")==true)
        {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("WelcomePage");
        }
        else
        {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("LoginPage");
        }
      });
    }
    else
    {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("LoginPage");
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Loading your data\n Please wait...",
        ),
      ),
    );
  }
}