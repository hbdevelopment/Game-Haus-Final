
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/models/guser.dart';
import 'package:ghfrontend/pages/home_page.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;

class SignUpPage extends StatefulWidget {

  SignUpPage({this.auth, this.users, this.onSignedIn});

  final BaseAuth auth;
  final Users users;
  final VoidCallback onSignedIn;


  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {

  final _formKey = new GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Style.Colors.primaryColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        centerTitle: true,
        title: Text("SIGN UP", style: Style.TextTemplate.app_bar,),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _createColorsRow(),
            Padding(
              padding: EdgeInsets.only(left: 17, top: 36, bottom: 13),
              child: Text("PICK YOUR USERNAME", style: Style.TextTemplate.heading, textAlign: TextAlign.start,),
            ),
            new Container(
              height: 50,
              color: Style.Colors.darkGrey,
              padding: EdgeInsets.only(left: 17),
              child:  _createTFF("Your Username", usernameController, false),
            ),
            Padding(
              padding: EdgeInsets.only(left: 17, top: 36, bottom: 13),
              child: Text("TYPE YOUR LOGIN INFO TO ENTER", style: Style.TextTemplate.heading, textAlign: TextAlign.start,),
            ),
            new Container(
              height: 100,
              padding: EdgeInsets.only(left: 17),
              color: Style.Colors.darkGrey,
              child: Column(
                children: <Widget>[
                  _createTFF("Email", emailController, false),
                  Container(
                    height: 1,
                    color: Colors.white,
                  ),
                  _createTFF("Password", passController, true),
                ],
              ),
            ),
            _createSignUpButton(),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 37, right: 37),
              child: _createRichText()
            ),
          ],
        ),
      )
    );
  }

  Widget _createColorsRow(){
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

  Widget _createTFF(hint, controller, obscure){
    return Container(
      child: TextFormField(
        style: new TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        controller: controller,
        obscureText: obscure,
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

  Widget _createSignUpButton(){
    return Container(
      height: 56,
      margin: EdgeInsets.only(top: 50, bottom: 10, left: 32, right: 32),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(30),
        border: Border.all(color: Colors.white,width: 2.0),
        color: Colors.white
      ),
      child: FlatButton(
        child: Text("CREATE ACCOUNT", style: Style.TextTemplate.button_signup),
        onPressed: () {
          setState(() {

            _validateSignUp(context);
          });
        },
      ),
    );
  }

  Widget _createRichText(){
    return RichText(
      textAlign: TextAlign.center,
      text: new TextSpan(
        children: [
          new TextSpan(
            text: 'By signing up to Game Haus,',
            style: Style.TextTemplate.description,
          ),
          new TextSpan(
            text: '\nyou agree to our ',
            style: Style.TextTemplate.description,
          ),
          new TextSpan(
            text: 'Terms of Service',
            style: new TextStyle(fontFamily: 'Segoe UI',color: Colors.white,decoration: TextDecoration.underline),
            recognizer: new TapGestureRecognizer()
              ..onTap = () { launch('https://app.termly.io/document/terms-of-use-for-website/4212e244-c6cc-4b6e-9414-62dae476f48e');
              },
          ),
          new TextSpan(
            text: ' & ',
            style: new TextStyle(color: Colors.white),
          ),
          new TextSpan(
            text: 'Privacy Policy.',
            style: new TextStyle(fontFamily: 'Segoe UI', color: Colors.white,decoration: TextDecoration.underline),
            recognizer: new TapGestureRecognizer()
              ..onTap = () { launch('https://app.termly.io/document/privacy-policy/61f55b7d-7309-4224-9e21-5cb29ab248e9');
              },
          ),
        ]
      ),
    );
  }

  void _validateSignUp(context){
    var name =usernameController.text;
    var pass = passController.text;
    var email = emailController.text;

    if (name.isNotEmpty){
      if (email.isNotEmpty){
        if (_validateEmail(email)){
          if (pass.isNotEmpty){
            _signUp(email, pass);
          }else{
            //either of the passwords are empty
            _showDialog(context, "Oops", "Password can't be empty");
          }
        }else{
          //email is incorrect format
          _showDialog(context, "Oops", "The email address is badly formatted");
        }
      }else{
        //email is empty
        _showDialog(context, "Oops", "Email can't be empty");
      }
    }else{
      //username is empty
      _showDialog(context, "Oops", "Username can't be empty");
    }

  }

  void _signUp(email, password) async {
    Fluttertoast.showToast(msg: "Signing Up...");
    try {
      String userId = await widget.auth.signUp(email, password);
      widget.auth.sendEmailVerification();
      Map<String, dynamic> data = {
        "nickname":usernameController.text ?? "",
        'id': userId,
        'photoUrl': "",
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'displayName': "",
        'memberOfRooms': [],
        'memberOfEvents': []
      };
      await Firestore.instance.collection("users").document(userId).setData(data,merge: true).then((value){
        _showSignUpDialog(context, "Verify your account", "Link to verify account has been sent to your email", email, password);
      });



    } catch (e) {

      _showDialog(context, "Sign In Failed", e.message);
    }
  }

  void _signIn(email, password) async {
    try {
      await widget.auth.signIn(email, password);
      widget.onSignedIn();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }catch (e){
      _showDialog(context, "Sign In Failed", e.message);
    }
  }

  bool _validateEmail(email){
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }

  void _showDialog(context, title, description){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text(title, style: Style.TextTemplate.alert_title,),
            content: new Text(description, style: Style.TextTemplate.alert_description,),
            actions: <Widget>[
              new FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text("OK", style: Style.TextTemplate.heading,)
              )
            ],
          );
        }
    );
  }

  void _showSignUpDialog(context, title, description, email, password){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text(title, style: Style.TextTemplate.alert_title,),
            content: new Text(description, style: Style.TextTemplate.alert_description,),
            actions: <Widget>[
              new FlatButton(
                  onPressed: (){
                    _signIn(email, password);
                  },
                  child: Text("OK", style: Style.TextTemplate.heading,)
              )
            ],
          );
        }
    );
  }
}
