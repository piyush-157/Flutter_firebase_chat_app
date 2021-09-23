import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_system/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  String name = "";
  String email = "";
  String loginId = "";

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("Email");
      loginId = prefs.getString("id");
      print(email);
      print("Login: " + loginId);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {

    final dateTime = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("Profile");
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("isLogin", false);
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed("LoginPage");
              Fluttertoast.showToast(
                  msg: "Logged out successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            },
            icon: Icon(Icons.login_outlined),
          ),
        ],
        title: Text("Chats"),
      ),
      body: (email!="")?StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").doc(loginId).collection("chats").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, position){
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30.0,
                    backgroundImage:
                    NetworkImage(snapshot.data.docs[position]["image"].toString()),
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(snapshot.data.docs[position]["name"].toString()),
                  subtitle: Text(snapshot.data.docs[position]["lastmessage"].toString()),
                  trailing: Text(snapshot.data.docs[position]["timestamp"].toString()),
                  onTap: () {
                    var id = snapshot.data.docs[position].id;
                    Navigator.of(context).pushNamed("ChatScreen", arguments: {"id":id});
                  },
                ),
              );
            },
          );
        },
      ):Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("AfterLogin");
        },
        child: Icon(Icons.chat_outlined),
      ),
    );
  }
}
