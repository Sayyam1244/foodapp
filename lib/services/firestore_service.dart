import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/main.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/welcome_screen.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService _instance =
      FirestoreService._privateConstructor();
  static FirestoreService get instance => _instance;

  UserModel? currentUser;

  Future<void> setUser(UserModel user, {File? image}) async {
    try {
      //TODO: Enable firebase storage
      String? imageUrl = user.image;
      if (image != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref('users/$fileName.png');
        await storageRef.putFile(image);
        imageUrl = await storageRef.getDownloadURL();
      }
      final usr = user.copyWith(image: imageUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(usr.toMap());
      await getUser(user.uid);
    } catch (e) {
      throw Exception('Error setting user: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        if (currentUser?.isDeleted == true) {
          Navigator.pushAndRemoveUntil(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false);
        }
        return currentUser;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  Future<bool> deleteAccount(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isDeleted': true,
      });
      return true;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
