import 'package:flutter/material.dart';
import 'package:project23/api/firebase_notification_api.dart';
import 'package:project23/api/firebase_plans_api.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/screens/create_trip/d_see_qr_page.dart';
import '../../models/plans_model.dart';

// check and confirm before masave
class ConfirmTripPage extends StatelessWidget {
  final String title;
  final Plans tempTrip; // temp plan to be check

  const ConfirmTripPage({
    super.key,
    required this.title,
    required this.tempTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: 'Confirm Trip Details'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem("Trip Name", tempTrip.name),
            _buildSummaryItem("Description", tempTrip.description),
            _buildSummaryItem("Category", tempTrip.category),
            _buildSummaryItem("Location", tempTrip.genlocation),
            _buildSummaryItem(
              "Date & Time",
              tempTrip.date?.toLocal().toString() ?? 'Not set',
            ),
            const SizedBox(height: 16),
            const Text(
              "Itinerary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // show itinerary if not empty
            if (tempTrip.itinerary != null && tempTrip.itinerary!.isNotEmpty)
              ...tempTrip.itinerary!.asMap().entries.map((entry) {
                final item = entry.value;
                final index = entry.key + 1;
                final time = item['time'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text('Activity $index: ${item['activity'] ?? ''}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item['location'] != null)
                            Text('Location: ${item['location']}'),
                          if (item['time'] != null) Text('Time: $time'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()
            else
              const Text("No itinerary items added."),
            const SizedBox(height: 24),

            // button to save and navigates sa QR page
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final firebaseApi = FirebasePlanApi();

                  // save plan sa firestore and get docu id
                  final newPlanId = await firebaseApi.addPlan({
                    'name': tempTrip.name,
                    'description': tempTrip.description,
                    'category': tempTrip.category,
                    'genlocation': tempTrip.genlocation,
                    'tripDuration': tempTrip.tripDuration,
                    'date': tempTrip.date,
                    'itinerary': tempTrip.itinerary,
                  });

                  // if succeeded:
                  NotifApi().scheduleNotification(
                    id: 1,
                    title: "Don't Miss Your Trip named ${tempTrip.name}",
                    body:
                        "You have a trip to ${tempTrip.genlocation} and you wouldn't want to miss it!",
                    date: tempTrip.date!.subtract(Duration(days: 1)),
                  );

                  NotifApi().showNotification(
                    id: 1,
                    title: "Succesffuly Created ${tempTrip.name}",
                    body:
                        "You have a trip to ${tempTrip.genlocation} and you wouldn't want to miss it!",
                  );

                  // create plan object with ID
                  final savedPlan = Plans(
                    id: newPlanId,
                    name: tempTrip.name,
                    description: tempTrip.description,
                    category: tempTrip.category,
                    genlocation: tempTrip.genlocation,
                    tripDuration: tempTrip.tripDuration,
                    date: tempTrip.date,
                    itinerary: tempTrip.itinerary,
                    userId: tempTrip.userId, // if available
                  );

                  //navigate to QR screen and passing saved plan
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlanQRGenerator(plan: savedPlan),
                    ),
                  );
                },

                icon: const Icon(Icons.check_circle),
                label: const Text("Confirm Plan & Generate QR Code"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF011f4b),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? 'Not set',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
