import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;

class PlayGamePage extends StatefulWidget {
  PlayGamePage({this.gameurl}): super(key: key);
  final String gameurl;


  @override
  State<StatefulWidget> createState() => new PlayGamePageState();
}

class PlayGamePageState extends State<PlayGamePage> with WidgetsBindingObserver{
  WebViewController _controller;

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Style.Colors.darkGrey,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        //leading: Icon(Icons.keyboard_backspace, color: Colors.white,),
        title: Text(
          "Game",
          style: Style.TextTemplate.app_bar,
        ),
      ),
      body:WebView(
                  initialUrl: widget.gameurl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) => _controller = controller,
                ),

    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _controller?.reload();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller?.reload();
    }
  }


}
