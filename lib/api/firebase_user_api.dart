import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';

class FirebaseUserApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  Future<Account> getUserAccount(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) {
      throw Exception("No user data found");
    }
    return Account.fromJson({...data, 'id': doc.id});
  }

  //to extract list from firestore using given key
  List extractList(Map data, String key) {
    // checks if key exists in the data and returns the list
    // or empty list if not found
    return data[key] != null ? List.from(data[key]) : [];
  }

  // to fetch users that have similar travel interests/styles
  Future<List<Map<String, dynamic>>> fetchSuggestedTravelers() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // get CURRENT user(logged in user)
    if (currentUser == null) {
      return Future.error('No user logged in');
    }

    // Fetch data of CURRENT user from firestore
    final currentUserDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    if (!currentUserDoc.exists) return Future.error('User not found');
    // get CURRENT user data
    final currentUserData = currentUserDoc.data()!;
    // extract CURRENT user travel styles and interests
    final currentUserInterests = extractList(currentUserData, 'interests');
    final currentUserTravelStyles = extractList(
      currentUserData,
      'travelStyles',
    );

    //to exclude sa suggestions:
    // extract list of friends
    final friends = extractList(currentUserData, 'friends');
    // Extract list of users na may friend requests na
    final currentUserSentRequests = extractList(
      currentUserData,
      'friend_requests_sent',
    );

    // fetch all users in collection (to compare kay current logged in user)
    final userSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> matchedUsers = [];

    // loop thru on each user
    for (var doc in userSnapshot.docs) {
      // if id is the same as current logged in user then skip
      if (doc.id == currentUser.uid) continue;
      // if FRIENDS with CURRENT user, skip din
      if (friends.contains(doc.id)) continue;
      //If current user ay nag friend request na to this user then skip na siya sa suggestions
      if (currentUserSentRequests.contains(doc.id)) continue;
      // If user ay nakaprivate account
      if (!(doc.data()['public'] ?? false)) continue;

      final userData = doc.data();
      final userInterests = extractList(userData, 'interests');
      final userStyles = extractList(userData, 'travelStyles');

      // find common interests
      final matchedInterests =
          currentUserInterests.where((i) => userInterests.contains(i)).toList();
      // find common travel styles
      final matchedStyles =
          currentUserTravelStyles.where((s) => userStyles.contains(s)).toList();
      // if logged in user matched anything in common to user(other users), add to listt
      if (matchedInterests.isNotEmpty || matchedStyles.isNotEmpty) {
        matchedUsers.add({
          'id': doc.id,
          'firstName': userData['firstName'] ?? 'Unknown',
          'lastName': userData['lastName'] ?? 'Unknown',
          'username': userData['username'] ?? 'unknown_user',
          'interests': userInterests,
          'travelStyles': userStyles,
          'matchedInterests': matchedInterests,
          'matchedTravelStyles': matchedStyles,
        });
      }
    }

    return matchedUsers;
  }

  // get the plans invited to
  Stream<List<Plans>> getInvitedPlans(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userSnapshot) async {
          final data = userSnapshot.data();
          final inviteIds = List<String>.from(data?['pending_invites'] ?? []);

          if (inviteIds.isEmpty) return [];

          // Fetch each plan by ID
          final planDocs = await Future.wait(inviteIds.map((planId) async {
            final planDoc = await _firestore.collection('plans').doc(planId).get();
            if (planDoc.exists) {
              return Plans.fromJson({...planDoc.data()!, 'id': planDoc.id});
            }
            return null;
          }));

          return planDocs.whereType<Plans>().toList(); // Remove nulls
        });
      }

  Future<void> sendFriendRequest(String toFriendUserID) async {
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(toFriendUserID);
    final currentUserDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID);

    try {
      final userDoc = await userDocRef.get();
      final currentUserDoc = await currentUserDocRef.get();

      if (userDoc.exists) {
        List<dynamic> friendRequests = userDoc.data()?['friend_requests'] ?? [];
        List<dynamic> friendRequestSent =
            currentUserDoc.data()?['friend_requests_sent'] ?? [];

        if (!friendRequests.contains(currentUserID)) {
          friendRequests.add(currentUserID);
          await userDocRef.update({'friend_requests': friendRequests});
        }

        if (!friendRequestSent.contains(toFriendUserID)) {
          friendRequestSent.add(toFriendUserID);
          await currentUserDocRef.update({
            'friend_requests_sent': friendRequestSent,
          });
        }
      }
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }
}
