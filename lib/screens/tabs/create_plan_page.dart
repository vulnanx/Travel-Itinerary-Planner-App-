import 'package:flutter/material.dart';
import 'package:project23/screens/create_trip/a_create_trip_page.dart';

// ignore: must_be_immutable
class CreatePlanPage extends StatefulWidget {
  final String title;
  const CreatePlanPage({super.key, required this.title});

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Create Plan Page', style: TextStyle(fontSize: 24)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const CreateTripPage(title: '', editable: false),
                ),
              );
            },
            child: Text("Next"),
          ),
        ],
      ),
    );
  }
}
