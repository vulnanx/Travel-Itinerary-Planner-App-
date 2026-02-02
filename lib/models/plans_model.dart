// modal for plans completed na

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Plans {
  String? id;
  String? userId;
  // plan details
  String? name; //name of plan
  DateTime? date;
  int? tripDuration;
  String? genlocation; // general location
  String? description; // notes langg
  String? category;
  List<Map<String, dynamic>>? itinerary; // optional
  List<String>? joiners;
  List<String>? joinersRequests;

  Plans({
    this.id,
    this.name,
    this.date,
    this.description,
    this.tripDuration,
    this.category,
    this.userId,
    this.genlocation,
    this.itinerary,
    this.joiners,
    this.joinersRequests,
  });

  // Factory constructor
  factory Plans.fromJson(Map<String, dynamic> json) {
    return Plans(
      id: json['id'],
      name: json['name'] ?? '',
      date: (json['date'] as Timestamp).toDate(), //  conversion
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      userId: json['userId'] ?? '',
      joiners: List<String>.from(json['joiners'] ?? []),
      joinersRequests: List<String>.from(json['joiners_requests'] ?? []),
      genlocation: json['genlocation'] ?? '',
      tripDuration: json['tripDuration'] ?? 1,

      itinerary:
          (json['itinerary'] as List<dynamic>?)?.map((activity) {
            final day = activity['day'];
            final time = activity['time'];
            final location = activity['location'];
            final act = activity['activity'];
            return <String, dynamic>{
              'day': day is int ? day : 1,
              'time': (time as Timestamp).toDate(),
              'location': location is String ? location : '',
              'activity': act is String ? act : 'No activity specified',
            };
          }).toList() ??
          [],
    );
  }

  static List<Plans> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Plans>((dynamic d) => Plans.fromJson(d)).toList();
  }

  // converts plan objets --> json (to be saved sa firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'description': description,
      'category': category,
      'genlocation': genlocation,
      'userId': userId,
      'joiners': joiners,
      'joiners_requests': joinersRequests,
      "tripDuration": tripDuration,
      'itinerary':
          itinerary?.map((activity) {
            return {
              'day': activity['day'],
              'time': activity['time'],
              'location': activity['location'],
              'activity': activity['activity'],
            };
          }).toList() ??
          [], // If null, default to an empty lis
    };
  }
}
