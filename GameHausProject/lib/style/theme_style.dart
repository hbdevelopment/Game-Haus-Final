import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Colors {

  const Colors();

  static const primaryColor = const Color(0xFF131212);
//  static const primaryDarkColor = const Color(0xFF333333);
//  static const primaryLightColor = const Color(0xFF9BB1C6);
  static const accentColor = const Color(0xFFFFFFFF);

  static const transColor = const Color(0x00FFFFFF);
  static const whiteText = const Color(0xFFFFFFFF);
  static const darkText = const Color(0xFF000000);
  static const hintText = const Color(0xFFE0E0E0);

  static const darkGrey = const Color(0xFF252525);
  static const grey = const Color(0xFF444444);
  static const lightGrey = const Color(0xFFBCBBBB);
  static const blue = const Color(0xFF21409A);
  static const red = const Color(0xFF7BE1E2D);
  static const yellow = const Color(0xFFFFDE17);
  static const green = const Color(0xFF078C26);
  static const brightGreen = const Color(0xFF15DE44);

}

class TextTemplate{
  const TextTemplate();

  static const app_bar = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w800, color: Colors.whiteText, fontSize: 16, letterSpacing: 1.5);
  static const app_bar_button = TextStyle(fontFamily: "Rubik", fontWeight: FontWeight.normal, color: Colors.whiteText, fontSize: 16, letterSpacing: 1);
  static const alert_title = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w800, color: Colors.whiteText, fontSize: 20, letterSpacing: 1);
  static const alert_description = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.normal, color: Colors.whiteText, fontSize: 14, letterSpacing: 1);
  static const button_signup = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w300, color: Colors.darkText, fontSize: 20, letterSpacing: 1);
  static const button_signin = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w300, color: Colors.whiteText, fontSize: 20, letterSpacing: 1);

  static const heading = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w800, color: Colors.whiteText, fontSize: 14, letterSpacing: 1);
  static const subheading = TextStyle(fontFamily: "Segoe UI", fontWeight: FontWeight.w800, color: Colors.whiteText, fontSize: 13, letterSpacing: 0.5,decoration: TextDecoration.underline);
  static const description = TextStyle(fontFamily: "Segoe UI", fontWeight: FontWeight.normal, color: Colors.whiteText, fontSize: 14, letterSpacing: 0.5);

  static const tf_hint = TextStyle(fontFamily: "Rubik", fontWeight: FontWeight.w100, color: Colors.hintText, fontSize: 16);
  static const drawer_heading = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w600, color: Colors.whiteText, fontSize: 24, letterSpacing: 4);
  static const drawer_subheading = TextStyle(fontFamily: "Rubik", fontWeight: FontWeight.w100, color: Colors.whiteText, fontSize: 18, letterSpacing: 2);
  static const drawer_listTitle = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w100, color: Colors.whiteText, fontSize: 18, letterSpacing: 1.2);

  static const event_description = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.normal, color: Colors.whiteText, fontSize: 13, letterSpacing: 1);
  static const event_day = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w800, color: Colors.whiteText, fontSize: 15, letterSpacing: 1,);
  static const event_title = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.normal, color: Colors.whiteText, fontSize: 18, letterSpacing: 1);
  static const attend_description = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.normal, color: Colors.lightGrey, fontSize: 13, letterSpacing: 1);

  static const chat_title = TextStyle(fontFamily: "Rubik", fontWeight: FontWeight.w800, color: Colors.whiteText, fontSize: 14, letterSpacing: 0.5);
  static const chat_description = TextStyle(fontFamily: "Rubik", fontWeight: FontWeight.normal, color: Colors.whiteText, fontSize: 14, letterSpacing: 0.5);

  static const profile_name = TextStyle(fontFamily: "Bahnschrift", fontWeight: FontWeight.w400, color: Colors.whiteText, fontSize: 16, letterSpacing: 1);
}