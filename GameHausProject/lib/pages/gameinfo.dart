import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'playgame.dart';

class GameInfoPage extends StatefulWidget {
  GameInfoPage({Key key, this.auth, this.currentUser, this.users, this.gameData, this.navigateToRoom, this.alreadyadded}): super(key: key);
  final BaseAuth auth;
  final GUser currentUser;
  final Users users;
  final DocumentSnapshot gameData;
  final Function(String, String) navigateToRoom;
  bool alreadyadded;

  @override
  State<StatefulWidget> createState() => new _GameInfoPageState();
}

class _GameInfoPageState extends State<GameInfoPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _addToUserRooms() async {
    await widget.gameData.reference.updateData({'users':FieldValue.arrayUnion([widget.currentUser.id])});
      setState((){ widget.alreadyadded=true; });
  }
  void _navigateToPlayGames() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PlayGamePage(gameurl: widget.gameData['game_url'])));
  }

  void _navigateToRoom(){
    widget.navigateToRoom(widget.gameData.documentID, widget.gameData['name']);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        //leading: Icon(Icons.keyboard_backspace, color: Colors.white,),
        title: Text(
          widget.gameData['name'],
          style: Style.TextTemplate.app_bar,
        ),
      ),
      body: ListView(
        children: <Widget>[
          _createColorsRow(),
          _createGamePicture(),
          // FlatButton(
          //   child: Text("Play", style:  new TextStyle(fontSize: 17.0, color: Colors.white)),
          //   onPressed:_navigateToPlayGames ),
          // FlatButton(
          //   child: Text("Add to Rooms", style:  new TextStyle(fontSize: 17.0, color: Colors.white)),
          //   onPressed: _addToUserRooms
          // )
          userButtons()
        ],
      ),
    );
  }

  Widget userButtons(){
    if (widget.alreadyadded==false){
      return Column(
        children: <Widget>[
        FlatButton(
          child: Text("Add to Rooms", style:  new TextStyle(fontSize: 17.0, color: Colors.white)),
          onPressed: _addToUserRooms
        )
      ]
      );
    } else {
      return Column(
        children: <Widget>[
        FlatButton(
          child: Text("Play", style:  new TextStyle(fontSize: 17.0, color: Colors.white)),
          onPressed:_navigateToPlayGames ),
          FlatButton(
          child: Text("Go to Room Page", style:  new TextStyle(fontSize: 17.0, color: Colors.white)),
          onPressed: _navigateToRoom
        )
        ]
      );
    }

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


  Widget _createGamePicture(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            height: 170,
            width: 170,
            padding: EdgeInsets.only(bottom: 20),
            margin: EdgeInsets.only(top: 25,bottom: 15),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(widget.gameData['image_url']),
                  fit: BoxFit.cover
              ),
              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
              border: Border.all(
                  color: Colors.white,
                  width: 3
              ),

            ),
          ),
        ),
        //Padding(
        //  padding: EdgeInsets.only(left: 17, top: 25, bottom: 10),
      //    child: Text("ATTENDING THESE EVENTS", style: Style.TextTemplate.heading, textAlign: TextAlign.start,),
      //  )
      ],
    );
  }












}
