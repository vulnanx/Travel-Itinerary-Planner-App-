import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project23/models/user_model.dart';
import '../models/plans_model.dart';

class FirebasePlanApi {
  //starttt (change)
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Fetch plans for a specific user using UID
  Stream<QuerySnapshot> getPlansByUser(String userId) {
    return db
        .collection('plans') //access collection plans
        .where('userId', isEqualTo: userId) // to filter use given id
        .snapshots(); //realtime updates as a stream
  } // until here (change)

  // for users who joined plans
  Stream<QuerySnapshot> getJoinedPlans(String userId) {
    return db
        .collection('plans')
        .where('joiners', arrayContains: userId)
        .snapshots();
  }

 

  // add plan
  Future<String> addPlan(Map<String, dynamic> plan) async {
    try {
      // get current user uid
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // add plan sa firestore collection : plan with user id
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('plans')
          .add({
            'name': plan['name'],
            'date': plan['date'],
            'description': plan['description'],
            'category': plan['category'],
            'userId': userId, // Store  UID
            'genlocation': plan['genlocation'],
            'tripDuration': plan['tripDuration'],
            'itinerary': plan['itinerary'],
          });
      return docRef.id; // for qr generation
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  Future<String> deletePlan(String id) async {
    try {
      await db.collection('plans').doc(id).delete();
      return "Successfully deleted plans";
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  Future<String> editPlan(String id, Plans updatedTrip) async {
    try {
      await db.collection('plans').doc(id).update({
        // added all needed values
        'name': updatedTrip.name,
        'description': updatedTrip.description,
        'category': updatedTrip.category,
        'date': updatedTrip.date,
        'genlocation': updatedTrip.genlocation,
        'itinerary': updatedTrip.itinerary,
      });
      return "Successfully updated plans";
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  // owner has option to remove
  void getRemoveJoiner(String planId, String joinerId) async {

    final userDoc = FirebaseFirestore.instance.collection('users').doc(joinerId);
    final planDoc = FirebaseFirestore.instance.collection('plans').doc(planId);

    final userSnapshot = await userDoc.get();
    final planSnapshot = await planDoc.get();

    final userData = userSnapshot.data();
    final planData = planSnapshot.data();

    List<dynamic> joiners = List.from(planData?['joiners']);
    List<dynamic> joinedPlans = List.from(userData?['joined_plans']);

    // remove the user to the joiners of the plan
    if (joiners.contains(joinerId)) {
      joiners.remove(joinerId);
      await planDoc.update({'joiners': joiners});
    }

    if (joinedPlans.contains(planId)) {
      joinedPlans.remove(planId);
      await userDoc.update({'joined_plans': joinedPlans});
    }
  }

  Stream<List<Account>> getJoinersAccount(String planId) {
    return db
      .collection('plans')
      .doc(planId)
      .snapshots()
      .asyncMap((userSnapshot) async {
        final data = userSnapshot.data();
        final joinerIds = List<String>.from(data?['joiners'] ?? []);

        if (joinerIds.isEmpty) return [];

        // get each account by id
        final joiners = await Future.wait(joinerIds.map((userId) async {
          final userDoc = await db.collection('users').doc(userId).get();
          if (userDoc.exists) {
            return Account.fromJson({...userDoc.data()!, 'id': userDoc.id});
          }
          return null;
        }));

        return joiners.whereType<Account>().toList(); 
      });
    }
}
