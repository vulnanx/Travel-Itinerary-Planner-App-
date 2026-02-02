/*
  Created by: Claizel Coubeili Cepe
  Date: updated April 26, 2023
  Description: Sample todo app with Firebase 
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/screens/common/landing_page.dart';
import 'package:project23/screens/common/main_screen.dart';
import 'package:project23/screens/sign_up/e_interests.dart';
import 'package:provider/provider.dart';

class userChecker extends StatefulWidget {
  const userChecker({super.key});

  @override
  State<userChecker> createState() => _userCheckerState();
}

class _userCheckerState extends State<userChecker> {
  @override
  Widget build(BuildContext context) {
    Stream<User?> userStream = context.watch<UserAuthProvider>().userStream;

    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error encountered! ${snapshot.error}")),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData) {
          return const LandingPage();
        }
        var log = snapshot.data;
        return StreamBuilder<Account?>(
          stream: context.read<UserAuthProvider>().account,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Column(
                children: [Text('Error loading profile: ${snapshot.error}')],
              );
            }
            final account = snapshot.data;

            return MainScreen(user: log, account: account);
          },
        );
      },
    );
  }
}
