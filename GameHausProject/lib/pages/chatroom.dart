import 'dart:convert';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';

@visibleForTesting
class ChatPage extends StatefulWidget {
  ChatPage(
      {Key key,
      this.title,
      this.roomId,
      this.chatId,
      this.auth,
      this.currentUser})
      : super(key: key);

  final String title;
  final String roomId;
  final String chatId;
  final BaseAuth auth;
  final GUser currentUser;

  @override
  State<StatefulWidget> createState() => new _ChatPageState();
}

@visibleForTesting
class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isEmailVerified = false;

  final TextEditingController _textController = new TextEditingController();
  final List<GChatMessage> _messages = <GChatMessage>[];

  bool _isLoading = false;
  bool _isComposing = false;

  String _userNickname;

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _notifsPlugin =
      new FlutterLocalNotificationsPlugin();

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (GChatMessage message in _messages) {
      message.aController.dispose();
    }
    super.dispose();
  }



  @override
  void initState() {
    super.initState();
    _userNickname = widget.currentUser.nickname;
  }



  @visibleForTesting
  void _handleSubmitted(String text) {
    print("New Chatroom");
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    var documentRef = Firestore.instance
    .collection("rooms")
    .document(widget.roomId)
    .collection('chatroom')
    .document(widget.chatId)
    .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentRef, {
        'fromId': widget.currentUser.id,
        'fromNickname': widget.currentUser.nickname,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': text,
        'type': 0
      });
    });
  }

  Widget _buildMessage(dynamic message) {
    GChatMessage gmessage = new GChatMessage(
      text: message['content'],
      nickname: message['fromNickname'],
      aController: new AnimationController(
          duration: new Duration(milliseconds: 600), vsync: this),
    );
    // gmessage.aController.forward();
    return gmessage;
  }

  Widget _wrapWithCardColorBox(Widget toWrap) {
    return new Container(
      decoration: new BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: toWrap,
    );
  }

  Widget _wrapWithIconTheme(Widget toWrap) {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: toWrap);
  }

  Widget _buildTextComposer() {
    return _wrapWithCardColorBox(_wrapWithIconTheme(new Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        child: new Row(children: <Widget>[
          new Flexible(
              child: new TextField(
            controller: _textController,
            onChanged: (String text) {
              setState(() {
                _isComposing = text.length > 0;
              });
            },
            onSubmitted: _handleSubmitted,
            decoration:
                new InputDecoration.collapsed(hintText: "Send a message"),
          )),
          new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              ))
        ]))));
  }

  Widget _buildMessageList() {
    return Expanded(
      child: new StreamBuilder(
          stream: Firestore.instance
              .collection("rooms")
              .document(widget.roomId)
              .collection('chatroom')
              .document(widget.chatId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(30)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            } else {
              return ListView.builder(
                padding: new EdgeInsets.all(6.0),
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (_, int index) =>
                    _buildMessage(snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
              );
            }
          }),
    );
  }
  Widget _createColorsRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.blue,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.red,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.yellow,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.green,
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            widget.title,
            style: Style.TextTemplate.app_bar,
          ),
        ),
        backgroundColor: Style.Colors.darkGrey,

        //changed to GAME HAUS

        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _createColorsRow(),
              _buildMessageList(),
              new Divider(height: 1.0),
              _buildTextComposer()
            ],
          ),
        ));
  }
}

class GChatMessage extends StatelessWidget {
  GChatMessage({this.text, this.aController, this.nickname, this.photoUrl});

  final String text;
  final String nickname;
  final String photoUrl;
  final AnimationController aController;

  Widget _wrapWithEaseOutAnimation(Widget toWrap) {
    return new SizeTransition(
      sizeFactor:
          new CurvedAnimation(parent: aController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: toWrap,
    );
  }

  NetworkImage GetImage(){

    if (photoUrl==null || photoUrl==''){
       return NetworkImage('https://robohash.org/'+(nickname ?? ""));
    }else{
      return NetworkImage(photoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 12.0),
              child: new CircleAvatar(
                backgroundImage: GetImage(),
                //child: new Text(nickname[0],style: Style.TextTemplate.button_signup,)
              )
              ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(nickname, style: Style.TextTemplate.chat_title),
                new Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  child: new Text(text, style: Style.TextTemplate.chat_description,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
