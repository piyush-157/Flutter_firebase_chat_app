import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfterLogin extends StatefulWidget {

  @override
  _AfterLoginState createState() => _AfterLoginState();
}

class _AfterLoginState extends State<AfterLogin> {

  var id;
  final dateTime = DateTime.now();
  String email = "";

  getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString("id");
    });
  }

  // getData() {
  //   FirebaseFirestore.instance.collection("Users").doc(id).get().then((value) {
  //     print(value["Name"]);
  //   });
  // }

  getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    email = prefs.getString("Email");
    print("id:" + id);
    var collection = FirebaseFirestore.instance.collection("Users");
    collection.doc(id).get().then((value) {
      print(value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("After Login"),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).pushNamed("Profile");
        //     },
        //     icon: Icon(Icons.settings),
        //   ),
        //   IconButton(
        //     onPressed: () async {
        //       SharedPreferences prefs = await SharedPreferences.getInstance();
        //       prefs.setBool("isLogin", false);
        //       Navigator.of(context).pop();
        //       Navigator.of(context).pushNamed("LoginPage");
        //       Fluttertoast.showToast(
        //           msg: "Logged out successfully",
        //           toastLength: Toast.LENGTH_SHORT,
        //           gravity: ToastGravity.BOTTOM,
        //           timeInSecForIosWeb: 1,
        //           backgroundColor: Colors.blue,
        //           textColor: Colors.white,
        //           fontSize: 16.0
        //       );
        //     },
        //     icon: Icon(Icons.login_outlined),
        //   ),
        // ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").where("Email",isNotEqualTo: email).snapshots(),
        builder: (BuildContext context, snapshot){
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, position){
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30.0,
                    backgroundImage:
                    NetworkImage(snapshot.data.docs[position]["Profile"].toString()),
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(snapshot.data.docs[position]["Name"].toString()),
                  subtitle: Text("Status"),
                  trailing: Text(
                    '${dateTime.hour} : ${dateTime.minute}',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12
                    ),
                  ),
                  onTap: () {
                    var id = snapshot.data.docs[position].id;
                    Navigator.of(context).pushNamed("ChatScreen", arguments: {"id":id});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
