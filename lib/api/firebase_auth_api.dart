import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project23/models/user_model.dart';
import 'package:uuid/uuid.dart';

// manage authentication and firestore user
class FirebaseAuthAPI {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges();
  }

  Future<Account> getUserAccount(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) {
      throw Exception("No user data found");
    }
    return Account.fromJson({...data, 'id': doc.id});
  }

  //sign in with username and password
  Future<String> signIn(String username, String password) async {
    // sign in using username
    try {
      //find docu where username(firestore) matches username (user entered)
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection('users') // in users collection
              .where(
                'username',
                isEqualTo: username,
              ) // check if the user input username is nasa users collection
              .get();

      if (userSnapshot.docs.isEmpty) {
        return "Username not found!";
      }
      // if matched un found, get its email
      String email = userSnapshot.docs.first['email'];

      await auth.signInWithEmailAndPassword(email: email, password: password);
      return "Successfully signed in!";
    } on FirebaseAuthException catch (e) {
      return "Failed at error ${e.code}";
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  //sign up details
  Future<String> signUp(Account newUser) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: newUser.email!,
            password: newUser.password!,
          );
      newUser.password = null;
      //create a user in the collection
      await FirebaseFirestore.instance
          .collection('users') // using users collection
          .doc(userCredential.user!.uid)
          .set({
            'firstName': newUser.firstName,
            'lastName': newUser.lastName,
            'email': newUser.email,
            'username': newUser.username,
            'interests': newUser.interestsList,
            'travelStyles': newUser.travelStylesList,
            'isGoogle': false,
          });
      //  success message
      return "Sign Up Successful!";
    } on FirebaseAuthException catch (e) {
      return "Failed at error ${e.code}";
    }
  }

  Future<void> updateAccount(Account editedUser) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(editedUser.id);
      await docRef.update({
        'firstName': editedUser.firstName,
        'lastName': editedUser.lastName,
        'contactno': editedUser.contactno,
        'public': editedUser.public,
        'interests': editedUser.interestsList,
        'travelStyles': editedUser.travelStylesList,
        'profileURL': editedUser.profileURL,
      });
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      final userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userData;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // added: function to check is username is unique
  Future<bool> isUsernameUnique(String username) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username.toLowerCase())
            .get();
    return snapshot.docs.isEmpty;
  }

  // checks if email is already present in the database
  Future<bool> isEmailUnique(String email) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email.toLowerCase())
            .get();
    return snapshot.docs.isEmpty;
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) return;

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);

    dynamic userInstance =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

    if (!userInstance.exists) {
      List<String?> names = (gUser.displayName)!.split(" ");
      String session = Uuid().v4();
      String chosen = session.substring(1, 5);
      String uName = "${names[0]}${names[1]}$chosen";

      await FirebaseFirestore.instance
          .collection('users') // using users collection
          .doc(userCredential.user!.uid)
          .set({
            'firstName': names[0],
            'lastName': names[1],
            'email': userCredential.user!.email,
            'username': uName,
            'interests': [],
            'travelStyles': [],
            'isGoogle': true,
          });
    }

    return userCredential;
  }
}
