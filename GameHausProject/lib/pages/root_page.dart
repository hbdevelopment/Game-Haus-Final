import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/pages/sign_in_page.dart';
import 'package:ghfrontend/pages/sign_up_page.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/pages/home_page.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.users});

  final BaseAuth auth;
  final Users users;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AppStatus {
  NOT_DETERMINED,
  STARTUP,
  DO_LOGIN,
  DO_SIGN_UP,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AppStatus appStatus = AppStatus.NOT_DETERMINED;
  GUser _currentUser;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      if (user != null) {
        if (user.uid != null){
          widget.users.ensureUserCreated(user).then((currentUser) {
            setState(() {
              _currentUser = currentUser;
              appStatus = AppStatus.LOGGED_IN;
            });
          });
        }else{
          setState(() {
            appStatus = AppStatus.STARTUP;
          });
        }
      } else {
        setState(() {
          appStatus = AppStatus.STARTUP;
        });
      }
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      widget.users.ensureUserCreated(user).then((currentUser) {
        setState(() {
          _currentUser = currentUser;
          appStatus = AppStatus.LOGGED_IN;
        });
      });
    });
  }

  void _onSignedOut() {
    widget.auth.signOut();
    setState(() {
      appStatus = AppStatus.STARTUP;
      _currentUser = null;
    });
    Navigator.of(context).pop();
  }


  void _onSetPreferences() {
    widget.users.getCurrentUser(_currentUser.id).then((currentUser) {
      setState(() {
        _currentUser = currentUser;
      });
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSignInPage(){
    return Scaffold(
      backgroundColor: Style.Colors.primaryColor,
      body: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 50,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // LOGO ICON + APP TITLE
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 100),
                      padding: EdgeInsets.all(0),
                      child: Image.asset(
                        'assets/images/gamehaus_logo.png',scale: 2,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 56,
                      margin: EdgeInsets.only(left: 32, right: 32),
                      decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(30),
                          color: Colors.white
                      ),
                      child: FlatButton(
                        child: Text("SIGN UP", style: Style.TextTemplate.button_signup,),
                        onPressed: () {
                          _navigateToSignUpScreen();
                        },
                      ),
                    ),
                    Container(
                      height: 56,
                      margin: EdgeInsets.only(top: 20, bottom: 20, left: 32, right: 32),
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(30),
                        border: Border.all(color: Colors.white,width: 2.0),
                      ),
                      child: FlatButton(
                        child: Text("LOG IN", style: Style.TextTemplate.button_signin),
                        onPressed: () {
                          _navigateToLoginScreen();

                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10, left: 32, right: 32),
                      height: 25,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 10, left: 10),
                              color: Style.Colors.grey,
                              height: 1,
                            ),
                          ),
                          Text("OR", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 10, left: 10),
                              color: Style.Colors.grey,
                              height: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: Center(
                          child: FlatButton(
                            onPressed: () {
                              googleSignIn();
                            },
                            child: Image.asset('assets/images/google_round_icon.png'),
                          ),
                        )
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  void _navigateToLoginScreen(){
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignInPage(auth:widget.auth, onSignedIn: _onLoggedIn,)));
  }

  void _navigateToSignUpScreen(){
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignUpPage(auth:widget.auth, users: widget.users, onSignedIn: _onLoggedIn,)));
  }

  Future<FirebaseUser> googleSignIn() async {
    try {
      String userId = await widget.auth.googleSignIn();
      print('Signed in: $userId');
      setState(() {
        _onLoggedIn();
      });
    } catch (e) {
      _showDialog(context, "Sign In Failed", e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (appStatus) {
      case AppStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AppStatus.STARTUP:
        return _buildSignInPage();
        break;

      case AppStatus.LOGGED_IN:
        if (_currentUser != null) {

          return new HomePage(
            currentUser: _currentUser,
            auth: widget.auth,
            users: widget.users,
            onSignedOut: _onSignedOut,
          );
        } else {
          return _buildWaitingScreen();
        }
        break;
      default:
        return _buildWaitingScreen();
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
}
