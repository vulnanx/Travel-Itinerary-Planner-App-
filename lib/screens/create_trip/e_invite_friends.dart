import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SharePlanWhenCreated extends StatefulWidget {
  final Plans plan;

  const SharePlanWhenCreated({super.key, required this.plan});

  @override
  State<SharePlanWhenCreated> createState() => _SharePlanWhenCreatedState();
}

class _SharePlanWhenCreatedState extends State<SharePlanWhenCreated> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: 'Share Trip to Friends!',
        showBackButton: false,
      ),
      backgroundColor: Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Expanded(child: friendsToInvite), homeButton],
        ),
      ),
    );
  }

  Widget get friendsToInvite => StreamBuilder<Account?>(
    stream: context.watch<UserAuthProvider>().account,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text('No account logged in.'));
      }

      final Account account = snapshot.data!;
      final List<String>? friends = account.friendsList;

      if (friends!.isEmpty) {
        return Center(
          child: Text(
            'No Friends to Display.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final uid = friends[index];
            return FutureBuilder<DocumentSnapshot>(
              future: context.read<UserAuthProvider>().getUserData(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text('Loading friend...'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const ListTile(title: Text('Friend not found'));
                }

                final friendAccount = Account.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 245, 250, 255),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      '${friendAccount.firstName} ${friendAccount.lastName}',
                      style: GoogleFonts.kumbhSans(
                        color: const Color(0xFF254268),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      friendAccount.username ?? 'No username',
                      style: GoogleFonts.kumbhSans(
                        color: const Color.fromARGB(255, 144, 167, 198),
                        fontSize: 16,
                        height: 1,
                      ),
                    ),
                    trailing: sendInviteButton(account.id!, uid),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );

  Widget sendInviteButton(String currentUserId, String invitedUser) {
    return IconButton(
      icon: const Icon(
        Icons.add_box,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Send invite',
      onPressed: () async {
        Flushbar(
          padding: EdgeInsets.all(25),
          margin: EdgeInsets.only(
            top: kToolbarHeight,
          ), // for it to appear just below the appbar
          duration: Duration(seconds: 3),
          backgroundColor: Color(0xFF9FC4F3),
          flushbarPosition: FlushbarPosition.TOP,
          messageText: Text(
            'You sent an invite',
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

  Widget get homeButton => ElevatedButton.icon(
    onPressed: () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    },
    icon: const Icon(Icons.home),
    label: const Text("Back to Homepage"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF8BC6F1),
      foregroundColor: Color.fromARGB(255, 1, 31, 75),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
