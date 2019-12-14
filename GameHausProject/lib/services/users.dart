import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ghfrontend/models/guser.dart';

abstract class BaseUsers {
  Future<GUser> getCurrentUser(String uid);

  Future<GUser> ensureUserCreated(FirebaseUser user);

  Future<void> updateNickname(String uid, String newNickname);
}

class Users implements BaseUsers {
  Future<GUser> getCurrentUser(String uid) async {
    final QuerySnapshot result = await Firestore.instance
      .collection('users')
      .where('id', isEqualTo: uid)
      .getDocuments();

    return GUser.fromSnapshot(result.documents[0]);
  }

  Future<GUser> ensureUserCreated(FirebaseUser user) async {
    final QuerySnapshot result = await Firestore.instance
      .collection('users')
      .where('id', isEqualTo: user.uid)
      .getDocuments();

    if (result.documents.length == 0) {
      await Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData({
          'id': user.uid,
          'nickname': user.displayName ?? "",
          'photoUrl': user.photoUrl ?? "",
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'displayName': user.displayName ?? "",
          'memberOfRooms': [],
          'memberOfEvents': [],
        },merge: true);
    }

    return getCurrentUser(user.uid);
  }

  Future<void> updateNickname(String uid, String newNickname) async {
    await Firestore.instance
      .collection('users')
      .document(uid)
      .updateData({
        'nickname': newNickname
      });
  }
}
