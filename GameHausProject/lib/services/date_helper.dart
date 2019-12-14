import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateHelper{

  static DateHelper _instance;
  factory DateHelper() => _instance ??= new DateHelper._();

  DateHelper._();

  String dateFormat(timestamp){
    return DateFormat("MMM dd - hh:mm a").format(timestamp);
  }

  String dayFormat(timestamp){
    return DateFormat("EEE ").format(timestamp).toUpperCase();
  }

  String dayDateFormat(timestamp){
    return DateFormat("EEE, MMM dd - hh:mm a").format(timestamp).toUpperCase();
  }
}