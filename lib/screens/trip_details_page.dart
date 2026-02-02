import 'package:flutter/material.dart';
import 'package:project23/common/appbar.dart';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key, required this.title});

  final String title;

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: 'Trip Details Page'),
      body: SingleChildScrollView(
        child: Container(),
      ),
    );
  }
}