import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController _text = TextEditingController();

  String name = "";
  String image = "";

  final dateTime = DateTime.now();

  var receiverid="";

  var senderid="";

  File _image = null;

  final ImagePicker _picker = ImagePicker();
  _imgFromCamera() async {
    PickedFile image = await _picker.getImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() async {
      _image = File(image.path);
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      var filename = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
      await FirebaseStorage.instance.ref().child(filename).putFile(_image).whenComplete((){}).then((value) async {
        var fPath = await value.ref.getDownloadURL();
        var filePath = fPath.toString();
        FirebaseFirestore.instance.collection("Users").doc(senderid).collection("chats").doc(receiverid).collection("messages").add({
          "sender":senderid,
          "receiver":receiverid,
          "message":filePath,
          "timestamp": timeStamp,
          "isRead": false,
          "type": "image"
        });

        FirebaseFirestore.instance.collection("Users").doc(receiverid).collection("chats").doc(senderid).collection("messages").add({
          "sender":senderid,
          "receiver":receiverid,
          "message":filePath,
          "timestamp": timeStamp,
          "isRead": false,
          "type": "image"
        });
      });
    });
    Navigator.of(context).pop();
  }

  _imgFromGallery() async {
    PickedFile image = await _picker.getImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() async {
      _image = File(image.path);
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      var filename = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
      await FirebaseStorage.instance.ref().child(filename).putFile(_image).whenComplete((){}).then((value) async {
        var fPath = await value.ref.getDownloadURL();
        var filePath = fPath.toString();
        FirebaseFirestore.instance.collection("Users").doc(senderid).collection("chats").doc(receiverid).collection("messages").add({
          "sender":senderid,
          "receiver":receiverid,
          "message":filePath,
          "timestamp": timeStamp,
          "isRead": false,
          "type": "image"
        });

        FirebaseFirestore.instance.collection("Users").doc(receiverid).collection("chats").doc(senderid).collection("messages").add({
          "sender":senderid,
          "receiver":receiverid,
          "message":filePath,
          "timestamp": timeStamp,
          "isRead": false,
          "type": "image"
        });


      });
    });

  }

  showAlert() {
      AlertDialog dialog = new AlertDialog(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                _imgFromGallery();
                Navigator.of(context).pop();
              },
              child: Text(
                "Gallery",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _imgFromCamera();
                Navigator.of(context).pop();
              },
              child: Text(
                "Camera",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
            ),
          ],
        ),
      );

      showDialog(
        context: context,
        builder: (BuildContext context){
          return dialog;
        }
      );
  }

  getData(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    senderid = prefs.getString("id");
    var collection = FirebaseFirestore.instance.collection("Users");
    collection.doc(id).get().then((value) {
      print(value["Name"]);
      setState(() {
        name = value["Name"];
        image = value["Profile"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, (){
      Map args =ModalRoute.of(context).settings.arguments as Map;
      if(args != null){
        setState(() {
          receiverid = args["id"];
          getData(receiverid);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage:
              NetworkImage(image),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(
              width: 10,
            ),
            Text(name),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              (receiverid != "" && senderid != "")?Flexible(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("Users").doc(senderid).collection("chats").doc(receiverid).collection("messages")
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                      if(!snapshot.hasData){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, position){
                            var sender = snapshot.data.docs[position]["sender"].toString();
                            if(sender==senderid)
                              {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    (snapshot.data.docs[position]["type"].toString() == "text")?Card(
                                      color: Colors.blue,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data.docs[position]["message"].toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      ),
                                    ): Image.network(
                                      snapshot.data.docs[position]["message"],
                                      fit: BoxFit.contain,
                                      height: 200,
                                      width: 100,
                                    ),
                                  ],
                                );
                              }
                            else
                              {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    (snapshot.data.docs[position]["type"].toString() == "text")?Card(
                                      color: Colors.white,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            snapshot.data.docs[position]["message"].toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )
                                      ),
                                    ): Image.network(
                                      snapshot.data.docs[position]["message"],
                                      height: 200,
                                      width: 100,
                                    ),
                                  ],
                                );
                              }
                          }
                      );
                    }
                ),
              ):Text("loading..."),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              showAlert();
                            },
                            icon: Icon(Icons.image),
                          ),
                          Flexible(
                            child: Container(
                              child: TextField(
                                onSubmitted: (value) {},
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                                controller: _text,
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  focusColor: Colors.blue,
                                ),
                              ),
                            ),
                          ),

                          // Button send message
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              var message = _text.text.toString();
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              // senderid = prefs.getString("id");
                              var timeStamp = DateTime.now().millisecondsSinceEpoch;

                              print(timeStamp);

                              FirebaseFirestore.instance.collection("Users").doc(senderid).collection("chats").doc(receiverid).collection("messages").add({
                                "sender":senderid,
                                "receiver":receiverid,
                                "message":message,
                                "timestamp": timeStamp,
                                "isRead": false,
                                "type": "text"
                              });

                              FirebaseFirestore.instance.collection("Users").doc(receiverid).collection("chats").doc(senderid).collection("messages").add({
                                "sender":senderid,
                                "receiver":receiverid,
                                "message":message,
                                "timestamp": timeStamp,
                                "isRead": false,
                                "type": "text"
                              });

                              FirebaseFirestore.instance.collection("Users").doc(senderid).collection("chats").doc(receiverid).update({
                                "lastmessage":message,
                                "timestamp": timeStamp,
                                "name": name,
                                "image": image
                              });

                              FirebaseFirestore.instance.collection("Users").doc(receiverid).collection("chats").doc(senderid).update({
                                "lastmessage":message,
                                "timestamp": timeStamp,
                              });


                              _text.clear();
                            },
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      width: double.infinity,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 0.4
                            // top: BorderSide(color: Colors.grey, width: 0.5)
                        ),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
