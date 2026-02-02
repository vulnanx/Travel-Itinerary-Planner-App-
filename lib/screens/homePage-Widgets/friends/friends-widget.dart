import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/screens/homePage-Widgets/friends/friends_popup.dart';
import 'package:provider/provider.dart';

import 'package:project23/helper/profile_pic.dart';

class FriendsWidget extends StatelessWidget {
  const FriendsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Account?>(
      stream: context.watch<UserAuthProvider>().account,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox(
            height: 150,
            child: Center(child: Text('No account logged in.')),
          );
        }

        final Account account = snapshot.data!;
        final List<String>? friends = account.friendsList;

        if (friends == null || friends.isEmpty) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'No Friends to Display.',
                style: GoogleFonts.kumbhSans(
                  color: const Color.fromARGB(255, 144, 167, 198),
                  fontSize: 20,
                  height: 1,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(width: 18),
            itemBuilder: (_, index) {
              final uid = friends[index];
              return FutureBuilder<DocumentSnapshot>(
                future: context.read<UserAuthProvider>().getUserData(uid),
                builder: (context, friendSnapshot) {
                  if (friendSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.grey[300],
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Loading...",
                          style: GoogleFonts.kumbhSans(fontSize: 16),
                        ),
                      ],
                    );
                  }

                  if (!friendSnapshot.hasData || !friendSnapshot.data!.exists) {
                    // Fallback if friend data is missing or error
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.red[200],
                          child: const Icon(Icons.error, size: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Error",
                          style: GoogleFonts.kumbhSans(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  }

                  final friendAccount = Account.fromJson(
                    friendSnapshot.data!.data() as Map<String, dynamic>,
                  );

                  return GestureDetector(
                    onTap: () {
                      FriendDialog.show(context, friendAccount);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          width: 86,
                          height: 86,
                          child: ClipOval(
                            child: getProfilePicOrInitials(
                              friendAccount,
                              size: 86,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          friendAccount.firstName ?? '',
                          style: GoogleFonts.kumbhSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF254268),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
