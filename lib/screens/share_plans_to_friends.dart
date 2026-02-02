import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SharePlanToFriendsPage extends StatefulWidget {
  final Plans plan;

  const SharePlanToFriendsPage({super.key, required this.plan, required String title});

  @override
  State<SharePlanToFriendsPage> createState() => _SharePlanToFriendsPageState();
}

class _SharePlanToFriendsPageState extends State<SharePlanToFriendsPage> {
  List<String> _recentlyInvited = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppbarWidget(title: 'Share Trip to Friends!'),
      backgroundColor: Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,          
          children: [
            friendsToInvite
          ], 
        )
      )
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
      final List<String> joinedUsers = widget.plan.joiners ?? []; // filter friends who already joined the plan

      // filter users that already has an invite sent to them


      final List<String> friendsToInvite = friends!
        .where((uid) => !joinedUsers.contains(uid) && !_recentlyInvited.contains(uid)) // has not yet joined and not recently invited
        .toList();

      if (friendsToInvite.isEmpty) {
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

      return Column(
        children: friendsToInvite.map((uid) {
          return FutureBuilder<DocumentSnapshot>(
            future: context.read<UserAuthProvider>().getUserData(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(title: Text('Loading friend...'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const ListTile(title: Text('Friend not found'));
              }

              final friendAccount = Account.fromJson(snapshot.data!.data() as Map<String, dynamic>);

              if (friendAccount.pendingInvites?.contains(widget.plan.id) ?? false) {
                return const SizedBox.shrink(); // don't  include this friend in the list tiles
              }

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
        }).toList(),
      );

    },
  );
 
  Widget sendInviteButton(String currentUserId, String invitedUser) {
    return IconButton(
      icon: const Icon(
        Icons.add_box,
        color: Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Send invite',
      onPressed: () async {

        // invite logic here
          final invited = FirebaseFirestore.instance.collection('users').doc(invitedUser);
          final invitedSnapshot = await invited.get();

          if (invitedSnapshot.exists) {
            final List<dynamic> receivedInvites = invitedSnapshot.data()?['pending_invites'] ?? [];
            receivedInvites.add(widget.plan.id);
            await invited.update({'pending_invites': receivedInvites});
            
            // add to trigger rebuild in ui
            setState(() {
              _recentlyInvited.add(invitedUser);
            });

            Flushbar(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.only(top: kToolbarHeight),
              duration: Duration(seconds: 3),
              backgroundColor: Color(0xFF9FC4F3),
              flushbarPosition: FlushbarPosition.TOP,
              messageText: Text(
                'Invite sent!',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: GoogleFonts.kumbhSans().fontFamily,
                  color: Color.fromARGB(255, 1, 31, 75),
                ),
              ),
            ).show(context);
            
        }
      }
    );
  }
}

