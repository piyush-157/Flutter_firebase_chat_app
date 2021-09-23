import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _contact = new TextEditingController();
  TextEditingController _password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _contact,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: "Contact",
                hintText: "Enter your Contact no."
              ),
            ),
            TextField(
              controller: _password,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your Password"
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed("HomePage");
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("Users")
                    .where("Contact",isEqualTo: _contact.text.toString())
                    .where("Password",isEqualTo: _password.text.toString())
                    .get().then((document) async {
                      var data = document.docs;
                   if(document.docs.length<=0)
                     {
                       Fluttertoast.showToast(
                           msg: "Contact or Password incorrect",
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.BOTTOM,
                           timeInSecForIosWeb: 1,
                           backgroundColor: Colors.red,
                           textColor: Colors.white,
                           fontSize: 16.0
                       );
                     }
                   else
                     {
                       Fluttertoast.showToast(
                           msg: "Login Successful!!",
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.BOTTOM,
                           timeInSecForIosWeb: 1,
                           backgroundColor: Colors.blue,
                           textColor: Colors.white,
                           fontSize: 16.0
                       );
                       print(data[0]["Name"]);
                       var id = data[0].id;
                       SharedPreferences prefs = await SharedPreferences.getInstance();
                       prefs.setBool("isLogin", true);
                       prefs.setString("id", id);
                       prefs.setString("Email", data[0]["Email"]);
                       print("Email:" + data[0]["Email"]);
                       print("id: " + id);
                       Navigator.of(context).pop();
                       //x  Navigator.of(context).pushNamed("AfterLogin");
                       Navigator.of(context).pushNamed("WelcomePage", arguments: {"id": id});
                     }
                });
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
