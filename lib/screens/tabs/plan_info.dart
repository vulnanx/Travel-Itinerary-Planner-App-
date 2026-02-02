import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/create_trip/a_create_trip_page.dart';
import 'package:project23/screens/create_trip/b_create_itinerary_page.dart';
import 'package:project23/screens/share_plans_to_friends.dart';
import 'package:project23/screens/user_details_page.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

// ignore: must_be_immutable
class PlanInfo extends StatefulWidget {
  final String title;
  final Plans plan;
  final bool edittable;

  const PlanInfo({
    super.key,
    required this.title,
    required this.plan,
    required this.edittable,
  });
  @override
  State<PlanInfo> createState() => _PlanInfoState();
}

class _PlanInfoState extends State<PlanInfo> {
  int selected = 1;

  late Plans instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      instance = widget.plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: ' ', showBackButton: true,  trailing: shareButton()),
      backgroundColor: Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: titled("Details"),
                  ),
                  (widget.edittable ? editButton(false) : Text('')),
                ],
              ),

              generalInformation,

              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: titled("Activities"),
                  ),
                  (widget.edittable ? editButton(true) : Text('')),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 12, left: 12),
                child: dates(),
              ),
              buildItinerarySection(),
              seeJoinersSection()
            ],
          ),
        ),
      ),
    );
  }

  // dito ung carousell view nung itenerary section
  Widget buildItinerarySection() {
    bool isEdgeIndex(int index) {
      return index ==
          instance.itinerary!
                  .where((mapTested) => mapTested['day'] == selected)
                  .length -
              1;
    }

    bool isStartIndex(int index) {
      return index == 0;
    }

    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 245, 250, 255),
      ),
      child:
          instance.itinerary!.any((mapTested) => mapTested['day'] == selected)
              ? Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // creating the timeline using the timeline package
                      child: SingleChildScrollView(
                        child: FixedTimeline.tileBuilder(
                          theme: TimelineTheme.of(context).copyWith(
                            nodePosition: 0,
                            connectorTheme: TimelineTheme.of(
                              context,
                            ).connectorTheme.copyWith(thickness: 1.0),
                            indicatorTheme: TimelineTheme.of(context)
                                .indicatorTheme
                                .copyWith(size: 10.0, position: 0.5),
                          ),
                          builder: TimelineTileBuilder(
                            indicatorBuilder:
                                (_, index) =>
                                    Indicator.dot(color: Color(0xFF254268)),

                            startConnectorBuilder:
                                (_, index) =>
                                    !isStartIndex(index)
                                        ? Connector.solidLine(
                                          color: Color.fromARGB(
                                            255,
                                            144,
                                            167,
                                            198,
                                          ),
                                        )
                                        : null,
                            endConnectorBuilder:
                                (_, index) =>
                                    !isEdgeIndex(index)
                                        ? Connector.solidLine(
                                          color: Color.fromARGB(
                                            255,
                                            144,
                                            167,
                                            198,
                                          ),
                                        )
                                        : null,
                            contentsBuilder: (context, index) {
                              while (instance.itinerary![index]['day'] !=
                                  selected) {
                                index++;
                              }

                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    label(
                                      '${instance.itinerary![index]['activity']}',
                                      false,
                                    ),
                                    lightLabel(
                                      '${instance.itinerary![index]['time'].hour.toString().padLeft(2, '0')}:${instance.itinerary![index]['time'].minute.toString().padLeft(2, '0')}',
                                      false,
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount:
                                instance.itinerary!
                                    .where(
                                      (mapTested) =>
                                          mapTested['day'] == selected,
                                    )
                                    .length,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Center(
                child: Image.asset('assets/images/noschedule.png', scale: 0.5),
              ),
    );
  }

  Widget shareButton() {
    if (instance.userId == FirebaseAuth.instance.currentUser?.uid) {
      return IconButton(
        color: Colors.white,
        tooltip: 'Share Plan',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SharePlanToFriendsPage(title: '', plan: instance)),
          );
        },
        icon: Icon(Icons.ios_share)
      );
    } else {
      return SizedBox(width: 0,);
    }
  }

  //  CarouselView(
  //               itemSnapping: true,
  //               itemExtent:
  //                   MediaQuery.sizeOf(context).width -
  //                   100, // for responsiveness
  //               shrinkExtent: 10,
  //               children: [
  //                 // magloloop sya ng mga iteneraries para sa araw lang na iyon
  //                 for (int i = 0; i < instance.itinerary!.length; i++)
  //                   if (instance.itinerary![i]['day'] == selected)
  //                     DecoratedBox(
  //                       decoration: BoxDecoration(
  //                         color: Color.fromARGB(255, 245, 250, 255),
  //                         borderRadius: BorderRadius.circular(20),
  //                       ),
  //                       child: Padding(
  //                         padding: EdgeInsets.all(20),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             label(
  //                               '${instance.itinerary![i]['activity']}',
  //                               true,
  //                             ),
  //                             lightLabel(
  //                               '${instance.itinerary![i]['location']}',
  //                               true,
  //                             ),
  //                             Align(
  //                               alignment: Alignment.bottomRight,
  //                               child: large(
  //                                 '${instance.itinerary![i]['time'].toDate().hour}:',
  //                               ),
  //                             ),

  //                             Align(
  //                               alignment: Alignment.bottomRight,
  //                               child: large(
  //                                 '${instance.itinerary![i]['time'].toDate().minute} ',
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //               ],
  //             )

  Widget titled(String title) {
    return Text(
      textAlign: TextAlign.left,
      title,
      style: GoogleFonts.kumbhSans(
        color: Color(0xFF254268),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget get generalInformation => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Color.fromARGB(255, 245, 250, 255),
    ),
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label(instance.genlocation!, false),

          lightLabel(instance.category!, false),
          Padding(padding: EdgeInsets.only(bottom: 8), child: Divider()),

          label(instance.name!, false),
          lightLabel(instance.description!, false),
          Padding(padding: EdgeInsets.only(bottom: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              lightLabel("Start Date", false),
              lightLabel(
                "${instance.date!.day}/${instance.date!.month}/${instance.date!.year}",
                false,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget dates() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 1; i <= instance.tripDuration!; i++)
            Padding(
              padding: EdgeInsets.all(4),
              child: FilterChip(
                side: const BorderSide(
                  color: Color(0xffE7E8EC), // Cor da borda
                ),
                disabledColor: Color(0xFFecf7ff),
                showCheckmark: false,
                selectedColor: Color(0xFF8bc6f1),
                label: Text(
                  "Day $i",
                  style: GoogleFonts.kumbhSans(
                    color: Color(0xFF011f4b),
                    height: 1,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                selected: (selected == i) ? true : false,
                onSelected: (bool value) {
                  setState(() {
                    selected = i;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget editButton(bool isItinerary) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = widget.plan.userId == currentUserId;

    if (!isOwner) return const SizedBox.shrink();

    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                isItinerary
                    ? (context) => CreateItineraryPage(
                      title: '',
                      editable: true,
                      tempTrip: instance,
                    )
                    : (context) => CreateTripPage(
                      title: '',
                      editable: true,
                      edited: instance,
                    ),
          ),
        );
        setState(() {
          instance = widget.plan;
        });
      },
      icon: Icon(
        Icons.edit,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
    );
  }

  Widget seeJoinersSection() {
    final tripProvider = context.read<TripListProvider>();

    if (instance.userId == FirebaseAuth.instance.currentUser?.uid) { // only visible to owner of plan
      return Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(18),
                child: titled("Joiners"),
              ),
            ],
          ),
          StreamBuilder<List<Account>>(
            stream: tripProvider.fetchJoinersList(instance.id ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              final accounts = snapshot.data;

              if (accounts == null || accounts.isEmpty) {
                return SizedBox.shrink();
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  Account acc = accounts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 245, 250, 255),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        '${acc.firstName} ${acc.lastName}',
                        style: GoogleFonts.kumbhSans(
                          color: const Color(0xFF254268),
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '@${acc.username}' ,
                        style: GoogleFonts.kumbhSans(
                          color: const Color.fromARGB(255, 144, 167, 198),
                          fontSize: 16,
                          height: 1,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          removeJoinerBtn(acc, instance),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsPage(uid: acc.id, showPlans: false)
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
    }
    return SizedBox.shrink(); // Return an empty widget if condition is not met
  }

  Widget removeJoinerBtn(Account acc, Plans plan) {
    return IconButton(
      icon: const Icon(
        Icons.remove,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Remove joiner',
      onPressed: () async {
        
        final userDoc = FirebaseFirestore.instance.collection('users').doc(acc.id);
        final planDoc = FirebaseFirestore.instance.collection('plans').doc(plan.id);

        final userSnapshot = await userDoc.get();
        final planSnapshot = await planDoc.get();

        final userData = userSnapshot.data();
        final planData = planSnapshot.data();

        List<dynamic> joiners = List.from(planData?['joiners']);
        List<dynamic> joinedPlans = List.from(userData?['joined_plans']);

        //remove the user to the joiners of the plan
        if (joiners.contains(acc.id)) {
          joiners.remove(acc.id);
          await planDoc.update({'joiners': joiners});
        }

        // remove the plan to the list of joined plans of user
        if (joinedPlans.contains(plan.id)) {
          joinedPlans.remove(plan.id);
          await userDoc.update({'joined_plans': joinedPlans});
        }
        
        Flushbar(
          padding: EdgeInsets.all(25),
          margin: EdgeInsets.only(
            top: kToolbarHeight,
          ), // for it to appear just below the appbar
          duration: Duration(seconds: 3),
          backgroundColor: Color(0xFF9FC4F3),
          flushbarPosition: FlushbarPosition.TOP,
          messageText: Text(
            'You removed @${acc.username} from this trip',
            style: TextStyle(
              fontSize: 15,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
              color: Color.fromARGB(255, 1, 31, 75),
            ),
          ),
          // ignore: use_build_context_synchronously
        ).show(context);
      },
    );
}

Widget large(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      overflow: TextOverflow.fade,
      softWrap: false,
      title,
      style: GoogleFonts.kumbhSans(
        color: const Color(0xFF254268),
        fontSize: 64,
        height: 1,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget label(String title, bool isOverflow) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child:
        isOverflow
            ? Text(
              overflow: TextOverflow.clip,
              softWrap: false,
              title,
              style: GoogleFonts.kumbhSans(
                color: const Color(0xFF254268),
                fontSize: 16,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            )
            : Text(
              textAlign: TextAlign.left,
              title,
              style: GoogleFonts.kumbhSans(
                color: const Color(0xFF254268),
                fontSize: 16,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
  );
}

Widget lightLabel(String title, bool isOverflow) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child:
        isOverflow
            ? Text(
              overflow: TextOverflow.clip,
              softWrap: false,
              textAlign: TextAlign.left,
              title,
              style: GoogleFonts.kumbhSans(
                color: const Color.fromARGB(255, 144, 167, 198),
                fontSize: 16,
                height: 1,
              ),
            )
            : Text(
              textAlign: TextAlign.left,
              title,
              style: GoogleFonts.kumbhSans(
                color: const Color.fromARGB(255, 144, 167, 198),
                fontSize: 16,
                height: 1,
              ),
            ),
  );
}
}