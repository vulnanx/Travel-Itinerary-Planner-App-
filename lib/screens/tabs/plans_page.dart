import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/providers/users_provider.dart';
import 'package:project23/screens/join_request_page.dart';
import 'package:project23/screens/homePage-Widgets/qrCode/qrScanner.dart';
import 'package:project23/screens/tabs/plan_info.dart';
import 'package:provider/provider.dart';
import '../../api/firebase_notification_api.dart';
import '../../models/plans_model.dart';
import '../../providers/plans_provider.dart';
import '../modal_plans.dart';

// ignore: must_be_immutable
class PlanPage extends StatefulWidget {
  final String title;
  const PlanPage({super.key, required this.title});

  @override
  State<PlanPage> createState() => _TripPageState();
}

class _TripPageState extends State<PlanPage> {
  late UserAuthProvider authProvider;
  int selectedView = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: "My Plans",
        showBackButton: false,
        centerTitle: false,
        trailing: seeRequestsAndQR,
      ),
      backgroundColor: Color(0xFFE0EEFF),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: getTabButton(0, 'Active'),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: getTabButton(1, 'Finished'),
                ),
              ),
            ],
          ),
          Expanded(
            child:
                selectedView == 0
                    ? getActiveTripsView()
                    : getFinishedTripsView(),
          ),
        ],
      ),
    );
  }

  Widget get seeRequestsAndQR => Row(
    children: [
      IconButton(
        color: Colors.white,
        tooltip: 'Scan QR to join a plan',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JoinRequestsPage(title: ''),
            ),
          );
        },
        icon: Icon(Icons.circle_notifications),
      ),
      IconButton(
        color: Colors.white,
        tooltip: 'See trip requests',
        icon: const Icon(Icons.qr_code_scanner), // functioning
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRcam()),
          );
        },
      ),
      SizedBox(width: 10),
    ],
  );

  void viewJoinRequests() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            contentTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
            content: Column(
              children: [
                //showPendingRequests(),
                seeSentJoinRequests(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // dismiss
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.kumbhSans().fontFamily,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget seeSentJoinRequests() {
    return Text('');
  }

  Widget getTabButton(int i, String title) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          backgroundColor:
              selectedView == i ? Color(0xFF8bc6f1) : Color(0xFFecf7ff),
        ),
        onPressed: () {
          setState(() {
            selectedView = i;
          });
        },
        child: Text(
          title,
          style: GoogleFonts.kumbhSans(
            color: Color(0xFF011f4b),
            height: 1,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget getActiveTripsView() {
    final tripProvider = context.read<TripListProvider>();
    final userProvider = context.read<UserListProvider>();
    final authProvider = context.read<UserAuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        // whole page scrollable
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================== CREATED PLANS ===============================
            Text(
              "Created Plans",
              style: GoogleFonts.kumbhSans(
                color: const Color(0xFF254268),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250, // scrollable height
              child: StreamBuilder<QuerySnapshot>(
                stream: TripListProvider().plan,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No created plans.",
                        style: GoogleFonts.kumbhSans(
                          color: const Color.fromARGB(255, 144, 167, 198),
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Plans plan = Plans.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      plan.id = snapshot.data!.docs[index].id;

                      if (DateTime.now().isAtSameMomentAs(plan.date!) ||
                          DateTime.now().isBefore(
                            plan.date!.add(Duration(days: plan.tripDuration!)),
                          )) {
                        return buildDismissiblePlanCard(plan, true);
                      } else {
                        return SizedBox();
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ====================== JOINED PLANS ========================
            Text(
              "Joined Plans",
              style: GoogleFonts.kumbhSans(
                color: const Color(0xFF254268),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: tripProvider.joinedPlans,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No joined plans. ",
                        style: GoogleFonts.kumbhSans(
                          color: const Color.fromARGB(255, 144, 167, 198),
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Plans plan = Plans.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      plan.id = snapshot.data!.docs[index].id;
                      return buildDismissiblePlanCard(plan, false);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ========================= PENDING INVITES =====================
            Text(
              "Pending Invites",
              style: GoogleFonts.kumbhSans(
                color: const Color(0xFF254268),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              child: StreamBuilder<List<Plans>>(
                stream: userProvider.invitedPlans,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No pending invites. ",
                        style: GoogleFonts.kumbhSans(
                          color: const Color.fromARGB(255, 144, 167, 198),
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                    );
                  }

                  final plans = snapshot.data!;
                  return ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      Plans plan = plans[index];
                      return FutureBuilder<Account>(
                        future: authProvider.userAccount(plan.userId ?? ''),
                        builder: (context, accountSnapshot) {
                          if (!accountSnapshot.hasData) return SizedBox();
                          Account? owner = accountSnapshot.data;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 245, 250, 255),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text(
                                plan.name ?? '',
                                style: GoogleFonts.kumbhSans(
                                  color: const Color(0xFF254268),
                                  fontSize: 20,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'created by: ${owner?.firstName} ${owner?.lastName}',
                                style: GoogleFonts.kumbhSans(
                                  color: const Color.fromARGB(
                                    255,
                                    144,
                                    167,
                                    198,
                                  ),
                                  fontSize: 16,
                                  height: 1,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  rejectInvitationBtn(plan, owner!, context),
                                  acceptInvitationBtn(plan, owner, context),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PlanInfo(
                                          title: '',
                                          plan: plan,
                                          edittable: false,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rejectInvitationBtn(Plans plan, Account owner, BuildContext context) {
    final userProvider = context.read<UserListProvider>();

    return IconButton(
      icon: const Icon(
        Icons.clear_rounded,
        color: Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Reject Invite',
      onPressed: () async {
        final user = userProvider.currentUser;
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid);

        final snapshot = await userDoc.get();
        final data = snapshot.data();
        List<dynamic> invites = List.from(data?['pending_invites']);

        // remove the pending invite to the list
        if (invites.contains(plan.id)) {
          invites.remove(plan.id);
          await userDoc.update({'pending_invites': invites});

          Flushbar(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.only(top: kToolbarHeight),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text(
              "You rejected ${owner.firstName}' s invitation to ${plan.name}",
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
                color: const Color.fromARGB(255, 1, 31, 75),
              ),
            ),
            // ignore: use_build_context_synchronously
          ).show(context);
        }
      },
    );
  }

  Widget acceptInvitationBtn(Plans plan, Account owner, BuildContext context) {
    final userProvider = context.read<UserListProvider>();

    return IconButton(
      icon: const Icon(
        Icons.check,
        color: Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Accept Invite',
      onPressed: () async {
        final user = userProvider.currentUser;
        if (user == null) return;

        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final planDoc = FirebaseFirestore.instance
            .collection('plans')
            .doc(plan.id);

        final snapshot = await userDoc.get();
        final data = snapshot.data();

        List<dynamic> invites = List.from(data?['pending_invites'] ?? []);
        List<dynamic> joiners = List.from(
          (await planDoc.get()).data()?['joiners'] ?? [],
        );

        if (invites.contains(plan.id)) {
          invites.remove(plan.id);
          await userDoc.update({'pending_invites': invites});

          if (!joiners.contains(user.uid)) {
            joiners.add(user.uid);
            await planDoc.update({'joiners': joiners});
          }

          Flushbar(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.only(top: kToolbarHeight),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text(
              "You accepted ${owner.firstName}'s invitation to ${plan.name}",
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
                color: const Color.fromARGB(255, 1, 31, 75),
              ),
            ),
            // ignore: use_build_context_synchronously
          ).show(context);

          NotifApi().scheduleNotification(
            id: 2,
            title: "Don't Miss Your Trip named ${plan.name}",
            body:
                "You have a trip to ${plan.genlocation} and you wouldn't want to miss it!",
            date: plan.date!.subtract(Duration(days: 1)),
          );
        }
      },
    );
  }

  Widget buildDismissiblePlanCard(Plans plan, bool editable) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PlanInfo(title: 'Plan', plan: plan, edittable: editable),
          ),
        );
      },
      child: Dismissible(
        key: Key(plan.id.toString()),
        onDismissed:
            editable
                ? (direction) {
                  context.read<TripListProvider>().deletePlan(plan.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${plan.name} dismissed')),
                  );
                }
                : null,
        direction:
            editable ? DismissDirection.endToStart : DismissDirection.none,
        background:
            editable
                ? Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                )
                : null,
        child: Card(
          color: Color.fromARGB(255, 245, 250, 255),
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name ?? '',
                        style: GoogleFonts.kumbhSans(
                          color: const Color(0xFF254268),
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // const Icon(Icons.list, color: Colors.grey, size: 20),
                          // const SizedBox(width: 8),
                          if (DateTime.now().isAfter(plan.date!) ||
                              DateTime.now().isAtSameMomentAs(plan.date!)) ...[
                            Text(
                              "Currently Ongoing",

                              style: GoogleFonts.kumbhSans(
                                color: const Color.fromARGB(255, 144, 167, 198),
                                fontSize: 16,
                                height: 1,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "${plan.date!.day}/${plan.date!.month}/${plan.date!.year}",

                              style: GoogleFonts.kumbhSans(
                                color: const Color.fromARGB(255, 144, 167, 198),
                                fontSize: 16,
                                height: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (editable)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 144, 167, 198),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => TripModal(type: 'Delete', item: plan),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFinishedTripsView() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    Stream<QuerySnapshot> plansStream = context
        .watch<TripListProvider>()
        .getFinishedTrips(userId); // check plans provider to get finished plans
    return Scaffold(
      backgroundColor: Color(0xFFE0EEFF),
      body: StreamBuilder(
        stream: plansStream,
        builder: (context, snapshot) {
          //build context, current laman ng stream
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}"); //check
            return Center(child: Text("Error encountered! ${snapshot.error}"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Plans Found",
                style: GoogleFonts.kumbhSans(
                  color: const Color.fromARGB(255, 144, 167, 198),
                  fontSize: 20,
                  height: 1,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: ((context, index) {
              Plans plan = Plans.fromJson(
                snapshot.data?.docs[index].data()
                    as Map<String, dynamic>, // snapshot.data : gets collection
              );
              plan.id = snapshot.data?.docs[index].id; //

              if (DateTime.now().isAfter(
                plan.date!.add(Duration(days: plan.tripDuration!)),
              )) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PlanInfo(
                              title: 'Plan',
                              plan: plan,
                              edittable: false,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    color: Color.fromARGB(255, 245, 250, 255),

                    shadowColor: Colors.transparent,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Plan Name
                                      Text(
                                        plan.name != null ? '${plan.name}' : "",
                                        style: GoogleFonts.kumbhSans(
                                          color: const Color(0xFF254268),
                                          fontSize: 20,
                                          height: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          //Category
                                          Row(
                                            children: [
                                              Text(
                                                "${plan.date!.day}/${plan.date!.month}/${plan.date!.year}",
                                                style: GoogleFonts.kumbhSans(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    144,
                                                    167,
                                                    198,
                                                  ),
                                                  fontSize: 16,
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Section (Amount + Action Buttons)
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(width: 0);
            }),
          );
        },
      ),
    );
  }
}
