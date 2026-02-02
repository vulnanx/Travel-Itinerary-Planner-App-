import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/edit_profile_page.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' show UserAuthProvider;

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  final Account account;
  final String title;
  const ProfilePage({super.key, required this.title, required this.account});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D3557),
      appBar: AppbarWidget(
        title: 'Profile Page',
        showBackButton: false,
        trailing: editButton,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Column(
            children: [
              SizedBox(height: 60),
              FutureBuilder<Widget>(
                future: getProfilePic(widget.account),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading profile picture');
                  }
                  return snapshot.data ??
                      CircleAvatar(radius: 80, child: Icon(Icons.person));
                },
              ),
              SizedBox(height: 60),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0EEFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    displayDetails,
                    SizedBox(height: 30),
                    logOutButton,
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get editButton => IconButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditProfilePage(title: '')),
      );
    },
    icon: Icon(Icons.edit),
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
  );

  Widget get logOutButton => ElevatedButton.icon(
    onPressed: () {
      context.read<UserAuthProvider>().signOut();
      // Navigator.popUntil(context, ModalRoute.withName('/landingpage'));
    },
    icon: Icon(Icons.logout),
    label: Text(
      "Log out",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.kumbhSans().fontFamily,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF254268), // Button background
      foregroundColor: Colors.white, // Text and icon color
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  );

  Widget get displayDetails => Column(
    children: [
      SizedBox(height: 16),
      getdisplayName(widget.account),
      Text(
        textAlign: TextAlign.left,
        "@${widget.account.username ?? 'username'}",
        style: GoogleFonts.kumbhSans(
          color: const Color.fromARGB(255, 144, 167, 198),
          fontSize: 16,
          height: 1,
        ),
      ),
      SizedBox(height: 30),
      getPlansAndFriends(widget.account),
      SizedBox(height: 10),
      getInfo(widget.account, context),
    ],
  );

  Widget get blueCircleDesign => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Color(0xFF254268), // Dark blue top section
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(130),
        bottomRight: Radius.circular(130),
      ),
    ),
  );

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

  Widget getPlansAndFriends(Account account) => Container(
    padding: EdgeInsets.all(10),
    width: 300,
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 245, 250, 255),
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
                getPlanCountWidget(),
                Text(
                  "Travel Plans",
                  style: TextStyle(
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
                getFriendsCountWidget(),
                Text(
                  "Friends",
                  style: TextStyle(
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

  Widget getInfo(Account account, BuildContext context) => Container(
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 245, 250, 255),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Contact information',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 31, 75),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.kumbhSans().fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            infoRow('Email', account.email ?? 'email'),
            (account.contactno == null || account.contactno!.isEmpty)
                ? SizedBox(height: 0)
                : infoRow(
                  'Contact Number',
                  account.contactno ?? 'contact number',
                ),
            const SizedBox(height: 16),

            Text(
              'Interests',
              style: TextStyle(
                color: Color.fromARGB(255, 1, 31, 75),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 5,
              children:
                  account.interestsList!
                      .map(
                        (e) => Chip(
                          label: SizedBox(
                            child: Text(
                              textAlign: TextAlign.center,
                              e,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.kumbhSans(
                                color: Color(0xFF011f4b),
                                height: 1,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),

            Text(
              'Travel Styles',
              style: TextStyle(
                color: Color.fromARGB(255, 1, 31, 75),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 5,
              children:
                  account.travelStylesList!
                      .map(
                        (e) => Chip(
                          label: SizedBox(
                            child: Text(
                              textAlign: TextAlign.center,
                              e,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.kumbhSans(
                                color: Color(0xFF011f4b),
                                height: 1,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ],
    ),
  );

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

  String getPlanCount(Account plan) {
    // for each document in collection 'plans', search for those documents with userId=currentUser.uid then count

    // Placeholder return value until implementation is complete
    return "0";
  }

  Widget getPlanCountWidget() {
    final plansStream = context.watch<TripListProvider>().plan;

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

  getFriendsCountWidget() {
    final userStream = context.watch<UserAuthProvider>().account;
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

  Future<Widget> getProfilePic(Account account) async {
    return ClipOval(
      child:
          account.profileURL != null
              ? Image.memory(
                base64Decode(account.profileURL ?? ''),
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              )
              : Image.asset(
                'assets/images/profilepic.png',
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
    );
  }
}
