import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'datetime.dart';

import 'chat_page.dart';

// THIS PAGE IS NOT BEING USED ANYMORE
class GamePage extends StatefulWidget {
  GamePage({Key key, this.title, this.auth, this.currentUser, this.onSignedOut})
  : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final GUser currentUser;

  @override
  State<StatefulWidget> createState() => new _GamePageState();
}

class _GamePageState extends State<GamePage>
with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime date=new DateTime.now();
  DateTime currentdate=new DateTime.now();

  bool _isEmailVerified = false;
  TabController controller;
  TextEditingController textcontroller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 2);
    textcontroller= new TextEditingController();

    _checkEmailVerification();
  }



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
    controller.dispose();
    textcontroller.dispose();
    super.dispose();
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void _navigateToChat(String roomId, String roomName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          title: 'Room: $roomName',
          roomId: roomId,
          currentUser: widget.currentUser,
          auth: widget.auth)));
        }

joinEvent(String eventID) async{

  //widget.currentUser.memberOfEvents.add(eventID);
  List newlist=addToFixedList(widget.currentUser.memberOfEvents);
  newlist[newlist.length-1]=eventID;
  await Firestore.instance
    .collection('users')
    .document(widget.currentUser.id)
    .updateData({
      'memberOfEvents': newlist
    });
  widget.currentUser.memberOfEvents=newlist;

}

List addToFixedList(List list){
  int newlength=list.length+1;
  List newlist=new List(newlength);
  for (var i=0; i<list.length;i++){
    newlist[i]=list[i];
  }
  return newlist;

}

        void _addDialog() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                actions: <Widget>[
                  new Center(
                  //widthFactor: 2,
                  child: new FlatButton(
                    child: new Text("Add Event"),
                    onPressed: () {
                      showEventInput();
                    },
                  )
                ),
                  // new FlatButton(
                  //   child: new Text("Add Chat"),
                  //   onPressed: () {
                  //   },
                  // ),
                ],
              );
            },
          );
        }



        Future<Null> selectDate(BuildContext context) async{
          final DateTime picked=await showDatePicker(context: context, initialDate: currentdate, firstDate: currentdate, lastDate: new DateTime(2100));
          if (picked!=null && picked!=currentdate){

            setState((){
              date=picked;
            });
            print (date.toString());
          }
        }

         showEventInput() async{
          String eventName='';
          String eventDescription='';

          // Build a Form widget using the _formKey created above.

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: new EventFormPage(),
              );
            });
          }


          void _handleSubmitted(String name, String content) {
            print(name);
            print(content);
            var documentRef = Firestore.instance
                .collection('events')
                .document();
            Firestore.instance.runTransaction((transaction) async {
              await transaction.set(documentRef, {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': name,
                'content': content
              });
            });
          }


          Widget _buildRoomsList(String collection, bool isEvent) {
            return new StreamBuilder(
              stream: Firestore.instance.collection(collection).limit(30).snapshots(),
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
                      itemBuilder: (_, int index) =>
                      _buildRoomBox(snapshot.data.documents[index], isEvent),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                });
              }

              Widget _buildRoomBox(dynamic roomData, bool isEvent) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Card(
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          print('Card tapped.');
                        },
                        child:
                        Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.home),
                            title: Text(roomData['name']),
                            subtitle: Text('ID: ' + roomData['id']),
                          ),
                          ButtonTheme.bar(
                            // make buttons use the appropriate styles for cards
                            child: ButtonBar(
                              children: isEvent
                              ? <Widget>[
                                FlatButton(
                                  child: const Text('JOIN'),
                                  onPressed: () {
                                      joinEvent(roomData['id']);
                                    },
                                  ),
                              ]
                              : <Widget>[
                                FlatButton(
                                  child: const Text('JOIN'),
                                  onPressed: () {
                                    _navigateToChat(
                                      roomData['id'], roomData['name']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      )));
                    }

                    Widget _buildList(String collection, bool isEvent) {
                      return Scaffold(
                        body: Container(
                          child: Center(child: _buildRoomsList(collection, isEvent))));
                        }

                        @override
                        Widget build(BuildContext context) {
                          return new Scaffold(
                            //change colors
                            appBar: new AppBar(
                              title: new Text(widget.title),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text('Add',
                                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                                  onPressed: _addDialog)
                                ],
                                bottom: new TabBar(
                                  controller: controller,
                                  tabs: <Tab>[
                                    new Tab(icon: new Icon(Icons.arrow_upward), text: 'Event'),
                                    new Tab(icon: new Icon(Icons.arrow_downward), text: 'Chat'),
                                  ]
                                )
                              ),
                              body: new TabBarView(controller: controller, children: <Widget>[

                                _buildList('events', true),
                                _buildList('channels', false)
                              ]
                              )
                          );
                            }
                          }
