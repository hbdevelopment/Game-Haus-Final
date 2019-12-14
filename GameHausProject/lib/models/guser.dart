import 'package:cloud_firestore/cloud_firestore.dart';

class GUser {
  String id;
  String nickname;
  String photoUrl;
  String createdAt;
  String displayName;
  List memberOfEvents;
  Map<dynamic, dynamic> listOfJson;
  Map<dynamic, dynamic> listOfAPI;


  GUser(this.id, this.nickname, this.photoUrl, this.createdAt, this.displayName, this.memberOfEvents, this.listOfJson, this.listOfAPI);

  GUser.fromSnapshot(DocumentSnapshot snapshot) :
    id = snapshot["id"],
    nickname = snapshot["nickname"],
    photoUrl = snapshot["photoUrl"],
    createdAt = snapshot["createdAt"],
    displayName = snapshot["displayName"],
    memberOfEvents = snapshot['memberOfEvents'],
    listOfJson = snapshot['Game JSON'],
    listOfAPI=snapshot['Game API'];

  bool incompletePreferences() {
    return nickname == null;
  }

  toJson() {
    return {
      "id": id,
      "nickname": nickname,
      "photoUrl": photoUrl,
      "createdAt": createdAt,
      "displayName": displayName,
      "memberOfEvents": memberOfEvents,
      "listOfJson": listOfJson,
      "listOfAPI": listOfAPI
    };
  }
}
