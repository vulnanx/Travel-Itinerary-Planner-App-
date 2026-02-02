import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:project23/providers/users_provider.dart';
import 'suggestion-popup.dart';

class SimilarTravelers extends StatelessWidget {
  const SimilarTravelers({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserListProvider>(context);

    if (userProvider.isLoading) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Finding travelers for you...',
                style: GoogleFonts.kumbhSans(
                  color: const Color.fromARGB(255, 144, 167, 198),
                  fontSize: 20,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (userProvider.suggestedTravelers.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No travelers with similar interests found yet.',
            style: GoogleFonts.kumbhSans(
              color: const Color.fromARGB(255, 144, 167, 198),
              fontSize: 20,
              height: 1,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: userProvider.suggestedTravelers.length,
            itemBuilder: (context, index) {
              final traveler = userProvider.suggestedTravelers[index];
              final totalMatches =
                  traveler['matchedInterests'].length +
                  traveler['matchedTravelStyles'].length;

              return GestureDetector(
                onTap: () {
                  userProfilePopup(
                    context,
                    traveler,
                    onFriendAdded: (String userId) {
                      userProvider.removeTravelerById(userId);
                    },
                  );
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF254268),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFFE0EEFF),
                          child: Text(
                            '${traveler['firstName'][0]}${traveler['lastName'][0]}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF254268),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${traveler['firstName']} ${traveler['lastName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '@${traveler['username']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 140, 162, 194),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$totalMatches in common',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 81, 157, 232),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
