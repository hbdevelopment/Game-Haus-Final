import 'package:flutter_test/flutter_test.dart';
import 'package:ghfrontend/pages/profile_page.dart';


void main(){


  test('Test check authenticition state', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testAuthState();
    expect(true, results);
  });

  test('Test log out from profile page', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testLogout();
    expect(true, results);
  });

  test('Test layout creation', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testLayoutCreation();
    expect(true, results);
  });

  test('Test profile info modification', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testProfileModification();
    expect(true, results);
  });

  test('Test modify gamer stats for Overwatch', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testGStatsOverwatch();
    expect(true, results);
  });

  test('Test modify gamer stats for LOL', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testGStatsLOL();
    expect(true, results);
  });

  test('Test modify gamer stats for DOTA2', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testGStatsDOTA2();
    expect(true, results);
  });

  test('Test modify gamer stats for Fortnite', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testGStatsFortnite();
    expect(true, results);
  });

  test('Test API request for Overwatch', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testApiOverwatch();
    expect(true, results);
  });

  test('Test API request for LOL', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testApiLOL();
    expect(true, results);
  });

  test('Test API request for DOTA2', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testApiDOTA2();
    expect(true, results);
  });

  test('Test API request for Fortnite', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testApiFortnite();
    expect(true, results);
  });

  test('Test parse Json file', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testParseJson();
    expect(true, results);
  });

  test('Test refresh page function', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testRefresh();
    expect(true, results);
  });

  test('Test pop-up dialogs', (){
    var profilePage = new ProfilePage();
    var myPPState = new _ProfilePageState;
    myPPPState._checkAuthState();
    bool results = myPPPState.testPopUpDialogs();
    expect(true, results);
  });
}

