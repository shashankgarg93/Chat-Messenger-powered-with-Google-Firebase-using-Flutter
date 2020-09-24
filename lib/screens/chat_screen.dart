import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textcontrol = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String message;
  //the getuser method in udemy course doesnt work which sets a var user as _auth.currentuser and then uses that.
  //Insted i am using _auth.currentuser directly.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('created_at',descending: true).snapshots(),
              builder: (context,snapshot)
              {
                List<ChatText> m = [];
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                {
                  final message = snapshot.data.documents;
                  for( var mess in message)
                  {
                    final mtext = mess.data()['text'];
                    final msender = mess.data()['sender'];
                    final currentuser = _auth.currentUser.email;

                    final messagewidget = ChatText(text: mtext, sender: msender,isme: currentuser==msender,);
                    m.add(messagewidget);
                  }
                return Expanded(
                  child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      children: m
                  ),
                );}
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textcontrol,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textcontrol.clear();
                      //Implement send functionality.
                      _firestore.collection('messages').add({'text':message,'sender':_auth.currentUser.email,'created_at':FieldValue.serverTimestamp()});

                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ChatText extends StatelessWidget {
  String text;
  String sender;
  bool isme;
  ChatText({this.text,this.sender,this.isme});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            color: isme? Colors.lightBlueAccent : Colors.white,
            borderRadius: isme ? BorderRadius.only(topLeft: Radius.circular(30),bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30))
            : BorderRadius.only(topRight: Radius.circular(30),bottomRight: Radius.circular(30),bottomLeft: Radius.circular(30)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(text,
                style: TextStyle(
                  color: isme ? Colors.white : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

