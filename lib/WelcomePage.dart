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

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("Email");
      print(email);
    });
    getUsers(email);
  }


  List<Widget> mainData = new List<Widget>();
  final dateTime = DateTime.now();

  getUsers(email) async{
    List<Widget> temp = new List<Widget>();
    await FirebaseFirestore.instance.collection("Users").where("Email",isNotEqualTo: email).get().then((value) {
      value.docs.forEach((element) {
        temp.add(Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage:
              NetworkImage(element["Profile"].toString()),
              backgroundColor: Colors.transparent,
            ),
            title: Text(element["Name"].toString()),
            subtitle: Text("Status"),
            trailing: Text(
              '${dateTime.hour} : ${dateTime.minute}',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12
              ),
            ),
            onTap: () {
              var id = element.id;
              Navigator.of(context).pushNamed("ChatScreen", arguments: {"id":id});
            },
          ),
        ));
      });
      setState(() {
        mainData = temp;
      });
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
      body: (email == "")?Center(child: CircularProgressIndicator(),):ListView(
        children: mainData,
      ),
      // body: (email!="")?StreamBuilder(
      //   stream: FirebaseFirestore.instance.collection("Users").where("Email",isNotEqualTo: email).snapshots(),
      //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
      //     if(!snapshot.hasData){
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     return ListView.builder(
      //       itemCount: snapshot.data.docs.length,
      //       itemBuilder: (context, position){
      //         return Card(
      //           child: ListTile(
      //             leading: CircleAvatar(
      //               radius: 30.0,
      //               backgroundImage:
      //               NetworkImage(snapshot.data.docs[position]["Profile"].toString()),
      //               backgroundColor: Colors.transparent,
      //             ),
      //             title: Text(snapshot.data.docs[position]["Name"].toString()),
      //             subtitle: Text("Status"),
      //             trailing: Text(
      //               '${dateTime.hour} : ${dateTime.minute}',
      //               style: TextStyle(
      //                 color: Colors.grey,
      //                 fontSize: 12
      //               ),
      //             ),
      //             onTap: () {
      //               var id = snapshot.data.docs[position].id;
      //               Navigator.of(context).pushNamed("ChatScreen", arguments: {"id":id});
      //             },
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ):Center(child: CircularProgressIndicator()),
    );
  }
}
