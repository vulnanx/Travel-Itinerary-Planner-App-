import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/homePage-Widgets/findSimilarPeople/suggestions-widget.dart';
import 'package:project23/screens/homePage-Widgets/friends/friends-widget.dart';
import 'package:project23/screens/homePage-Widgets/plans/plans-widgets.dart';
import 'package:provider/provider.dart';

import '../../api/firebase_notification_api.dart';
import '../../models/user_model.dart';
import '../sign_up/e_interests.dart';

class HomePage extends StatefulWidget {
  final User? user;
  final Account? account;
  final String title;
  const HomePage({
    super.key,
    required this.title,
    required this.user,
    this.account,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _didCallRefresh = false;
  bool openScreen = false;
  String? _firstName;

  @override
  void initState() {
    NotifApi().initNotif();
    super.initState();

    if (widget.account!.interestsList!.isEmpty &&
        widget.account!.travelStylesList!.isEmpty) {
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => FifthPage(
                  newUser: widget.account as Account,
                  isGoogle: true,
                ),
          ),
        );
      });
    }

    _loadFirstName();
  }

  void _loadFirstName() async {
    final userProvider = Provider.of<UserAuthProvider>(context, listen: false);

    try {
      final account = await userProvider.currUserAccount;
      setState(() {
        _firstName = account.firstName ?? 'Traveler';
      });
    } catch (e) {
      setState(() {
        _firstName = 'Traveler'; // fallback on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripListProvider>(context, listen: false);

    if (!_didCallRefresh) {
      tripProvider.refreshPlans(); // Refresh
      _didCallRefresh = true;
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1D3557),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.20,
                width: double.infinity,
                color: const Color(0xFF1D3557),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hello, ${_firstName ?? 'Traveler'}!",
                            style: GoogleFonts.kumbhSans(
                              color: Color.fromARGB(255, 245, 250, 255),
                              fontSize: 22,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),
                          Text(
                            "Your journey starts here! Discover, plan, and explore!",
                            style: GoogleFonts.kumbhSans(
                              color: Color.fromARGB(184, 245, 250, 255),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT: Image
                    Image.asset(
                      'assets/images/travel.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // CURVED LIGHT BLUE SECTION - rest of content
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0EEFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // Search Bar (just layout)
                    // Container(
                    //   height: 50,
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(25),
                    //   ),
                    //   child: Row(
                    //     children: const [
                    //       Icon(Icons.location_on_outlined, color: Colors.blue),
                    //       SizedBox(width: 10),
                    //       Expanded(
                    //         child: Text(
                    //           "Where to?",
                    //           style: TextStyle(fontSize: 16),
                    //         ),
                    //       ),
                    //       Icon(Icons.search, color: Colors.blue),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    const SizedBox(height: 20),

                    Text(
                      "Your Friends",
                      style: GoogleFonts.kumbhSans(
                        color: const Color(0xFF254268),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const FriendsWidget(),
                    Text(
                      "Upcoming Trips",
                      style: GoogleFonts.kumbhSans(
                        color: const Color(0xFF254268),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PlansWidget(),

                    const SizedBox(height: 20),
                    Text(
                      "Travelers You May Know",
                      style: GoogleFonts.kumbhSans(
                        color: const Color(0xFF254268),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const SimilarTravelers(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
