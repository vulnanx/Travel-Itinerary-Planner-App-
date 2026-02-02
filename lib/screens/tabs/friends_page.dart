import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/screens/user_details_page.dart';
import 'package:provider/provider.dart';

import '../../common/appbar copy.dart';

// ignore: must_be_immutable
class FriendsPage extends StatefulWidget {
  final String title;
  const FriendsPage({super.key, required this.title});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int selectedView = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: ''),
      backgroundColor: Color(0xFFE0EEFF),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: getTabButton(0, 'Friends'),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: getTabButton(1, 'Friend Requests'),
                ),
              ),
            ],
          ),
          Expanded(
            child:
                selectedView == 0
                    ? getFriendsListView
                    : getFriendRequestListView,
          ),
        ],
      ),
    );
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

  Widget get getFriendsListView => StreamBuilder<Account?>(
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
            style: GoogleFonts.kumbhSans(
              color: const Color.fromARGB(255, 144, 167, 198),
              fontSize: 20,
              height: 1,
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
                      friendAccount.email ?? 'No email',
                      style: GoogleFonts.kumbhSans(
                        color: const Color.fromARGB(255, 144, 167, 198),
                        fontSize: 16,
                        height: 1,
                      ),
                    ),
                    trailing: unfriendButton(account.id!, uid),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  UserDetailsPage(uid: uid, showPlans: true),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );

  Widget get getFriendRequestListView => StreamBuilder<Account?>(
    stream: context.watch<UserAuthProvider>().account,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text('No account logged in.'));
      }
      final Account account = snapshot.data!;
      final List<String>? requesters = account.friendRequests;
      final List<String>? sentRequests = account.friendRequestsSent;

      if (requesters!.isEmpty && sentRequests!.isEmpty) {
        return Center(
          child: Text(
            'No Friend Requests to display.',
            style: GoogleFonts.kumbhSans(
              color: const Color.fromARGB(255, 144, 167, 198),
              fontSize: 20,
              height: 1,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            requesters.isEmpty
                ? SizedBox(height: 0)
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Friend Requests Received',
                        style: GoogleFonts.kumbhSans(
                          color: Color(0xFF254268),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requesters.length,
                        itemBuilder: (context, index) {
                          final uid = requesters[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: context
                                .read<UserAuthProvider>()
                                .getUserData(uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading friend...'),
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const ListTile(
                                  title: Text('Person not found'),
                                );
                              }
                              final requesterAccount = Account.fromJson(
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
                                    '${requesterAccount.firstName} ${requesterAccount.lastName},',
                                    style: GoogleFonts.kumbhSans(
                                      color: const Color(0xFF254268),
                                      fontSize: 16,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    requesterAccount.email ?? 'No email',
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
                                      confirmReqBtn(account.id!, uid),
                                      cancelRequestBtn(account.id!, uid),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => UserDetailsPage(
                                              uid: uid,
                                              showPlans: false,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

            // FRIEND REQUESTS SENT
            sentRequests!.isEmpty
                ? SizedBox(height: 0)
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Friend Requests Sent',
                        style: GoogleFonts.kumbhSans(
                          color: Color(0xFF254268),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sentRequests.length,
                        itemBuilder: (context, index) {
                          final uid = sentRequests[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: context
                                .read<UserAuthProvider>()
                                .getUserData(uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading friend...'),
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const ListTile(
                                  title: Text('Person not found'),
                                );
                              }
                              final requesterAccount = Account.fromJson(
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
                                    '${requesterAccount.firstName} ${requesterAccount.lastName}',
                                    style: GoogleFonts.kumbhSans(
                                      color: const Color(0xFF254268),
                                      fontSize: 16,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    requesterAccount.email ?? 'No email',
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
                                      cancelRequestSentBtn(account.id!, uid),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => UserDetailsPage(
                                              uid: uid,
                                              showPlans: false,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ],
        ),
      );
    },
  );

  get seeFriends => Container(
    margin: const EdgeInsets.all(10),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        // ignore: deprecated_member_use
        backgroundColor:
            selectedView == 0
                ? Color(0xFF254268)
                : Color(0xFF254268).withOpacity(0.3),
        foregroundColor:
            selectedView == 0
                ? Color.fromARGB(255, 245, 250, 255)
                : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedView = 0;
        });
      },
      child: Text(
        'Friends',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.kumbhSans().fontFamily,
        ),
      ),
    ),
  );

  get seeFriendRequests => Container(
    margin: const EdgeInsets.all(10),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        // ignore: deprecated_member_use
        backgroundColor:
            selectedView == 1
                ? Color(0xFF254268)
                : Color(0xFF254268).withOpacity(0.3),
        foregroundColor:
            selectedView == 1
                ? Color.fromARGB(255, 245, 250, 255)
                : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedView = 1;
        });
      },
      child: Text(
        'Friend Requests',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.kumbhSans().fontFamily,
        ),
      ),
    ),
  );

  Widget cancelRequestBtn(String currentUserId, String requesterUid) {
    return IconButton(
      icon: const Icon(
        Icons.clear_rounded,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Cancel Request',
      onPressed: () async {
        final user = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId);
        final requester = FirebaseFirestore.instance
            .collection('users')
            .doc(requesterUid);
        final userSnapshot = await user.get();
        final requesterSnapshot = await requester.get();

        if (userSnapshot.exists && requesterSnapshot.exists) {
          final currentFriendRequests = List<String>.from(
            userSnapshot.data()?['friend_requests'] ?? [],
          ); // friend requests received by current user
          final requesterFRsent = List<String>.from(
            requesterSnapshot.data()?['friend_requests_sent'] ?? [],
          ); // friend requests sent by requester

          // remove requester from the friend requests
          currentFriendRequests.remove(requesterUid);
          await user.update({'friend_requests': currentFriendRequests});

          // remove the current user from the friend requests sent by requester
          requesterFRsent.remove(currentUserId);
          await requester.update({'friend_requests_sent': requesterFRsent});

          Flushbar(
            padding: EdgeInsets.all(25),
            margin: EdgeInsets.only(
              top: kToolbarHeight,
            ), // for it to appear just below the appbar
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text(
              "You canceled @${requesterSnapshot.data()?['username']}'s friend request",
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
                color: Color.fromARGB(255, 1, 31, 75),
              ),
            ),
            // ignore: use_build_context_synchronously
          ).show(context);
        }
      },
    );
  }

  Widget confirmReqBtn(String currentUserId, String requesterUid) {
    return IconButton(
      icon: const Icon(
        Icons.check_rounded,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Confirm Request',
      onPressed: () async {
        final user = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId);
        final requester = FirebaseFirestore.instance
            .collection('users')
            .doc(requesterUid);
        final userSnapshot = await user.get();
        final requesterSnapshot = await requester.get();

        if (userSnapshot.exists && requesterSnapshot.exists) {
          final currentFriendRequests = List<String>.from(
            userSnapshot.data()?['friend_requests'] ?? [],
          );
          final currentFriendList = List<String>.from(
            userSnapshot.data()?['friends'] ?? [],
          );
          final requesterFriendList = List<String>.from(
            requesterSnapshot.data()?['friends'] ?? [],
          );
          final requesterFRsent = List<String>.from(
            requesterSnapshot.data()?['friend_requests_sent'] ?? [],
          );

          // add requester as friend
          currentFriendList.add(requesterUid);
          await user.update({'friends': currentFriendList});

          // add the current user to friends of requester
          requesterFriendList.add(currentUserId);
          await requester.update({'friends': requesterFriendList});

          // remove requester from the friend requests
          currentFriendRequests.remove(requesterUid);
          await user.update({'friend_requests': currentFriendRequests});

          // remove the current user from the friends requests sent of requester
          requesterFRsent.remove(currentUserId);
          await requester.update({'friend_requests_sent': requesterFRsent});
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
            'You are now friends with @${requesterSnapshot.data()?['username']}',
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

  Widget unfriendButton(String currentUserId, String removedUid) {
    return IconButton(
      icon: const Icon(
        Icons.person_remove_rounded,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Unfriend',
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Remove Friend'),
                content: const Text(
                  'Are you sure you want to unfriend this user?',
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF254268),
                      textStyle: TextStyle(
                        fontFamily: GoogleFonts.kumbhSans().fontFamily,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF254268),
                      foregroundColor: Color.fromARGB(255, 245, 250, 255),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: TextStyle(
                        fontFamily: GoogleFonts.kumbhSans().fontFamily,
                      ),
                    ),
                    child: const Text('Unfriend'),
                  ),
                ],
              ),
        );

        if (confirmed == true) {
          final user = FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId);
          final removed = FirebaseFirestore.instance
              .collection('users')
              .doc(removedUid);
          final userSnapshot = await user.get();
          final removedSnapshot = await removed.get();

          if (userSnapshot.exists && removedSnapshot.exists) {
            final List<dynamic> currentFriends =
                userSnapshot.data()?['friends'] ?? [];
            final List<dynamic> removedCurrentFriends =
                removedSnapshot.data()?['friends'] ?? [];

            // removed friend from list of friends
            currentFriends.remove(removedUid);
            await user.update({'friends': currentFriends});

            // removes the current user from friendslist of the removed friend
            removedCurrentFriends.remove(currentUserId);
            await removed.update({'friends': removedCurrentFriends});
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
              'You unfriended @${removedSnapshot.data()?['username']}',
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
                color: Color.fromARGB(255, 1, 31, 75),
              ),
            ),
            // ignore: use_build_context_synchronously
          ).show(context);
        }
      },
    );
  }

  Widget cancelRequestSentBtn(String currentUserID, String toCancelReqSentID) {
    return IconButton(
      icon: const Icon(
        Icons.undo_rounded,
        color: const Color.fromARGB(255, 144, 167, 198),
        size: 24,
      ),
      tooltip: 'Undo Friend Request',
      onPressed: () async {
        final user = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID);
        final requested = FirebaseFirestore.instance
            .collection('users')
            .doc(toCancelReqSentID);
        final userSnapshot = await user.get();
        final requestedSnapshot = await requested.get();

        if (userSnapshot.exists && requestedSnapshot.exists) {
          final userFriendRequestSent = List<String>.from(
            userSnapshot.data()?['friend_requests_sent'] ?? [],
          ); // friend_request_sent of current user
          final requestedFriendRequests = List<String>.from(
            requestedSnapshot.data()?['friend_requests'] ?? [],
          ); // friend_requests (received) of requested user

          // remove the request sent from the current user's end
          userFriendRequestSent.remove(toCancelReqSentID);
          await user.update({'friend_requests_sent': userFriendRequestSent});

          // remove the request sent from the requested user's end
          requestedFriendRequests.remove(currentUserID);
          await requested.update({'friend_requests': requestedFriendRequests});

          Flushbar(
            padding: EdgeInsets.all(25),
            margin: EdgeInsets.only(
              top: kToolbarHeight,
            ), // for it to appear just below the appbar
            duration: Duration(seconds: 3),
            backgroundColor: Color(0xFF9FC4F3),
            flushbarPosition: FlushbarPosition.TOP,
            messageText: Text(
              "You canceled your friend request tp @${requestedSnapshot.data()?['username']}",
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
                color: Color.fromARGB(255, 1, 31, 75),
              ),
            ),
            // ignore: use_build_context_synchronously
          ).show(context);
        }
      },
    );
  }
}
