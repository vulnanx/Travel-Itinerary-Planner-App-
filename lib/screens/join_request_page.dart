
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar%20copy.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/tabs/plan_info.dart';
import 'package:project23/screens/user_details_page.dart';
import 'package:provider/provider.dart';


class JoinRequestsPage extends StatefulWidget {
  final String title;

  const JoinRequestsPage({super.key, required this.title});

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: ''),
      backgroundColor: Color(0xFFE0EEFF),
      body: Column(
        children: [
          AppbarWidget(title: 'View Join Requests'),
          Expanded(
            child: ListView(
              children: [
                viewJoinRequestReceived(),
                viewJoinRequestSent,
              ],
            ),
          )
        ],
      ) 
    );
  }

  Widget get viewJoinRequestSent => StreamBuilder<Account?>(
    stream: context.watch<UserAuthProvider>().account,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No account logged in.'));
        }
        final Account account = snapshot.data!;
        final List<String>? sentRequests = snapshot.data!.joinRequestSent; // list of trips the current user sent a request to

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // VIEW JOIN REQUESTS SENT
            sentRequests!.isEmpty ? SizedBox(height: 0)
            : Column(
              children: [
                Center(child:  Text('Join Requests Sent', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.kumbhSans().fontFamily))),
                const SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sentRequests.length,
                    itemBuilder: (context, index) {
                      final planID = sentRequests[index];

                      return FutureBuilder<DocumentSnapshot>(
                        future: context.read<TripListProvider>().getPlanData(planID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading friend...'));
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const ListTile(title: Text('Person not found'));
                          }
                          final requestedPlan = Plans.fromJson(snapshot.data!.data() as Map<String, dynamic>,);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text('${requestedPlan.name}'),
                              subtitle: Text('${requestedPlan.genlocation}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [cancelRequestSentBtn(context, account.id!, planID)]
                                ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlanInfo(title: '', plan: requestedPlan, edittable: false,), 
                                  ),
                                );
                              },
                            )
                          ); 
                        },
                      );
                    },
                  )
                )
              ],
            )
          ],
        );
      },
    );


  // kunin mo kung sinong plan may not empty na joiners_requests
  // kung di empty, then kunin mo yung plan na yon
  // kunin mo yung plan.joiners_requests
  // kunin mo yung bawat user sa plan na yon
  // render mo ui (di na clickable yung listtile) na pinapakita yung name as title, plan name as subtitle

  Widget viewJoinRequestReceived() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    Stream<List<Plans>> plansStream =
        context.watch<TripListProvider>().getPlansList(userId); // get the plans of the current user

    return StreamBuilder<List<Plans>>(
      stream: plansStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Plans Found"));
        }

        // get the account of specific user in the list
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: loadJoinRequests(snapshot.data!),
          builder: (context, joinSnapshot) {
            if (joinSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (joinSnapshot.hasError) {
              return Center(child: Text("Error loading accounts: ${joinSnapshot.error}"));
            }
            
            final joinRequests = joinSnapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // VIEW JOIN REQUESTS SENT
                joinRequests.isEmpty ? SizedBox(height: 0)
                : Column(
                  children: [
                    Center(child:  Text("Joiners' Pending Requests", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.kumbhSans().fontFamily))),
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: joinRequests.length,
                        itemBuilder: (context, index) {
                          final acc = joinRequests[index]['account'] as Account;
                          final plan = joinRequests[index]['plan'] as Plans;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text('${acc.firstName ?? ''} ${acc.lastName ?? ''}'),
                              subtitle: Text('For plan: ${plan.name ?? "No Title"}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [cancelRequestBtn(acc.id!, plan.id!), confirmReqBtn(acc.id!, plan.id!)]
                                ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailsPage(uid: acc.id, showPlans: false) 
                                  ),
                                );
                              },
                            )
                          );
                        },
                      )
                    )
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }


  Future<List<Map<String, dynamic>>> loadJoinRequests(List<Plans> plans) async { // to get the join requests separately
    List<Map<String, dynamic>> joinRequests = [];
    for (var plan in plans) {
      if (plan.joinersRequests != null && plan.joinersRequests!.isNotEmpty) {
        for (String uid in plan.joinersRequests!) {
          Account acc = await UserAuthProvider().userAccount(uid);
          joinRequests.add({'account': acc, 'plan': plan});
        }
      }
    }
    return joinRequests;
  }


  Widget cancelRequestBtn(String reqID, String planID) {
    return IconButton(
      icon: const Icon(Icons.clear_rounded),
      tooltip: 'Cancel Request',
      onPressed: () async {

        final user = FirebaseFirestore.instance.collection('users').doc(reqID);
        final reqPlan = FirebaseFirestore.instance.collection('plans').doc(planID);
        
        final userSnapshot = await user.get();
        final reqPlanSnapshot = await reqPlan.get();
        
        if (userSnapshot.exists && reqPlanSnapshot.exists) {
          final joinReqSent = List<String>.from(userSnapshot.data()?['join_request_sent'] ?? []); // array of planID where join request is sent
          final reqJoiners = List<String>.from(reqPlanSnapshot.data()?['joiners_requests'] ?? []); // array of uid of joiners who request to join
         

          // remove the user from the request_joiners of the plan
          reqJoiners.remove(reqID);
          await reqPlan.update({'joiners_requests': reqJoiners}); 

          // remove the plan from the requests_sent of the user
          joinReqSent.remove(planID);
          await user.update({'join_request_sent': joinReqSent});

          Flushbar(
            padding: EdgeInsets.all(25),
            margin: EdgeInsets.only(top: kToolbarHeight), // for it to appear just below the appbar
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text("You removed @${userSnapshot.data()?['username']}'s request to join ${reqPlanSnapshot.data()?['name']}", style: TextStyle(fontSize: 15, fontFamily: GoogleFonts.kumbhSans().fontFamily, color: Color.fromARGB(255, 1, 31, 75))),
          // ignore: use_build_context_synchronously
          ).show(context);
        }
      }
    );
  }
  
  Widget confirmReqBtn(String reqID, String planID) {
    return IconButton(
      icon: const Icon(Icons.check_rounded),
      tooltip: 'Confirm Request',
      onPressed: () async {
        final user = FirebaseFirestore.instance.collection('users').doc(reqID);
        final reqPlan = FirebaseFirestore.instance.collection('plans').doc(planID);
        
        final userSnapshot = await user.get();
        final reqPlanSnapshot = await reqPlan.get();
        
        if (userSnapshot.exists && reqPlanSnapshot.exists) {
          final joinReqSent = List<String>.from(userSnapshot.data()?['join_request_sent'] ?? []); // array of planID where join request is sent
          final joinedPlans = List<String>.from(userSnapshot.data()?['joined_plans'] ?? []); // array of planID where join request is sent
          final reqJoiners = List<String>.from(reqPlanSnapshot.data()?['joiners_requests'] ?? []); // array of uid of joiners who request to join
          final joiners = List<String>.from(reqPlanSnapshot.data()?['joiners'] ?? []); // array of uid of joiners who joined

          // remove the user from the request_joiners of the plan
          reqJoiners.remove(reqID);
          await reqPlan.update({'joiners_requests': reqJoiners}); 

          // remove the plan from the requests_sent of the user
          joinReqSent.remove(planID);
          await user.update({'join_request_sent': joinReqSent});

          // add the user to the joiners list in the plan
          joiners.add(reqID);
          await reqPlan.update({'joiners': joiners});

          // add the plan to the user's joined plans
          joinedPlans.add(planID);
          await user.update({'joined_plans': joinedPlans});

          Flushbar(
            padding: EdgeInsets.all(25),
            margin: EdgeInsets.only(top: kToolbarHeight), // for it to appear just below the appbar
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text("@${userSnapshot.data()?['username']} joined ${reqPlanSnapshot.data()?['name']}", style: TextStyle(fontSize: 15, fontFamily: GoogleFonts.kumbhSans().fontFamily, color: Color.fromARGB(255, 1, 31, 75))),
          // ignore: use_build_context_synchronously
          ).show(context);
        }
      }
    );
  }

  Widget cancelRequestSentBtn(BuildContext context, String currentUserId, String reqPlanUid) {
    return IconButton(
      icon: const Icon(Icons.undo),
      tooltip: 'Cancel Request',
      onPressed: () async {

        final user = FirebaseFirestore.instance.collection('users').doc(currentUserId);
        final reqPlan = FirebaseFirestore.instance.collection('plans').doc(reqPlanUid);
        
        final userSnapshot = await user.get();
        final reqPlanSnapshot = await reqPlan.get();
        
        if (userSnapshot.exists && reqPlanSnapshot.exists) {
          final joinReqSent = List<String>.from(userSnapshot.data()?['join_request_sent'] ?? []); // array of planID where join request is sent
          final reqJoiners = List<String>.from(reqPlanSnapshot.data()?['joiners_requests'] ?? []); // array of uid of joiners who request to join
         
          // remove the planID from the array of plan requests sent
          joinReqSent.remove(reqPlanUid);
          await user.update({'join_request_sent': joinReqSent});

          // remove the current user from the array of UID joiners requests
          reqJoiners.remove(currentUserId);
          await reqPlan.update({'joiners_requests': reqJoiners});         

          Flushbar(
            padding: EdgeInsets.all(25),
            margin: EdgeInsets.only(top: kToolbarHeight), // for it to appear just below the appbar
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text("You canceled your request to join @${reqPlanSnapshot.data()?['name']}", style: TextStyle(fontSize: 15, fontFamily: GoogleFonts.kumbhSans().fontFamily, color: Color.fromARGB(255, 1, 31, 75))),
          // ignore: use_build_context_synchronously
          ).show(context);
        }
      }
    );
  }
}


