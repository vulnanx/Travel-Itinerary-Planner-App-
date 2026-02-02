import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';
import 'package:project23/providers/users_provider.dart';

// user details when clicked
void userProfilePopup(
  BuildContext context,
  Map<String, dynamic> user, {
  required Function(String) onFriendAdded,
}) {
  // total count of travel styles + interests in common
  final totalMatches =
      List<String>.from(user['matchedInterests']).length +
      List<String>.from(user['matchedTravelStyles']).length;

  Widget buildListSection(
    String title,
    List<String> items,
    List<String> matches,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title == 'Interests' ? Icons.interests : Icons.travel_explore,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items.map((item) {
                  final isMatch = matches.contains(item);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMatch ? color : Colors.transparent,
                          ),
                        ),
                        Text(
                          item,
                          style: TextStyle(
                            fontFamily: GoogleFonts.kumbhSans().fontFamily,
                            color: isMatch ? color : Colors.black,
                            fontWeight:
                                isMatch ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isMatch)
                          Text(
                            ' (Match!)',
                            style: TextStyle(
                              color: color.withOpacity(0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontFamily: GoogleFonts.kumbhSans().fontFamily,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          '${user['firstName']} ${user['lastName']}',
          style: TextStyle(
            fontFamily: GoogleFonts.kumbhSans().fontFamily,
            fontWeight: FontWeight.w900,
            color: Color(0xFF254268),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username: @${user['username']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.kumbhSans().fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have $totalMatches things in common!',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF254268),
                  fontFamily: GoogleFonts.kumbhSans().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              buildListSection(
                'Interests',
                List<String>.from(user['interests']),
                List<String>.from(user['matchedInterests']),
                Color(0xFF254268),
              ),
              const SizedBox(height: 16),
              buildListSection(
                'Travel Styles',
                List<String>.from(user['travelStyles']),
                List<String>.from(user['matchedTravelStyles']),
                Color(0xFF254268),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF254268)),
            child: Text(
              'Close',
              style: TextStyle(fontFamily: GoogleFonts.kumbhSans().fontFamily),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<UserListProvider>().sendFriendRequest(
                user['id'],
                onFriendAdded,
              );
              context.read<UserListProvider>().removeTravelerById(user['id']);
              Navigator.of(context).pop();

              Flushbar(
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.only(
                  top: kToolbarHeight,
                ), // for it to appear just below the appbar
                duration: Duration(seconds: 3),
                backgroundColor: Color(0xFFE0EEFF),
                flushbarPosition: FlushbarPosition.TOP,
                messageText: Text(
                  'Friend request sent to @${user['username']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: GoogleFonts.kumbhSans().fontFamily,
                    color: Color.fromARGB(255, 1, 31, 75),
                  ),
                ),
              ).show(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF254268),
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1),
                Text(
                  '  Add Friend',
                  style: TextStyle(
                    fontFamily: GoogleFonts.kumbhSans().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
