
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ghfrontend/services/API_call.dart';
//import 'package:fluttertoast/generated/i18n.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/services/date_helper.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ghfrontend/pages/attendance_page.dart';
//import 'GamerStats2.dart';

class ProfilePage extends StatefulWidget {

  ProfilePage({Key key,this.onSignedOut, this.users, this.currentUser, this.isMe, this.userId}) : super(key: key);
  final VoidCallback onSignedOut;
  final Users users;
  final GUser currentUser;

  final bool isMe;
  final String userId;

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {

  BaseAuth auth;
  Users users;
  GUser mUser = GUser("","","","","",[""], {"":""}, {"":""});
  VoidCallback onSignedOut;

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    Widget logOutButton;
    if (widget.isMe){
      logOutButton = FlatButton(
        child: Text("LOG OUT" ,style: Style.TextTemplate.app_bar_button,),
        onPressed:  _signOut,
      );
    }else{
      logOutButton = Center();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "PROFILE",
          style: Style.TextTemplate.app_bar,
        ),
        actions: <Widget>[
          logOutButton
        ],
      ),
      body: ListView(
        children: <Widget>[
          _createColorsRow(),
          _createProfilePicture(),
          Container(
          height: 300,
          child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[_createOverwatchGameStats()])
        )
          ,
          _createRefresh (),


          Container(
            height: 300,
            padding: EdgeInsets.only(left: 17,right: 17),
            child: _createAttendingEvents(),
          ),
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

  Widget _createProfilePicture(){
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
                  image: NetworkImage('https://robohash.org/'+(mUser.nickname ?? "")),
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

        Text(mUser.nickname, style: Style.TextTemplate.profile_name, textAlign: TextAlign.center,),
        //jsonDecode(mUser.listOfJson['Overwatch'] ?? '{"":""}')['name'] ?? ""
        Padding(
          padding: EdgeInsets.only(left: 17, top: 25, bottom: 10),
          child: Text("ATTENDING THESE EVENTS", style: Style.TextTemplate.heading, textAlign: TextAlign.start,),
        )
      ],
    );
  }


  Widget _createRefresh () {
    if (widget.isMe==false){
      return SizedBox(
        width: 0,
        height: 50,
      );
    }
    return FlatButton(
        child: Text("Refresh", style: Style.TextTemplate.drawer_listTitle),
        onPressed: updatePlayerOverwatchInfo,
    );
  }

  void _showAddAPIDialog(context){
    final textController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text(
              "Add Overwatch Stats",
              style: Style.TextTemplate.alert_title,
            ),
            content: _createTFF("Enter BattleNet ID", textController, TextInputType.text),
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
                  addAPIButtonPressed('pc', 'us', textController.text.replaceAll("#","-"));

                //  Navigator.of(context).pop();

                },
                child: Text(
                  "Add",
                  style: Style.TextTemplate.heading
                )
              )
            ],
          );
        });
  }

void addAPIButtonPressed(String platform, String region, String battleNetID) async{
  bool completed=await addJsonAndAPIInfo(platform, region,battleNetID);
  if (widget.currentUser.listOfJson!=null && widget.currentUser.listOfJson['Overwatch']!=null){
    Navigator.of(context).pop();
  }else{
    _showDialog(context, "Unable to show Stats", "Make sure you've entered the correct battleNetID");
  }
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


  Widget _createOverwatchGameStats(){

    if(mUser.listOfJson==null || mUser.listOfJson['Overwatch']==null){
      if (widget.isMe==true){
      return FlatButton(
          child: Text("Add Overwatch Info", style: Style.TextTemplate.drawer_listTitle),
          onPressed: () {_showAddAPIDialog(context);},
      );
    }else{
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    }else{



      // store all info from Json into a Map
      Map<String, dynamic> allInfo = jsonDecode(mUser.listOfJson['Overwatch']);

      String competitivewinrate="0";
      String competitiveMedalGold="";
      String competitiveMedalSilver="";
      String competitiveMedalBronze="";
      String competitiveCards="";
      if (allInfo['competitiveStats']!=null){

        if (allInfo['competitiveStats']['games']!=null){
        competitivewinrate=(allInfo['competitiveStats']['games']['won']*100/allInfo['competitiveStats']['games']['played']).roundToDouble().toString();
        }
        if (allInfo['competitiveStats']['awards']!=null && allInfo['competitiveStats']['awards']['medalsGold']!=null){
          competitiveMedalGold=allInfo['competitiveStats']['awards']['medalsGold'].toString();
        }
        if (allInfo['competitiveStats']['awards']!=null && allInfo['competitiveStats']['awards']['medalsSilver']!=null){
          competitiveMedalSilver=allInfo['competitiveStats']['awards']['medalsSilver'].toString();
        }
        if (allInfo['competitiveStats']['awards']!=null && allInfo['competitiveStats']['awards']['medalsBronze']!=null){
          competitiveMedalBronze=allInfo['competitiveStats']['awards']['medalsBronze'].toString();
        }
        if (allInfo['competitiveStats']['awards']!=null && allInfo['competitiveStats']['awards']['cards']!=null){
          competitiveCards=allInfo['competitiveStats']['awards']['cards'].toString();
        }

      }

    String quickPlaywinrate="0";
    String quickPlayMedalGold="";
    String quickPlayMedalSilver="";
    String quickPlayMedalBronze="";
    String quickPlayCards="";

    if (allInfo['quickPlayStats']!=null){
      if (allInfo['quickPlayStats']['games']!=null && allInfo['quickPlayStats']['games']['won']!=null){
        quickPlaywinrate=allInfo['quickPlayStats']['games']['won'].toString();
      }
      if (allInfo['quickPlayStats']['awards']!=null){
        if (allInfo['quickPlayStats']['awards']['medalsGold']!=null){
          quickPlayMedalGold=allInfo['quickPlayStats']['awards']['medalsGold'].toString();
        }
        if (allInfo['quickPlayStats']['awards']['medalsSilver']!=null){
          quickPlayMedalSilver=allInfo['quickPlayStats']['awards']['medalsSilver'].toString();
        }
        if (allInfo['quickPlayStats']['awards']['medalsBronze']!=null){
          quickPlayMedalBronze=allInfo['quickPlayStats']['awards']['medalsBronze'].toString();
        }
        if (allInfo['quickPlayStats']['awards']['cards']!=null){
          quickPlayCards=allInfo['quickPlayStats']['awards']['cards'].toString();
        }
      }

    }



      //(allInfo['competitiveStats']['games']['won']*100/allInfo['competitiveStats']['games']['played']).roundToDouble().toString()
      return Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.65,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.amber,
              ),
              width: MediaQuery.of(context).size.width,
              height: 300,
            ),
          ),

          // all info in the OverwatchStats block
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),

              // Overwatch logo
              Image.asset('assets/images/overwatch_icon.png',
                  width: 30,
                  height: 30
              ),

              // all stats
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget> [

                  // User info
                  Padding(
                    padding: EdgeInsets.only(left: 2, right: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: AlignmentDirectional.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black38,
                          ),
                          width: 120,
                          height: 25,
                          child: Text('User Info',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Bahnschrift",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Image.network(allInfo['icon'],
                              width: 35,
                              height: 35,
                            ),
                            Image.network(allInfo['levelIcon'],
                              width: 90,
                              height: 90,
                            ),
                            Image.network(allInfo['prestigeIcon'],
                              width: 90,
                              height: 90,
                            ),
                          ],
                        ),
                        Text(allInfo['name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.white,
                          ),
                        ),

                        Text('LV: ' + allInfo['prestige'].toString() + allInfo['level'].toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Total Wins: ' + allInfo['gamesWon'].toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.white,
                          ),
                        ),

                      ],
                    ),
                  ),

                  // Separator line
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white70,
                    ),
                    width: 5,
                    height: 240,
                  ),


                  // Competitive stats
                  Padding(
                    padding: EdgeInsets.only(right: 2, left: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: AlignmentDirectional.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black38,
                          ),
                          width: 120,
                          height: 25,
                          child: Text('Competitive',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Bahnschrift",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Winrate: ' + competitivewinrate,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Gold Medals: ' + competitiveMedalGold,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Bahnschrift",
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Silver Medals: ' + competitiveMedalSilver,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Bahnschrift",
                            color: Colors.black26,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Bronze Medals: ' + competitiveMedalBronze,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Bahnschrift",
                            color: Colors.brown,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Cards: ' + competitiveCards,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Separator line
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white70,
                    ),
                    width: 5,
                    height: 240,
                  ),


                  // Quick Play stats
                  Padding(
                    padding: EdgeInsets.only(right: 2, left: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: <Widget>[
                        Container(
                          alignment: AlignmentDirectional.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black38,
                          ),
                          width: 120,
                          height: 25,
                          child: Text('Quick Play',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Bahnschrift",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Game Wins: ' + quickPlaywinrate,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Gold Medals: ' + quickPlayMedalGold,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Bahnschrift",
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Silver Medals: ' + quickPlayMedalSilver,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Bahnschrift",
                            color: Colors.black26,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Bronze Medals: ' + quickPlayMedalBronze,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Bahnschrift",
                            color: Colors.brown,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Cards: ' + quickPlayCards,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Bahnschrift",
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }

  void _getUserDetails() async{

    if (widget.isMe){
      try {

        var user = await FirebaseAuth.instance.currentUser();
        Firestore.instance.collection("users").document(user.uid).get().then((snapshot){
          GUser userData = GUser.fromSnapshot(snapshot);

          setState(() {
            mUser = userData;
          });
        });
      }catch (e) {
        print(e);
      }
    }else{
      try {
        Firestore.instance.collection("users").document(widget.userId).get().then((snapshot){

          GUser userData = GUser.fromSnapshot(snapshot);
          setState(() {
            mUser = userData;
          });
        });
      }catch (e) {
        print(e);
      }
    }



  //  }


  }

  Widget _createAttendingEvents(){
    if (mUser.id.isNotEmpty){
      return new StreamBuilder(
          //stream: Firestore.instance.collection("users").document(mUser.id).collection("attending_events").snapshots(),
          stream: Firestore.instance.collection("events").where('attending_uid', arrayContains: mUser.id).snapshots(),
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
                  child: Text("No Events", style: Style.TextTemplate.tf_hint,),
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
    }else{
      return null;
    }
  }

  void _eventCardTapped(eventData) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AttendancePage(
                        eventData: eventData,
                        currentUser: widget.currentUser,
                        boolAttend: false,
                      )));
        }



  Widget _buildEventView(eventData){

    Widget eventImage;
    if (eventData["image_url"] == null){
      eventImage = Center(
        child: Text("No Image", style: Style.TextTemplate.heading,),
      );
    }else{
      eventImage = Image(
        image: NetworkImage(eventData["image_url"]),
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
            child: Text(eventData["title"] ?? "", style: Style.TextTemplate.event_title, overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.access_time, color: Style.Colors.lightGrey,),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: RichText(
                        text: new TextSpan(
                            children: [
                              TextSpan(text: DateHelper().dayFormat(eventData['dateTime'].toDate()), style: Style.TextTemplate.attend_description,),
                              TextSpan(text: DateHelper().dateFormat(eventData['dateTime'].toDate()), style: Style.TextTemplate.attend_description,)
                            ]
                        )
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.location_on, color: Style.Colors.lightGrey,),
                Flexible(
                  child: Text(eventData["location"], style: Style.TextTemplate.attend_description),
                )
              ],
            ),
          )
        ],
      ),
    )
  );
  }

  addAPIInfo(String platform, String region, String battleNetID) async{
    var returnedval=await APICall(currentUser: widget.currentUser).AddPlayerAPIInfo(widget.currentUser.id, platform, region, battleNetID);
    _getUserDetails();

    print("Data: "+returnedval.toString());

  }

  addJsonInfo(String platform, String region, String battleNetID) async{

    var result=await APICall(currentUser: widget.currentUser).callOverwatchAPI(widget.currentUser.id, platform, region, battleNetID);
    _getUserDetails();
    bool isnull=(result==null);
    
  }

Future<bool> addJsonAndAPIInfo(String platform, String region, String battleNetID) async{
  var result=await APICall(currentUser: widget.currentUser).callOverwatchAPI(widget.currentUser.id, platform, region, battleNetID);
  if (result!=null){
    _getUserDetails();
    APICall(currentUser: widget.currentUser).AddPlayerAPIInfo(widget.currentUser.id, platform, region, battleNetID).then((completed){return completed;});
  }
  return false;

}

  updatePlayerOverwatchInfo() async{
    if (widget.currentUser.listOfAPI["Overwatch"]==null){
      return;
    }
    Map<String, dynamic> data=jsonDecode(widget.currentUser.listOfAPI['Overwatch']);
    addJsonInfo(data['platform'], data['region'], data['battleNetID']);
    _getUserDetails();
  }

  _signOut() async {
    GoogleSignIn googleSignIn = new GoogleSignIn();
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}
