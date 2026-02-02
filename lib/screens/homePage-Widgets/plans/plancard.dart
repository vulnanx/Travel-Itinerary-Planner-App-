import 'package:flutter/material.dart';
import 'package:project23/models/plans_model.dart';
import 'package:project23/screens/tabs/plan_info.dart';

class PlanCard extends StatelessWidget {
  final Plans plan;

  const PlanCard({required this.plan, super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PlanInfo(title: 'Plan', plan: plan, edittable: true),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ClipPath(
            clipper: BottomRightCutClipper(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 89, 129, 183),
                    Color(0xFF254268),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.travel_explore,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                plan.name ?? "Unnamed Plan",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // left details
                        // https://emojipedia.org/
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "📍 ${plan.genlocation ?? 'Unknown'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "📂  ${plan.category ?? 'General'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "🗓  ${plan.date?.toLocal().toString().split(' ')[0] ?? 'No date'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "⏱  ${plan.tripDuration ?? 1} day(s)",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),

                  // navigate to info
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PlanInfo(
                                  title: 'Plan',
                                  plan: plan,
                                  edittable: false,
                                ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.arrow_outward,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomRightCutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 50.0;

    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width - radius, size.height); // move to curve start

    // curved inward
    path.arcToPoint(
      Offset(size.width, size.height - radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, 0); // top-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
