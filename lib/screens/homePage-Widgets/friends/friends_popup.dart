import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/providers/plans_provider.dart';

import 'package:provider/provider.dart';
import 'package:project23/helper/profile_pic.dart';

class FriendDialog {
  static void show(BuildContext context, Account friendAccount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // either profile pic or initials from helper
                getProfilePicOrInitials(friendAccount, size: 80),
                const SizedBox(height: 16),

                if (friendAccount.email != null)
                  Column(
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.kumbhSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friendAccount.email!,
                        style: GoogleFonts.kumbhSans(
                          fontSize: 16,
                          color: const Color(0xFF254268),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Username
                Column(
                  children: [
                    Text(
                      'Username',
                      style: GoogleFonts.kumbhSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${friendAccount.firstName ?? ''} ${friendAccount.lastName ?? ''}',
                      style: GoogleFonts.kumbhSans(
                        fontSize: 16,
                        color: const Color(0xFF254268),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Recent Plans Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Some of ${friendAccount.firstName ?? 'User'}\'s Plans',
                      style: GoogleFonts.kumbhSans(
                        fontSize: 14,
                        color: const Color(0xFF254268),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(color: Color(0xFF8bc6f1), thickness: 1),
                    const SizedBox(height: 8),
                    _buildPlansList(context, friendAccount.id),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.kumbhSans(
                  color: const Color(0xFF254268),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildPlansList(BuildContext context, String? userId) {
    final provider = Provider.of<TripListProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Text('Please log in to view plans');
    }

    return StreamBuilder<List<Plans>>(
      stream: provider.getPlansList(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'No plans yet',
            style: GoogleFonts.kumbhSans(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          );
        }

        final plans = snapshot.data!;
        //up to 5 langg
        final limitedPlans = plans.length > 5 ? plans.sublist(0, 5) : plans;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              limitedPlans.map((plan) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF254268),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.name ?? 'Untitled Plan',
                          style: GoogleFonts.kumbhSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF254268),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
