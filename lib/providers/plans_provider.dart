import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project23/api/firebase_plans_api.dart';
import 'package:project23/models/user_model.dart';
import '../models/plans_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

class TripListProvider with ChangeNotifier {
  late FirebasePlanApi firebaseService;
  late Stream<QuerySnapshot> _plansStream;
  late Stream<QuerySnapshot> _joinedPlansStream; // for jpined plans

  TripListProvider() {
    firebaseService = FirebasePlanApi();
    fetchPlans();
  }

  // getter
  Stream<QuerySnapshot> get plan => _plansStream;
  Stream<QuerySnapshot> get joinedPlans => _joinedPlansStream;

  // TODO: get all plan items from Firestore
  void fetchPlans() {
    String userId = FirebaseAuth.instance.currentUser!.uid; // get current uid
    _plansStream = firebaseService.getPlansByUser(userId); // filtered by id
    _joinedPlansStream = firebaseService.getJoinedPlans(userId);
    notifyListeners();
  }

  //added : need to refresh plans once nag change ng user
  void refreshPlans() {
    fetchPlans();
  }

  // build logic for getting active trips of user
  Stream<QuerySnapshot<Object?>> getPlans(String uid) {
    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Stream<List<Plans>> getPlansList(String accountId) {
    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: accountId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final plan = Plans.fromJson(doc.data());
                plan.id = doc.id;
                return plan;
              }).toList(),
        );
  }

  Stream<QuerySnapshot<Object?>> getActiveTrips(String uid) {
    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: uid)
        .snapshots(); // get active trips only
  }

  Stream<QuerySnapshot<Object?>> getFinishedTrips(String uid) {
    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: uid)
        .snapshots(); // get finished trips only
  }

  // add plan
  Future<void> addPlan(Plans item) async {
    String message = await firebaseService.addPlan(item.toJson());
    print(message);
    notifyListeners();
  }

  Future<void> editPlan(String id, Plans updatedTrip) async {
    String message = await firebaseService.editPlan(id, updatedTrip);
    print(message);
    notifyListeners();
  }

  Future<void> deletePlan(String id) async {
    await firebaseService.deletePlan(id);
    notifyListeners();
  }

  Future<DocumentSnapshot> getPlanData(String planID) {
    return FirebaseFirestore.instance.collection('plans').doc(planID).get();
  }

  // get the stream of joiners on a plan
  Stream<List<Account>> fetchJoinersList(String planId) {
    final joinersStream = firebaseService.getJoinersAccount(planId);
    notifyListeners();
    return joinersStream;
  }

  // remove a joiner from the plan
  Future<void> removeJoiner(String uid, String planId) async {
    firebaseService.getRemoveJoiner(uid, planId);
    notifyListeners();
  }
}
