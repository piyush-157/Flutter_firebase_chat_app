import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String image = "";
  String name = "";
  String contact = "";
  String email = "";

  getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("id");
    print("id:" + id);
    var collection = FirebaseFirestore.instance.collection("Users");
    collection.doc(id).get().then((value) {
      print(value["Name"]);
      setState(() {
        name = value["Name"];
        contact = value["Contact"];
        email = value["Email"];
        image = value["Profile"];
      });
    });
  }


  @override
  initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 90.0,
                backgroundImage:
                NetworkImage(image),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 25
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            email,
            style: TextStyle(
                fontSize: 25
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            contact,
            style: TextStyle(
                fontSize: 25
            ),
          ),
        ],
      ),
    );
  }
}
