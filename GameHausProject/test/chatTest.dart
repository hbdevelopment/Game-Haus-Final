import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'videoApp.dart';
import 'chatroom.dart';
import 'gamestore.dart';
import 'package:ghfrontend/pages/home_page.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/services/authentication.dart';


void main(){

 
  test('Test chatroom handling new message submission', (){
    var chatRoom = new ChatPage();
    var documentRef = Firestore.instance
    .collection("rooms")
    .document('5crWuxFMuNY7E9G9xdz9')
    .collection('chatroom')
    .document("KhbeWfxpAyNnepwRwKcC")
    .collection('messages')
        .document('1573711348703');
        Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentRef, {
        'fromId': 'TX05iDkFDcVdYdir7NFlbjqMLvd2',
        'fromNickname': 'StevenLiu',
        'timestamp': '1573711348765',
        'content': 'hello',
        'type': 0
      });
    });
    var dbMessage = Firestore.instance.collection("rooms")
    .document('5crWuxFMuNY7E9G9xdz9')
    .collection('chatroom')
    .document("KhbeWfxpAyNnepwRwKcC")
    .collection('messages')
        .document('1573711348703').toString();
    String realMessage = 'hello';
    var results = (realMessage.compareTo(dbMessage));
    expect(1, results);
  });

  
}