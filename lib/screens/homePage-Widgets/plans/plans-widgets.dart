import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/plans_model.dart';
import '../../../../providers/plans_provider.dart';
import 'plancard.dart';

class PlansWidget extends StatelessWidget {
  const PlansWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripListProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot>(
            stream: tripProvider.plan,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No active plans.",
                    style: GoogleFonts.kumbhSans(
                      color: const Color.fromARGB(255, 144, 167, 198),
                      fontSize: 20,
                      height: 1,
                    ),
                  ),
                );
              }

              // Filter active plans (same lang sa plans page)
              final List activePlans =
                  snapshot.data!.docs
                      .map((doc) {
                        final plan = Plans.fromJson(
                          doc.data() as Map<String, dynamic>,
                        );
                        plan.id = doc.id;
                        return plan;
                      })
                      .where(
                        (plan) =>
                            plan.date != null &&
                            (DateTime.now().isAtSameMomentAs(plan.date!) ||
                                DateTime.now().isBefore(
                                  plan.date!.add(
                                    Duration(days: plan.tripDuration ?? 1),
                                  ),
                                )),
                      )
                      .take(10)
                      .toList();

              if (activePlans.isEmpty) {
                return const Center(child: Text("No active trips found."));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activePlans.length,
                itemBuilder: (context, index) {
                  final plan = activePlans[index];
                  return PlanCard(plan: plan);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
