import 'package:flutter/material.dart';
import 'package:ghfrontend/services/authentication.dart';
import 'package:ghfrontend/pages/root_page.dart';
import 'package:ghfrontend/services/users.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;
void main() {
  runApp(new GHausApp());
}

class GHausApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'GameHaus',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blueGrey,
          canvasColor: Style.Colors.primaryColor
        ),
        home: new RootPage(auth: new Auth(), users: new Users()));
  }
}
