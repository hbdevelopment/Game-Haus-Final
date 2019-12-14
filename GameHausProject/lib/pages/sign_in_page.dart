
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;

class SignInPage extends StatefulWidget {

  SignInPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() {
    return SignInPageState();
  }
}

class SignInPageState extends State<SignInPage> {

  bool signedIn = false;
  void signingin() {
    signedIn = true;
  }
  bool isSignedIn () {
    return signedIn;
  }

  final _formKey = new GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final forgotController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Style.Colors.primaryColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        centerTitle: true,
        title: Text("WELCOME BACK", style: Style.TextTemplate.app_bar,),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _createColorsRow(),
            Padding(
              padding: EdgeInsets.only(left: 17, top: 36, bottom: 13),
              child: Text("TYPE YOUR LOGIN INFO TO ENTER", style: Style.TextTemplate.heading, textAlign: TextAlign.start,),
            ),
            new Container(
              padding: EdgeInsets.only(left: 17, bottom: 10, top: 10),
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
            Padding(
              padding: EdgeInsets.only(right: 17, top: 20),
              child: InkWell(
                child: RichText(
                    textAlign: TextAlign.end,
                    text: new TextSpan(
                        children: [
                          TextSpan(
                              text: "Forgot your password?",
                              style: Style.TextTemplate.subheading
                          ),
                        ]
                    )
                ),
                onTap: _forgotPassword,
              ),
            ),
            _createLoginButton()
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
        keyboardType: TextInputType.emailAddress,
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
//        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
//        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _createLoginButton(){
    return Container(
      height: 56,
      margin: EdgeInsets.only(top: 50, bottom: 20, left: 32, right: 32),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(30),
        border: Border.all(color: Colors.white,width: 2.0),
        color: Colors.white
      ),
      child: FlatButton(
        child: Text("LOG IN", style: Style.TextTemplate.button_signup),
        onPressed: () {
          setState(() {
            _signInValidation();
          });
        },
      ),
    );
  }



  void _signIn(email, password) async {
    Fluttertoast.showToast(msg: "signing in...");
    try {
      String userId = await widget.auth.signIn(email, password);
      print('Signed in: $userId');
      signingin();
      widget.onSignedIn();
      Navigator.of(context).pop();
    } catch (e) {
      _showDialog(context, "Sign In Failed", e.message);
    }
  }


  void _signInValidation() async{

    String email = emailController.text;
    String password = passController.text;

    if (email.isNotEmpty){
      if (password.isNotEmpty){
        _signIn(email, password);
      }else{

        _showDialog(context, "Oops", "Password can't be empty");
      }
    }else{

      _showDialog(context, "Oops", "Email can't be empty");
    }
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

  void _forgotPassword(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Style.Colors.darkGrey,
            title: new Text("Forgot Password?", style: Style.TextTemplate.alert_title,),
            content:TextField(
              style: TextStyle(color: Colors.white),
              controller: forgotController,
              decoration: InputDecoration(hintText: "Enter Email",hintStyle: Style.TextTemplate.tf_hint),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: (){
                    _sendResetPasswordLink();
                  },
                  child: Text("OK", style: Style.TextTemplate.heading,)
              )
            ],
          );
        }
    );
  }

  void _sendResetPasswordLink() async{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    await _firebaseAuth.sendPasswordResetEmail(email: forgotController.text);
    Navigator.of(context).pop();
    _showDialog(context, "Reset Password", "A link to reset your password has been sent to your email.");
  }
}
