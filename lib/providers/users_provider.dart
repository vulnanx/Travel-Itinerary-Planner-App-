
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';
import '../api/firebase_user_api.dart';

class UserListProvider with ChangeNotifier {
  late FirebaseUserApi firebaseService;
  List<Map<String, dynamic>> _suggestedTravelers = [];
  bool _isLoading = false;
  late Stream<List<Plans>> _invitedPlansStream;


  UserListProvider() {
    firebaseService = FirebaseUserApi();
    fetchUsers();
    fetchSuggestedTravelers();
  }

  // getters
  List<Map<String, dynamic>> get suggestedTravelers => _suggestedTravelers;
  bool get isLoading => _isLoading;
  Stream<List<Plans>> get invitedPlans => _invitedPlansStream;
  User? get currentUser => firebaseService.currentUser;

  void fetchUsers()  {
    String userId = FirebaseAuth.instance.currentUser!.uid;
     _invitedPlansStream = firebaseService.getInvitedPlans(userId);
    notifyListeners();
  }

  Future<Account> userAccount(String uid) async {
    return await firebaseService.getUserAccount(uid);
  }

  // fetch users with matching interests and travel styles
  Future<void> fetchSuggestedTravelers() async {  
    _isLoading = true;
    notifyListeners();

    try {
      _suggestedTravelers = await firebaseService.fetchSuggestedTravelers();
    } catch (e) {
      _suggestedTravelers = [];
      print("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // remove traveler after adding as friend
  void removeTravelerById(String userId) {
    _suggestedTravelers.removeWhere((user) => user['id'] == userId);
    notifyListeners();
  }

  // send friend request
  Future<void> sendFriendRequest(
    String toUserId,
    Function(String) onFriendAdded,
  ) async {
    try {
      await firebaseService.sendFriendRequest(toUserId);
      onFriendAdded(toUserId);
      //immediately remove sa suggestions
      removeTravelerById(toUserId);
    } catch (e) {
      print("Error sending friend request: $e");
    }
  }
}
