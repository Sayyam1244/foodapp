import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? category,
    String? location,
    File? image,
    required String role,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //TODO: Enable firebase storage
      // String? imageUrl;
      // if (image != null) {
      //   final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      //   final storageRef = FirebaseStorage.instance.ref('users/$fileName.png');
      //   await storageRef.putFile(image);
      //   imageUrl = await storageRef.getDownloadURL();
      // }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        if (category != null) 'category': category,
        if (location != null) 'location': location,
        // if (image != null) 'image': imageUrl,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'role': role, // 'business' , 'customer',
        'isDeleted': false,
      });

      return userCredential.user;
    } catch (e) {
      return e.toString();
    }
  }

  static Future loginWithEmailPassword(
    String email,
    String password,
    String role,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (user['role'] != role) {
        await FirebaseAuth.instance.signOut();
        return 'Invalid credentials';
      }
      return userCredential.user;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future resetPass(email) async {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future changePassword(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      return true;
    } catch (e) {
      return e.toString();
    }
  }
}
