import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController _name = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _contact = new TextEditingController();
  TextEditingController _password = new TextEditingController();


  File _image = null;

  final ImagePicker _picker = ImagePicker();
  _imgFromCamera() async {
    PickedFile image = await _picker.getImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = File(image.path);
      //firebase
    });
  }

  _imgFromGallery() async {
    PickedFile image = await _picker.getImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = File(image.path);
    });
  }

  Future<bool> checkEmail(email) async
  {
    await FirebaseFirestore.instance.collection("Users")
        .where("Email", isEqualTo: email)
        .get().then((value){
      if(value.docs.length <= 0){
        return true;
      }
      else{
          return false;
      }
    });
    return false;
  }

  Future<bool> checkContact(contact) async
  {
    await FirebaseFirestore.instance.collection("Users")
        .where("Contact", isEqualTo: contact)
        .get().then((value){
      if(value.docs.length <= 0){
        return true;
      }
      else{
        return false;
      }
    });
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  child: (_image == null)?Text("Please select an image"):Image.file(_image, height: 100, width: 100,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_enhance_outlined),
                      onPressed: () {
                        _imgFromCamera();
                      },
                      color: Colors.grey,
                    ),
                    IconButton(
                      icon: Icon(Icons.photo_library_outlined),
                      onPressed: () {
                        _imgFromGallery();
                      },
                      color: Colors.grey,
                    ),
                  ],
                ),
                TextField(
                  controller: _name,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter Name"
                  ),
                ),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter Email Id"
                  ),
                ),
                TextField(
                  controller: _contact,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                      labelText: "Contact no.",
                      hintText: "Enter Contact number"
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter Password"
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                ElevatedButton(
                  onPressed: () async{

                    await FirebaseFirestore.instance.collection("Users")
                        .where("Email", isEqualTo: _email.text.toString())
                        .get().then((value) async {
                      if(value.docs.length <= 0) {
                        await FirebaseFirestore.instance.collection("Users")
                        .where("Contact", isEqualTo: _contact.text.toString())
                        .get().then((value) async {
                          if(value.docs.length <= 0){
                            var filename = DateTime.now().toString()+".jpg";

                            await FirebaseStorage.instance.ref().child(filename).putFile(_image).whenComplete(() {}).then((value) async{

                              var fPath = await value.ref.getDownloadURL();
                              var filepath = fPath.toString();

                              var name = _name.text.toString();
                              var email = _email.text.toString();
                              var contact = _contact.text.toString();
                              var password = _password.text.toString();

                              FirebaseFirestore.instance.collection("Users").add({
                                "Name":name,
                                "Email":email,
                                "Contact":contact,
                                "Password":password,
                                "Profile":filepath,
                              });

                              Fluttertoast.showToast(
                                  msg: "Inserted successfully",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );

                              _name.clear();
                              _email.clear();
                              _contact.clear();
                              _password.clear();
                              setState(() {
                                _image = null;
                              });

                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed("LoginPage");
                          }
                          else{
                            Fluttertoast.showToast(
                                msg: "Contact already in use",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
                        });
                      }
                      else {
                        Fluttertoast.showToast(
                            msg: "Email already in use",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    });
                  },
                  child: Text("Submit"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed("LoginPage");
                  },
                  child: Text(
                    "Login?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
