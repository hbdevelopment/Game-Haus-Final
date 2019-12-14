import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/event.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/pages/attendance_page.dart';
import 'package:ghfrontend/pages/create_event_page.dart';
import 'package:ghfrontend/pages/profile_page.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/services/date_helper.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;

import 'chatroom.dart';
import 'gamestore.dart';

@visibleForTesting
class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.currentUser, this.onSignedOut, this.users})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final GUser currentUser;
  final Users users;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

@visibleForTesting
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {


  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var eventList;
  bool findMatch=false;
  String selectedRoomId = "m6p76gE4hnigPW4Bi6hJ"; //dota 2
  String selectedRoomName = "DOTA 2";

  bool _isEmailVerified = false;
  TabController controller;

  final TextEditingController _textController = new TextEditingController();
  bool _isLoading = false;
  bool _isComposing = false;

  String _userNickname;

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _notifsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    updatedatabase();
    controller = new TabController(vsync: this, length: 2);
    _checkEmailVerification();
    _registerNotifications();
    _configureLocalNotifications();

    _userNickname = widget.currentUser.nickname;

    drawerTitle = "ROOMS";
    currentIndexPage = 0;
  }

  void updatedatabase() async{
    var query = await Firestore.instance.collectionGroup("events").where('__name__', isEqualTo: "events/4q9H1qbP8oJdk1ke9PGb").getDocuments();
    for (var document in query.documents){
      await document.reference.updateData({'title': 'New Title5'});
    }


  }
  @visibleForTesting
  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }
  @visibleForTesting
  bool isEmailVerified(){
    return _isEmailVerified;
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

    super.dispose();
    currentIndexPage = 0;
  }

  void _navigateToCreateEventPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateEventPage(roomId: selectedRoomId, roomName: selectedRoomName)));
  }


  void _showDialog(context, title, description) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text(
              title,
              style: Style.TextTemplate.alert_title,
            ),
            content: new Text(
              description,
              style: Style.TextTemplate.alert_description,
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: Style.TextTemplate.heading,
                  ))
            ],
          );
        });
  }
  void _navigateToProfilePage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                onSignedOut: widget.onSignedOut,
                users: widget.users,
                currentUser: widget.currentUser,
                userId: widget.currentUser.id,
                isMe: true)));
  }

  void _navigateToOtherProfilePage(user_id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                onSignedOut: widget.onSignedOut,
                users: widget.users,
                currentUser: widget.currentUser,isMe: false, userId: user_id,)));
  }

void toGameStore(){
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => GameStorePage(auth: widget.auth,
        currentUser: widget.currentUser,
        users: widget.users,
        navigateToRoom: updatePage)));
}
updatePage(String id, String name){
  setState(() {
    selectedRoomId=id;
    selectedRoomName=name;
  });
}
Widget buildRoomsList(){
  return new Column(
    children: <Widget> [
      _buildGameRoomsList(),
      new Divider(height: 1.0),
      Align(
      alignment: Alignment.centerRight,
      child: Row(
      children: <Widget> [Image.asset('assets/images/gh_add_icon.png', scale: 3),
      FlatButton(child: Text("Add New Room",
      style: Style.TextTemplate.event_title), onPressed: toGameStore )]
      ,mainAxisAlignment: MainAxisAlignment.center
    )

  )
    ]
  );
}

  // TODO: rename these so they make sense? These aren't rooms anymore they are games
  Widget _buildGameRoomsList() {
    // TODO: update this to work through a service
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('rooms').where('users', arrayContains: widget.currentUser.id)
            //.orderBy('name', descending: false)
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
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text(
                  "No Rooms",
                  style: Style.TextTemplate.tf_hint,
                ),
              );
            };
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

          //load relevant event and message
          setState(() {

            selectedRoomId = doc_id;
            selectedRoomName = roomData['name'];
          });
          Navigator.pop(context);
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

  Widget _buildEventList() {
    return Scaffold(

        body:
        Column(
          children: <Widget>[
            FlatButton(child: Text("Find Matching Events",
            style: Style.TextTemplate.event_title), onPressed: () {
              if (widget.currentUser.listOfJson!=null && widget.currentUser.listOfJson[selectedRoomName]!=null) {
              setState((){
                findMatch=!findMatch;
              });
            }
            }),
            Expanded(
          child: _buildNewList(),
        )
          ]
        )
    );
  }


  Widget _buildNewList() {
    return new StreamBuilder(
        stream: _eventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text(
                  "No Events",
                  style: Style.TextTemplate.tf_hint,
                ),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemBuilder: (_, int index) =>
                    _buildEventBox(snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
              );
            }
          }
        });
  }

  Stream _eventsStream() {
    if (findMatch==true){
      //print(widget.currentUser.listOfJson["Overwatch"]);
      int currentUserLevel=jsonDecode(widget.currentUser.listOfJson[selectedRoomName])["level"];
      print(currentUserLevel);
      return Firestore.instance.collection("events").where("id", isEqualTo: selectedRoomId).where("average_level", isLessThanOrEqualTo: (currentUserLevel+20)).where("average_level", isGreaterThanOrEqualTo: (currentUserLevel-20)).limit(60).snapshots();
    }
    return Firestore.instance
        .collection("events")
        //.orderBy("dateTime", descending: false)
        .where("id", isEqualTo: selectedRoomId)
        .limit(60)
        .snapshots();
  }

  Widget _buildEventBox(dynamic eventData) {
    String name = "";
    name = eventData["user_nickname"] ?? "";
    String roboUrl = "https://robohash.org/" + name;
    String created_uid = eventData["user_id"];


    Image eventImage;
    if (eventData["image_url"] == null) {
      eventImage = Image(
        image: AssetImage('assets/images/event_placeholder.png'),
        fit: BoxFit.fitWidth,
      );
    } else {
      eventImage = Image(
        image: NetworkImage(eventData["image_url"]),
        fit: BoxFit.fitHeight,
      );
    }

    return Card(
        color: Style.Colors.grey,
        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 10, top: 20),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.access_time),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: RichText(
                                text: new TextSpan(children: [
                              TextSpan(
                                text: DateHelper()
                                    .dayFormat(eventData['dateTime'].toDate()),
                                style: Style.TextTemplate.event_day,
                              ),
                              TextSpan(
                                text: DateHelper()
                                    .dateFormat(eventData['dateTime'].toDate()),
                                style: Style.TextTemplate.event_description,
                              )
                            ])),
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 10),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.location_on),
                              Flexible(
                                child: Text(
                                  eventData['location'],
                                  style: Style.TextTemplate.event_description,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        )),
                      Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 10),
                        child:Container(height: 25,width: 100, margin: EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10)
                        ,decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(30),
                                                border: Border.all(color: Colors.white,width: 2.0),
                                              ),

                                                child: Text(eventData['group_type'] ?? "LFG", style: Style.TextTemplate.tf_hint, textAlign: TextAlign.center),

                                            )
                      )  ,
                    Padding(
                      padding: EdgeInsets.only(left: 21, bottom: 10),
                      child: Container(
                        height: 1,
                        width: 12,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 17, bottom: 20),
                        child: Text(eventData['title'],
                            style: Style.TextTemplate.event_title,
                            overflow: TextOverflow.ellipsis)),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          FutureBuilder(
                            future: _handleAttendanceEvent(eventData),
                            builder: (context, snapshots) {
                              if (snapshots.data != null) {
                                if (snapshots.data.length != 0) {
                                  return InkWell(
                                    child: Container(
                                        height: 45,
                                        width: 45,
                                        child: Icon(Icons.check_circle_outline,
                                            color: Style.Colors.brightGreen,
                                            size: 45)),
                                    onTap: () =>
                                        _attendButtonPressed(false, eventData),
                                  );
                                } else {
                                  return InkWell(
                                    child: Container(
                                        height: 45,
                                        width: 45,
                                        child: Icon(Icons.add_circle_outline,
                                            color: Style.Colors.whiteText,
                                            size: 45)),
                                    onTap: () =>
                                        _attendButtonPressed(true, eventData),
                                  );
                                }
                              } else {
                                return InkWell(
                                  child: Container(
                                      height: 45,
                                      width: 45,
                                      child: Icon(Icons.add_circle_outline,
                                          color: Style.Colors.whiteText,
                                          size: 45)),
                                  onTap: () =>
                                      _attendButtonPressed(true, eventData),
                                );
                              }
                            },
                          ),
                          InkWell(
                            child: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                image: DecorationImage(
                                    image: NetworkImage(roboUrl),
                                    fit: BoxFit.cover),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(100.0)),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                            onTap: () => _navigateToOtherProfilePage(created_uid),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 210,
                    child: eventImage),
              )
            ],
          ),
          onTap: () => _eventCardTapped(eventData),
        ));
  }

  Future<List<DocumentSnapshot>> _handleAttendanceEvent(eventData) async {
    GUser user = widget.currentUser;
    var querySnap = await Firestore.instance
        .collection("events")
        .document(eventData.documentID)
        .collection("attendance_uid")
        .where("id", isEqualTo: user.id)
        .getDocuments();

    return querySnap.documents;
  }

  void _eventCardTapped(eventData) async {
    try {
      List<DocumentSnapshot> snapshots =
          await _handleAttendanceEvent(eventData);

      if (snapshots != null) {
        if (snapshots.length != 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AttendancePage(
                        eventData: eventData,
                        currentUser: widget.currentUser,
                        boolAttend: false,
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AttendancePage(
                        eventData: eventData,
                        currentUser: widget.currentUser,
                        boolAttend: true,
                      )));
        }
      }
    } catch (e) {}
  }

  Future<int> findAverage(String documentID) async{
    int total=0;
    int totalamount=0;
    var query = await Firestore.instance.collection("events").document(documentID).collection("attendance_uid").getDocuments();
    if (query==null || query.documents.length==0){
      return 0;
    }
    for (var document in query.documents){
      totalamount=totalamount+1;
      if (document['listOfJson']!=null && document['listOfJson']['Overwatch']!=null){
        //print(document['listOfJson']['Overwatch']);
        total=total+jsonDecode(document['listOfJson']['Overwatch'])['level'];
      }
    }
    int returnval=(total/totalamount).round();
    return returnval.round();
  }

  void _attendButtonPressed(bool, eventData) async {
    Fluttertoast.showToast(msg: "Loading...");
    Event eventObj = Event.fromSnapshot(eventData);
    Map<String, dynamic> data = eventObj.toJson();
    var db=Firestore.instance;
    if (bool == true) {
      print("ATTEND");


      var batch=db.batch();
      batch.setData(db.collection("events").document(eventData.documentID)
          .collection("attendance_uid").document(widget.currentUser.id),widget.currentUser.toJson());
      batch.updateData(db.collection("events").document(eventData.documentID), {"attending_uid": FieldValue.arrayUnion([widget.currentUser.id])});
      await batch.commit();
      findAverage(eventData.documentID).then((value){
        Firestore.instance.collection("events").document(eventData.documentID).updateData({"average_level": value});
        print (value);
      });
      _showDialog(context, "Success", "Successfully attend event");
    } else {
      print("UNATTEND");

      var batch=db.batch();
      batch.delete(db.collection("events").document(eventData.documentID)
          .collection("attendance_uid").document(widget.currentUser.id));
      batch.updateData(db.collection("events").document(eventData.documentID), {"attending_uid": FieldValue.arrayRemove([widget.currentUser.id])});
      await batch.commit();
      findAverage(eventData.documentID).then((value){
        Firestore.instance.collection("events").document(eventData.documentID).updateData({"average_level": value});
        print (value);
      });
      _showDialog(context, "Success", "Successfully unattend event");
    }
    setState((){});
  }

  void _showChatCreationDialog(context) {
    final textController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text(
              "Create New Chatroom",
              style: Style.TextTemplate.alert_title,
            ),
            content: _createTFF("Enter Name", textController, TextInputType.text),
            actions: <Widget>[
              //_createTFF("Enter Name", textController, TextInputType.text),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: Style.TextTemplate.heading,
                  )),
              new FlatButton(
                onPressed: () {
                    Firestore.instance.collection('rooms').document(selectedRoomId).collection('chatroom').add({'name': textController.text});
                    Navigator.of(context).pop();
                },
                child: Text(
                  "Create Chatroom",
                  style: Style.TextTemplate.heading
                )
              )
            ],
          );
        });
  }

  Widget _createTFF(hint, controller, keyboard) {
    return Container(
      child: TextFormField(
        style:
            new TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        controller: controller,
        keyboardType: keyboard,
        autofocus: false,
        decoration: InputDecoration(
          enabled: true,
          hintText: hint,
          hintStyle: Style.TextTemplate.tf_hint,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
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

  Widget _createTabs() {
    return new TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        indicator: new BoxDecoration(
            //color: Style.Colors.primaryColor,
            borderRadius: BorderRadius.circular(30),
            image: new DecorationImage(
              image: new AssetImage('assets/images/gh_tab_indicator.png'),
              fit: BoxFit.scaleDown,
            )),
        tabs: [
          Container(
            height: 65,
            child: new Tab(
              child: Text(
                'EVENTS',
                style: Style.TextTemplate.drawer_subheading,
              ),
            ),
          ),
          Container(
            height: 65,
            child: new Tab(
                child: Text(
              'CHAT',
              style: Style.TextTemplate.drawer_subheading,
            )),
          )
        ]);
  }

  Widget _buildGameNearbyList() {

    return new StreamBuilder(
        stream: Firestore.instance
            .collection('events')
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
            return GridView.builder(
              shrinkWrap: true,
              itemBuilder: (_, int index) => _buildNearbyView(snapshot.data.documents[index]),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (265 / 400),
            ),
              itemCount: snapshot.data.documents.length,
            );
          }
        });
  }

  Widget _buildNearbyView(DocumentSnapshot eventSnap) {

    Event eventData = Event.fromSnapshot(eventSnap);

    Widget eventImage;
    if (eventData.image_url == null) {
        eventImage = Text(
          "No Image",
          style: Style.TextTemplate.heading,
        );
    } else {
      eventImage = Image(
        image: NetworkImage(eventData.image_url),
        fit: BoxFit.fill,
      );
    }

    return InkWell(
      child: Container(
        width: 220,
        height: 400,
        padding: EdgeInsets.only(bottom: 10),
        margin: EdgeInsets.only(right: 10, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Style.Colors.darkGrey),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                width: 200,
                height: 100,
                color: Style.Colors.grey,
                child: Center(
                    child: eventImage
                )),
            Container(
              padding: EdgeInsets.only(left: 10, top: 12, right: 10),
              child: Text(
                eventData.title ?? "",
                style: Style.TextTemplate.event_title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, top: 5, right: 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.access_time,
                    color: Style.Colors.lightGrey,
                  ),
                  Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: RichText(
                            text: new TextSpan(children: [
                              TextSpan(
                                text: "" + DateHelper().dayFormat(eventData.dateTime),
                                style: Style.TextTemplate.attend_description,
                              ),
                              TextSpan(
                                text: DateHelper().dateFormat(eventData.dateTime),
                                style: Style.TextTemplate.attend_description,
                              )
                            ])),
                      )
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, top: 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Style.Colors.lightGrey,
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Text(eventData.location,
                          style: Style.TextTemplate.attend_description,
                      overflow: TextOverflow.ellipsis,),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      onTap:() =>  _eventCardTapped(eventSnap),
    );
  }



  void _registerNotifications() {
    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      _showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    _firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(widget.currentUser.id)
          .updateData({'pushToken': token}).catchError((err) {
        Fluttertoast.showToast(msg: err.toString());
      });
    });
  }

  void _configureLocalNotifications() {
    _notifsPlugin.initialize(new InitializationSettings(
        new AndroidInitializationSettings('app_icon'),
        new IOSInitializationSettings()));
  }

  void _showNotification(message) async {
    var platformChannelSpecifics = new NotificationDetails(
        new AndroidNotificationDetails(
            'com.gamehaus.ghfrontend', 'GChat', 'You Got Message',
            playSound: true,
            enableVibration: true,
            importance: Importance.Max,
            priority: Priority.High),
        new IOSNotificationDetails());

    await _notifsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
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





  Widget _buildChatRoomsList() {
    // TODO: update this to work through a service
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('rooms').document(selectedRoomId).collection('chatroom')
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
              itemBuilder: (_, int index) => _buildChatRoomBox(
                  snapshot.data.documents[index],
                  snapshot.data.documents[index].documentID),
              itemCount: snapshot.data.documents.length,
            );
          }
        });
  }

  Widget _buildChatRoomBox(dynamic roomData, doc_id) {
    return Center(
        child: Container(
      color: Style.Colors.darkGrey,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      margin: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        splashColor: Colors.grey,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChatPage(
                title: roomData['name'],
                roomId: selectedRoomId,
                chatId: roomData.documentID,
                auth: widget.auth,
                currentUser:widget.currentUser)
          ));

        },
        child: ListTile(

          title: Text(
            roomData['name'],
            style: Style.TextTemplate.drawer_listTitle,
          ),
        ),
      ),
    ));
  }




  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              selectedRoomName,
              style: Style.TextTemplate.app_bar,
            ),
          ),
          backgroundColor: Style.Colors.darkGrey,
          iconTheme: new IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            child: Container(
              child: _createTabs(),
            ),
            preferredSize: new Size(size.width, 60),
          ),
          leading: Padding(
            padding: EdgeInsets.only(top: 15),
            child: FlatButton(
              //icon: Icon(Icons.menu),
              child: Image.asset('assets/images/menu_round_logo.png'),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
                if (_scaffoldKey.currentState.isDrawerOpen) {
                  setState(() {
                    currentIndexPage = 0;
                  });
                } else {
                  setState(() {
                    currentIndexPage = 0;
                  });
                }
              },
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, right: 5),
              child: new IconButton(
                onPressed: () {
                  if (controller.index==0){
                  _navigateToCreateEventPage();
                }else{
                  _showChatCreationDialog(context);
                }
                },
                icon: Image.asset('assets/images/gh_add_icon.png'),
              ),
            )
          ],
        ),
        drawer: SizedBox(
          width: size.width - 20,
          child: Drawer(
            child: Container(
              child: Column(
                children: <Widget>[
                  _drawerHeaderTab(),
                  Expanded(
                    child: PageView(
                      onPageChanged: pageChanged,
                      children: <Widget>[
                        buildRoomsList(),
                        _buildGameNearbyList()
                      ],
                    ),
                  ),
                  Container(
                      height: 20,
                      width: 50,
                      margin: EdgeInsets.only(bottom: 5, top: 7),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Style.Colors.grey),
                      child: Center(
                        child: new DotsIndicator(
                          dotsCount: 2,
                          position: currentIndexPage,
                          decorator: DotsDecorator(
                            color: Style.Colors.darkGrey,
                            activeColor: Colors.white,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            new TabBarView(controller: controller, children: <Widget>[
              _buildEventList(),
              //ChatPage(
              //    roomId: selectedRoomId,
              //    auth: widget.auth,
              //    currentUser:widget.currentUser),
              _buildChatRoomsList(),
            ]),
            _createColorsRow(),
          ],
        ));
  }

  final PageController pageController = PageController(initialPage: 0);
  String drawerTitle = "ROOMS";
  int currentIndexPage = 0;

  void pageChanged(int index) {
    setState(() {
      if (index == 0) {
        setState(() {
          drawerTitle = "ROOMS";
          currentIndexPage = index;
        });
      } else {
        setState(() {
          drawerTitle = "GAMING NEARBY";
          currentIndexPage = index;
        });
      }
    });
  }

  Widget AddEventIcon(){
    bool _isIos = (Theme.of(context).platform == TargetPlatform.iOS);
    if (_isIos==true){
  //  return Transform.scale(
    //  scale: 4,
      return IconButton(
        onPressed: () {
          setState(() {
            _navigateToCreateEventPage();
          });
        },
        icon: Image.asset('assets/images/gh_add_icon.png')

      );
    //);
    }
  return IconButton(
    onPressed: () {
      setState(() {
        _navigateToCreateEventPage();
      });
    },
    icon: Image.asset('assets/images/gh_add_icon.png')
  );
  }
  Widget _drawerHeaderTab() {

    return Column(
      //padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          height: 100,
          child: DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'GAME HAUS',
                  style: Style.TextTemplate.drawer_heading,
                ),


              InkWell(
                child: Container(
                  width: 45,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage('https://robohash.org/'+(_userNickname ?? "")),
                        fit: BoxFit.fitHeight
                    ),
                    borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 1.5
                    ),
                  ),
                ),
                onTap: _navigateToProfilePage,
              ),
                AddEventIcon(),
              ],
            ),
            decoration: BoxDecoration(
              color: Style.Colors.darkGrey,
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
            child: Row(
              children: <Widget>[
                Image.asset("assets/images/gh_triangle_icon.png"),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(drawerTitle,
                      style: Style.TextTemplate.drawer_subheading),
                )
              ],
            )),
      ],
    );
  }
}
