
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/event.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/services/date_helper.dart';
import 'package:ghfrontend/services/users.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'package:ghfrontend/style/theme_style.dart' as Style;



class AttendancePage extends StatefulWidget {

  AttendancePage({Key key,this.eventData, this.currentUser, this.boolAttend}) : super(key: key);
  final DocumentSnapshot eventData;
  final GUser currentUser;
  bool boolAttend;
  @override
  State<StatefulWidget> createState() {
    return _AttendancePageState();
  }
}

class _AttendancePageState extends State<AttendancePage> {

  BaseAuth auth;
  Users users;
  GUser mUser = GUser("","","","","",[""],{"":""}, {"":""});
  VoidCallback onSignedOut;
  //bool isAttending=widget.boolAttend;
  @override
  void initState() {
  //  isAttending=widget.boolAttend;
    // TODO: implement initState
    //_getUserDetails();
    super.initState();
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
          widget.eventData["game"],
          style: Style.TextTemplate.app_bar,
        ),
      ),
      body: ListView(
        children: <Widget>[
          _createColorsRow(),
          _returnTitle(),
          _returnDetailView(),
          _returnButtons(),
          Text("Attendance", style: Style.TextTemplate.button_signin),
          Container(
            height: 300,
            padding: EdgeInsets.only(left: 17,right: 17),
            child: _createAttendingEvents(),
          )
        ],
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

  Widget _returnTitle(){
    if (widget.boolAttend){
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 30),
          child: Text("Do you want to attend this event?", style: Style.TextTemplate.button_signin,)
        ),
      );
    }else{
      return Center(
        child: Container(
            margin: EdgeInsets.only(top: 30),
            child: Text("Do you want to unattend this event?", style: Style.TextTemplate.button_signin,)
        ),
      );
    }
  }

  Widget _returnDetailView(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("Title:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, bottom: 5),
            child: Text(widget.eventData["title"], style: Style.TextTemplate.description,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("Description:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, bottom: 5),
            child: Text(widget.eventData["description"], style: Style.TextTemplate.description,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15,top: 20),
            child: Text("Location:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(widget.eventData["location"], style: Style.TextTemplate.description,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("Date:", style: Style.TextTemplate.heading,),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(DateHelper().dayDateFormat(widget.eventData["dateTime"].toDate()), style: Style.TextTemplate.description,),
          ),
        ],
      ),
    );
  }

  Widget _returnButtons(){
    return Container(
      margin: EdgeInsets.only(top: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(50)
            ),
            child: FlatButton(
              child: Text("NO", style: Style.TextTemplate.button_signin,),
              onPressed: _noButton,
            ),
          ),
          Container(
            width: 150,
            child: FlatButton(
              child: Text("YES", style: Style.TextTemplate.button_signup,),
              onPressed: _yesButton,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50)
            ),
          )
        ],
      ),
    );
  }

  Widget _createAttendingEvents(){
  //  if (mUser.id.isNotEmpty){
      return new StreamBuilder(
          stream: Firestore.instance.collection("events").document(widget.eventData.documentID).collection("attendance_uid").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            } else {
              if (snapshot.data.documents.length == 0){
                return Center(
                  child: Text("No Attendee", style: Style.TextTemplate.tf_hint,),
                );
              }else{
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, int index) =>
                      _buildEventView(snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            }
          });
  //  }else{
  //    return null;
  //  }
  }

  void _eventCardTapped(eventData) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(onSignedOut: null, users: new Users(), currentUser: widget.currentUser, isMe: false, userId:eventData["id"])));
        }



  Widget _buildEventView(eventData){

    Widget eventImage;
    if (eventData["nickname"] == null){
      eventImage = Center(
        child: Text("No Image", style: Style.TextTemplate.heading,),
      );
    }else{
      eventImage = Image(
        image: NetworkImage('https://robohash.org/'+(eventData['nickname'] ?? "")),
        fit: BoxFit.fitWidth,
      );
    }

    return
    InkWell(
      onTap: () {_eventCardTapped(eventData);},
    child: Container(
      width: 200,
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Style.Colors.darkGrey
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 200,
            height: 150,
            color: Style.Colors.grey,
            child: eventImage
          ),
          Container(

            padding: EdgeInsets.only(left:10, top: 12,right: 10),
            child: Text(eventData["nickname"] ?? "", style: Style.TextTemplate.event_title, overflow: TextOverflow.ellipsis),
          ),
          // Padding(
          //   padding: EdgeInsets.only(left: 8, top: 5),
          //   child: Row(
          //     children: <Widget>[
          //       Icon(Icons.access_time, color: Style.Colors.lightGrey,),
          //       Flexible(
          //         child: Padding(
          //           padding: EdgeInsets.only(left: 5, right: 5),
          //           child: RichText(
          //               text: new TextSpan(
          //                   children: [
          //                     TextSpan(text: DateHelper().dayFormat(eventData['dateTime'].toDate()), style: Style.TextTemplate.attend_description,),
          //                     TextSpan(text: DateHelper().dateFormat(eventData['dateTime'].toDate()), style: Style.TextTemplate.attend_description,)
          //                   ]
          //               )
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(left: 8, top: 5),
          //   child: Row(
          //     children: <Widget>[
          //       Icon(Icons.location_on, color: Style.Colors.lightGrey,),
          //       Flexible(
          //         child: Text(eventData["location"], style: Style.TextTemplate.attend_description),
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
    )
  );
  }

  Future<int> findAverage() async{
    int total=0;
    int totalamount=0;
    var query = await Firestore.instance.collection("events").document(widget.eventData.documentID).collection("attendance_uid").getDocuments();
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

  void _yesButton() async{
    Fluttertoast.showToast(msg: "Loading...");
    Event eventObj = Event.fromSnapshot(widget.eventData);
    Map<String, dynamic> data = eventObj.toJson();
    var db=Firestore.instance;
    if (widget.boolAttend){
          print("ATTEND");


        //   await Firestore.instance.collection("events").document(widget.eventData.documentID)
        //       .collection("attendance_uid").document(widget.currentUser.id)
          //     .setData(widget.currentUser.toJson());
        //   await Firestore.instance.collection("events").document(widget.eventData.documentID).updateData({"attending_uid": FieldValue.arrayUnion([widget.currentUser.id])});
          // await Firestore.instance.collection("users").document(widget.currentUser.id)
          //     .collection("attending_events").document(widget.eventData.documentID)
          //     .setData(data).then((value){
          //   _showDialog(context, "Success", "Successfully attend event");
          // });
          //var db=Firestore.instance;
          var batch=db.batch();
          batch.setData(db.collection("events").document(widget.eventData.documentID)
              .collection("attendance_uid").document(widget.currentUser.id),widget.currentUser.toJson());
          batch.updateData(db.collection("events").document(widget.eventData.documentID), {"attending_uid": FieldValue.arrayUnion([widget.currentUser.id])});
          await batch.commit();
          //int total=await findAverage();
          //print(total);
          findAverage().then((value){
            Firestore.instance.collection("events").document(widget.eventData.documentID).updateData({"average_level": value});
            print (value);
          });
          _showDialog(context, "Success", "Successfully attend event");



    }else{
        print("UNATTEND");
        var batch=db.batch();
        batch.delete(db.collection("events").document(widget.eventData.documentID)
            .collection("attendance_uid").document(widget.currentUser.id));
        batch.updateData(db.collection("events").document(widget.eventData.documentID), {"attending_uid": FieldValue.arrayRemove([widget.currentUser.id])});
        await batch.commit();
        //int total=await findAverage();
      //  print(total);
      findAverage().then((value){
        Firestore.instance.collection("events").document(widget.eventData.documentID).updateData({"average_level": value});
        print (value);
      });
        // await Firestore.instance.collection("events").document(widget.eventData.documentID)
        //     .collection("attendance_uid").document(widget.currentUser.id)
        //     .delete();
      //   await Firestore.instance.collection("events").document(widget.eventData.documentID).updateData({"attending_uid": FieldValue.arrayRemove([widget.currentUser.id])});
        // await Firestore.instance.collection("users").document(widget.currentUser.id)
        //     .collection("attending_events").document(widget.eventData.documentID)
        //     .delete().then((value){
      _showDialog(context, "Success", "Successfully unattend event");
        // });

    }
  //  isAttending=!isAttending;

    setState((){
      widget.boolAttend=!widget.boolAttend;
    });
  }

  void _noButton(){
    Navigator.of(context).pop();
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
                    //Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: Style.TextTemplate.heading,
                  ))
            ],
          );
        });
  }
}
