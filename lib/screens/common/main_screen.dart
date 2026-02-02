import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/screens/create_trip/a_create_trip_page.dart';
import 'package:project23/screens/tabs/home_page.dart';
import '../tabs/friends_page.dart';
import '../tabs/profile_page.dart';
import '../tabs/plans_page.dart';
import '../tabs/create_plan_page.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  final Account? account;
  const MainScreen({super.key, this.user, this.account});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String title = 'TRIP PALS';
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(title: '', user: widget.user, account: widget.account),
      const FriendsPage(title: ''),
      const CreatePlanPage(title: ''),
      const PlanPage(title: ''),
      ProfilePage(title: '', account: widget.account!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF03396c),
        elevation: 0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const CreateTripPage(title: '', editable: false),
            ),
          );
        },
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF03396c), width: 3),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFF03396c),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(
            icon: SizedBox(width: 0, height: 0), // invisible item for FAB
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.window_rounded),
            label: 'Plans',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
