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
import 'gameinfo.dart';

class GameStorePage extends StatefulWidget {
  GameStorePage({Key key, this.auth, this.currentUser, this.users, this.navigateToRoom})
      : super(key: key);

  final BaseAuth auth;
  final GUser currentUser;
  final Users users;
  final Function(String, String) navigateToRoom;

  @override
  State<StatefulWidget> createState() => new _GameStorePageState();
}

class _GameStorePageState extends State<GameStorePage> {
  @override
  void initState() {
    super.initState();

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

  Widget _buildGameRoomsList() {
    // TODO: update this to work through a service
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('rooms')
            .orderBy('name', descending: false)
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
              shrinkWrap: true,
              itemBuilder: (_, int index) => _buildRoomBox(
                  snapshot.data.documents[index],
                  snapshot.data.documents[index].documentID),
              itemCount: snapshot.data.documents.length,
            );
          }
        });
  }

  Widget _buildRoomBox(dynamic roomData, doc_id) {
    return Center(
        child: Container(
      color: Style.Colors.darkGrey,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      margin: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        splashColor: Colors.grey,
        onTap: () {
      //    print(roomData['video_url']);
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => VideoApp(
          //               video_url: roomData['video_url']
          //             )));
          bool alreadycontainsuser=(roomData['users']!=null) && (roomData['users'].contains(widget.currentUser.id));
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => GameInfoPage(
              auth: widget.auth, currentUser: widget.currentUser, users: widget.users, gameData: roomData, navigateToRoom: widget.navigateToRoom, alreadyadded: alreadycontainsuser
            )
          ));
          //load relevant event and message
          //Navigator.pop(context);
        },
        child: ListTile(
          leading: Image.network(
            roomData['image_url'],
          ),
          title: Text(
            roomData['name'],
            style: Style.TextTemplate.drawer_listTitle,
          ),
          //subtitle: Text('ID: ' + roomData['id']),
        ),
      ),
    ));
  }
 @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            "Game Store",
            style: Style.TextTemplate.app_bar,
          ),
        ),
        backgroundColor: Style.Colors.darkGrey,

        //changed to GAME HAUS

        ),
      body:
      ListView(
        children: <Widget> [
          _createColorsRow(),
          _buildGameRoomsList()
        ]
      )
      );

  }

}
