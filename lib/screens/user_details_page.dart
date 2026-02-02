import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/tabs/plan_info.dart';
import 'package:provider/provider.dart';

class UserDetailsPage extends StatefulWidget {
  final String? uid;
  final bool? showPlans;
  const UserDetailsPage({
    super.key,
    required this.uid,
    required this.showPlans,
  });

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  late Account currUser;
  Account? account;
  String? fullname;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _getCurrUser();
  }

  // users full name from Firestore
  Future<void> _fetchUserDetails() async {
    if (widget.uid != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();
      if (userDoc.exists) {
        setState(() {
          account = Account.fromJson({
            ...(userDoc.data() as Map<String, dynamic>),
            'id': userDoc.id,
          });
          fullname = '${account?.firstName} ${account?.lastName}';
        });
      }
    }
  }

  Future<void> _getCurrUser() async {
    currUser = await UserAuthProvider().currUserAccount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: '', showBackButton: true),
      backgroundColor: Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFE0EEFF),
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 60),
              account == null
                  ? Expanded(
                    child: Container(
                      color: Color(0xFFE0EEFF),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : displayDetails,
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget get displayDetails => Column(
    children: [
      getProfilePic(),
      SizedBox(height: 10),
      getdisplayName(account!),
      SizedBox(height: 30),
      getPlansAndFriends(account!),
      SizedBox(height: 10),
      getInfo(account!, context),
      SizedBox(height: 10),
      widget.showPlans == true ? getPlans(widget.uid) : Text(''),
    ],
  );

  Widget getProfilePic() {
    return CircleAvatar(
      radius: 80,
      // backgroundImage: NetworkImage(account?.profileUrl ?? defaultAvatarUrl),
      backgroundColor: Colors.black,
    );
  }

  Widget getdisplayName(Account account) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (account.public ?? true)
            ? Icon(Icons.lock_open_rounded)
            : Icon(Icons.lock_person),
        SizedBox(width: 10),
        Text(
          '${account.firstName ?? 'First Name'} ${account.lastName ?? 'Last Name'}',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 31, 75),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.kumbhSans().fontFamily,
          ),
        ),
      ],
    );
  }

  // eto yung paglalagyan ng friends and plans count
  Widget getPlansAndFriends(Account account) => Container(
    padding: EdgeInsets.all(10),
    width: 300,
    decoration: BoxDecoration(
      color: Color(0xFF9FC4F3),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 30,
              color: Color.fromARGB(255, 1, 31, 75),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getPlanCountWidget(widget.uid ?? ''),
                Text(
                  "Travel Plans",
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 31, 75),
                    fontSize: 15,
                    fontFamily: GoogleFonts.kumbhSans().fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(width: 30),
        Row(
          children: [
            Icon(
              Icons.people_rounded,
              size: 30,
              color: Color.fromARGB(255, 1, 31, 75),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getFriendsCountWidget(widget.uid ?? ''),
                Text(
                  "Friends",
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 31, 75),
                    fontSize: 15,
                    fontFamily: GoogleFonts.kumbhSans().fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // container na binubuo nung mga info
  Widget getInfo(Account account, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF9FC4F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              color: Color.fromARGB(255, 1, 31, 75),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          ),
          // private and hindi friend ni user
          (account.public == false &&
                  currUser.friendsList!.contains(widget.uid) == false)
              ? Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    'No Available Information to Show',
                    style: TextStyle(
                      color: Color.fromARGB(255, 1, 31, 75),
                      fontSize: 15,
                      fontFamily: GoogleFonts.kumbhSans().fontFamily,
                    ),
                  ),
                ],
              )
              : Column(
                // kahit nakaprivate, basta friend, dapat makikita
                children: [
                  const SizedBox(height: 16),
                  infoRow('Username', account.username ?? 'username'),
                  infoRow('First Name', account.firstName ?? 'firstName'),
                  infoRow('Last Name', account.lastName ?? 'lastName'),
                  infoRow(
                    'Interests',
                    account.interestsList?.join(', ') ?? 'interests',
                  ),
                  infoRow(
                    'Travel Styles',
                    account.travelStylesList?.join(', ') ?? 'travel styles',
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget getPlanCountWidget(String uid) {
    final plansStream = context.watch<TripListProvider>().getPlans(uid);
    return StreamBuilder<QuerySnapshot>(
      stream: plansStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            "error",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          );
        }
        final count = snapshot.data?.docs.length ?? 0;
        return Text(
          count.toString(),
          style: TextStyle(
            color: Color.fromARGB(255, 1, 31, 75),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.kumbhSans().fontFamily,
          ),
        );
      },
    );
  }

  getFriendsCountWidget(String uid) {
    final userStream = context.watch<UserAuthProvider>().getUserStream(uid);
    return StreamBuilder<Account?>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            "error",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          );
        }
        final account = snapshot.data;
        final count = account?.friendsList?.length ?? 0;
        return Text(
          count.toString(),
          style: TextStyle(
            color: Color.fromARGB(255, 1, 31, 75),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.kumbhSans().fontFamily,
          ),
        );
      },
    );
  }

  // returns formatted na  details in the container
  Widget infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          ),
        ),
        SizedBox(width: 30),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          ),
        ),
      ],
    ),
  );

  // contains stream sa container na paglalagyan ng plans
  getPlans(String? uid) {
    final plansStream = context.watch<TripListProvider>().getPlans(uid!);
    return StreamBuilder<QuerySnapshot>(
      stream: plansStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            "error",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          );
        }
        final count = snapshot.data?.docs.length ?? 0;
        return
        // private and hindi friend ni user
        (account?.public == false &&
                currUser.friendsList!.contains(widget.uid) == false)
            ? SizedBox(height: 0) // show nothing
            : Column(
              children: [
                count == 0
                    ? Text(
                      "No plans yet.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.kumbhSans().fontFamily,
                      ),
                    )
                    : Column(children: [getPlanByPerson(uid)]),
              ],
            );
      },
    );
  }

  // returns the listview of each plans
  getPlanByPerson(String uid) {
    final plansStream = context.watch<TripListProvider>().getPlans(uid);

    return StreamBuilder<QuerySnapshot>(
      stream: plansStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error loading plans");
        }
        final plans = snapshot.data?.docs ?? [];

        return Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
          decoration: BoxDecoration(
            color: Color(0xFF9FC4F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                "Plans made by ${account?.firstName}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 31, 75),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: GoogleFonts.kumbhSans().fontFamily,
                ),
              ),
              SizedBox(height: 15),
              ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 12),
                physics:
                    NeverScrollableScrollPhysics(), // Prevent GridView from scrolling inside a ScrollView
                shrinkWrap:
                    true, // Important to contain it within parent scroll view
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final planDoc = plans[index];
                  final Map<String, dynamic> data = {
                    ...planDoc.data() as Map<String, dynamic>,
                    'id': planDoc.id,
                  };
                  final plan = Plans.fromJson(
                    data,
                  ); // converts the element to a plan model

                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE0EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: ListTile(
                      onTap:
                          () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PlanInfo(
                                      plan: plan,
                                      title: '',
                                      edittable: false,
                                    ),
                              ),
                            ),
                          },
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        plan.name ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        plan.genlocation ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://info.myboracayguide.com/wp-content/uploads/2024/04/Sand-Castle-at-Love-Boracay-scaled.webp',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          sendJoinRequest(plan);
                          Flushbar(
                            padding: EdgeInsets.all(25),
                            margin: EdgeInsets.only(
                              top: kToolbarHeight,
                            ), // for it to appear just below the appbar
                            duration: Duration(seconds: 3),
                            backgroundColor: Color(0xFFE0EEFF),
                            flushbarPosition: FlushbarPosition.TOP,
                            messageText: Text(
                              "Request to join ${account?.firstName}'s ${plan.name} has been sent.",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: GoogleFonts.kumbhSans().fontFamily,
                                color: Color.fromARGB(255, 1, 31, 75),
                              ),
                            ),
                          ).show(context);
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Color.fromARGB(255, 1, 31, 75),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void sendJoinRequest(plan) async {
    // current user sends a request to join
    final uid =
        FirebaseAuth.instance.currentUser!.uid; // gets uid of current user
    final planDocSnapshot =
        await FirebaseFirestore.instance
            .collection('plans')
            .doc(plan.id)
            .get(); // gets the plans of the owner
    final planData = planDocSnapshot.data() as Map<String, dynamic>;

    if (planDocSnapshot.exists) {
      final plan = Plans.fromJson({...planData, 'id': planDocSnapshot.id});

      // Only add if account.id is not already in the list
      if (!plan.joinersRequests!.contains(uid)) {
        plan.joinersRequests?.add(uid);
        await FirebaseFirestore.instance
            .collection('plans')
            .doc(plan.id)
            .update({'joiners_requests': plan.joinersRequests});
      }
    }
  }
}
