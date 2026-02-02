import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project23/api/firebase_auth_api.dart';
import '../models/user_model.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> userStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userStream = authService.getUserStream();
  }

  // gets the account details of the user stored on firestore
  Stream<Account> get account {
    final User? user = _auth.currentUser; // gets the current user
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          final data = snapshot.data();
          if (data == null) {
            throw Exception("No user data found");
          }
          return Account.fromJson({
            ...data,
            'id': snapshot.id,
          }); // converts the to account model
        });
  }

  Future<Account> userAccount(String uid) async {
    return await authService.getUserAccount(uid);
  }

  Future<Account> get currUserAccount async {
    final User? user = _auth.currentUser;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();
    final data = snapshot.data();
    if (data == null) {
      throw Exception("No user data found");
    }
    return Account.fromJson({...data, 'id': snapshot.id});
  }

  Stream<Account> getUserStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          final data = snapshot.data();
          if (data == null) {
            throw Exception("No user data found");
          }
          return Account.fromJson({
            ...data,
            'id': snapshot.id,
          }); // converts the to account model
        });
  }

  // sign in using username
  Future<String> signIn(String username, String password) async {
    String message = await authService.signIn(username, password);
    notifyListeners();
    return message;
  }

  Future<String> signUp(Account newUser) async {
    String message = await authService.signUp(newUser);
    notifyListeners();
    return message;
  }

  Future<String> google() async {
    String message = await authService.signInWithGoogle();
    notifyListeners();
    return message;
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }

  Future<void> updateAccount(Account editedUser) async {
    await authService.updateAccount(editedUser);
    notifyListeners();
  }

  Future<bool> uniqueEmail(String? email) async {
    notifyListeners();

    return await authService.isEmailUnique(email!);
  }

  Future<bool> uniqueUser(String? user) async {
    notifyListeners();

    return await authService.isUsernameUnique(user!);
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }
}
