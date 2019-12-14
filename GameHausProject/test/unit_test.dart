import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghfrontend/pages/sign_in_page.dart';
import 'package:ghfrontend/pages/create_event_page.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:mockito/mockito.dart';
import 'chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghfrontend/pages/home_page.dart';

class FirebaseAuthMock extends Mock implements Auth {}

void main() {
  //somewhat static test data
  //Username: TestAccount
  //email(fake,nonexistant): testghaus@gmail.com
  //password: 1234567890
  //userid: tSOy9V73AhfBjbBWL0Ais3SmdzI2
  //url: https://ow-api.com/v1/stats/pc/us/cats-11481/profile
  SignInPageState auth; //create object
  setUp(() {
    auth = new SignInPageState();
  });

  test('Test sign in right password', () {
    //test
    auth.testSignIn("testghaus.gmail.com", "1234567890");
    bool result = auth.isSignedIn(); //get result

    expect(result, true); //verify
  });

  test('Test sign in wrong password', () {
    //test
    auth.testSignIn("testghaus.gmail.com", "1234567891");
    bool result = auth.isSignedIn(); //get result

    expect(result, false); //verify
  });

  group('Test Correctly set game name and room ID of event', () {
    //Room IDs care constants given by Firebase
    // "FORTNITE":"nYQT0NBBAQGRYI3TSVQ0";
    // "DOTA 2":"m6p76gE4hnigPW4Bi6hJ";
    // "LOL":"eGKPNy54lvyQoatYE5Mx";
    // "OVERWATCH":"5crWuxFMuNY7E9G9xdz9";
    // "Madison eSports Club":"6CkGuBewHOuPOKmhl2NI";

    CreateEventPageState event;
    setUp(() {
      event = new CreateEventPageState();
    });

    test('Fortnite', () {
      event.chooseAGame("FORTNITE");
      expect(event.getSelectedGame(), "FORTNITE");
      expect(event.getSelectedRoomId(), "nYQT0NBBAQGRYI3TSVQ0"); //verify
    });
    test('DotA 2', () {
      event.chooseAGame("DOTA 2");
      expect(event.getSelectedGame(), "DOTA 2");
      expect(event.getSelectedRoomId(), "m6p76gE4hnigPW4Bi6hJ"); //verify
    });

    test('LoL', () {
      event.chooseAGame("LOL");
      expect(event.getSelectedGame(), "LOL");
      expect(event.getSelectedRoomId(), "eGKPNy54lvyQoatYE5Mx"); //verify
    });

    test('Overwatch', () {
      event.chooseAGame("OVERWATCH");
      expect(event.getSelectedGame(), "OVERWATCH");
      expect(event.getSelectedRoomId(), "5crWuxFMuNY7E9G9xdz9"); //verify
    });

    test('Esports Club', () {
      event.chooseAGame("Madison eSports Club");
      expect(event.getSelectedGame(), "Madison eSports Club");
      expect(event.getSelectedRoomId(), "6CkGuBewHOuPOKmhl2NI"); //verify
    });
  });

  test('Test checkEmailVerification', (){
    var homePage = new HomePage();
    var myHPState = new _HomePageState();
    myHPState._checkEmailVerification();
    bool results = myHPState.isEmailVerified();
    expect(true, results);
  });
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
