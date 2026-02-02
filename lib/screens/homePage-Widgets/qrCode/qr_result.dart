import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelines_plus/timelines_plus.dart';

class QRResult extends StatefulWidget {
  final String data;

  const QRResult({super.key, required this.data});

  @override
  State<QRResult> createState() => _QRScannerResultState();
}

class _QRScannerResultState extends State<QRResult> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _planData; // holds plan data from firestoree
  int selected = 1;

  @override
  void initState() {
    super.initState();
    _fetchPlanData();
  }

  Future<void> _fetchPlanData() async {
    try {
      final planId = widget.data; // scanned val

      if (planId.isEmpty) {
        // if qr data is empty:
        setState(() {
          _isLoading = false;
          _errorMessage = "QR code does not contain a valid plan ID";
        });
        return;
      }

      // fetch plan data from Firestore using the ID
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('plans')
              .doc(planId)
              .get();
      // in case no docu found
      if (!docSnapshot.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Plan not found";
        });
        return;
      }

      // if found, get data ng plan and include ID
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;

      setState(() {
        _planData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading plan: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading Plan")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildError(context, _errorMessage!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Scanned Plan")),
      backgroundColor: Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: titled("Details"),
                  ),
                ],
              ),
              _buildGeneralInformation(),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: titled("Activities"),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(left: 12), child: _buildDates()),
              _buildItinerarySection(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add to My Plans"),
                  onPressed: _joinPlan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItinerarySection() {
    final itinerary = List<Map<String, dynamic>>.from(_planData!['itinerary']);
    final dayActivities =
        itinerary.where((item) => item['day'] == selected).toList();

    bool isEdgeIndex(int index) => index == dayActivities.length - 1;
    bool isStartIndex(int index) => index == 0;

    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 245, 250, 255),
      ),
      child:
          dayActivities.isNotEmpty
              ? Padding(
                padding: EdgeInsets.all(20),
                child: FixedTimeline.tileBuilder(
                  theme: TimelineTheme.of(context).copyWith(
                    nodePosition: 0,
                    connectorTheme: TimelineTheme.of(
                      context,
                    ).connectorTheme.copyWith(thickness: 1.0),
                    indicatorTheme: TimelineTheme.of(
                      context,
                    ).indicatorTheme.copyWith(size: 10.0, position: 0.5),
                  ),
                  builder: TimelineTileBuilder(
                    itemCount: dayActivities.length,
                    indicatorBuilder:
                        (_, index) => Indicator.dot(color: Color(0xFF254268)),
                    startConnectorBuilder:
                        (_, index) =>
                            !isStartIndex(index)
                                ? Connector.solidLine(
                                  color: Color.fromARGB(255, 144, 167, 198),
                                )
                                : null,
                    endConnectorBuilder:
                        (_, index) =>
                            !isEdgeIndex(index)
                                ? Connector.solidLine(
                                  color: Color.fromARGB(255, 144, 167, 198),
                                )
                                : null,
                    contentsBuilder:
                        (context, index) => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label(dayActivities[index]['activity'], false),
                              lightLabel(
                                "${dayActivities[index]['time'].toDate().hour}:${dayActivities[index]['time'].toDate().minute.toString().padLeft(2, '0')}",
                                false,
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              )
              : Center(
                child: Image.asset('assets/images/noschedule.png', scale: 0.5),
              ),
    );
  }

  Widget _buildGeneralInformation() {
    final date = (_planData!['date'] as Timestamp).toDate();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 245, 250, 255),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label(_planData!['genlocation'] ?? 'N/A', false),
            lightLabel(_planData!['category'] ?? 'N/A', false),
            Padding(padding: EdgeInsets.only(bottom: 8), child: Divider()),
            label(_planData!['name'] ?? 'N/A', false),
            lightLabel(_planData!['description'] ?? 'N/A', false),
            Padding(padding: EdgeInsets.only(bottom: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                lightLabel("Start Date", false),
                lightLabel("${date.day}/${date.month}/${date.year}", false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDates() {
    final duration = _planData!['tripDuration'] ?? 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 1; i <= duration; i++)
            Padding(
              padding: EdgeInsets.all(4),
              child: FilterChip(
                selected: selected == i,
                onSelected: (_) => setState(() => selected = i),
                label: Text(
                  "Day $i",
                  style: GoogleFonts.kumbhSans(fontSize: 16),
                ),
                selectedColor: Color(0xFF8bc6f1),
              ),
            ),
        ],
      ),
    );
  }

  void _joinPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('You must be signed in to join a plan.');
      return;
    }

    final userId = user.uid;
    final planRef = FirebaseFirestore.instance
        .collection('plans')
        .doc(widget.data);
    final planSnap = await planRef.get();

    if (!planSnap.exists) {
      _showMessage('Plan not found.');
      return;
    }

    final data = planSnap.data();
    if (data?['userId'] == userId) {
      _showMessage('This is a plan you created.');
      return;
    }

    final List<dynamic> joiners = data?['joiners'] ?? [];
    if (joiners.contains(userId)) {
      _showMessage('You have already joined this plan.');
    } else {
      await planRef.update({
        'joiners': FieldValue.arrayUnion([userId]),
      });
      _showMessage('You’ve successfully joined this plan!');
    }

    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget titled(String title) {
    return Text(
      title,
      style: GoogleFonts.kumbhSans(
        color: Color(0xFF254268),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget label(String title, bool isOverflow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        overflow: isOverflow ? TextOverflow.clip : null,
        softWrap: !isOverflow,
        style: GoogleFonts.kumbhSans(
          color: Color(0xFF254268),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget lightLabel(String title, bool isOverflow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        overflow: isOverflow ? TextOverflow.clip : null,
        softWrap: !isOverflow,
        style: GoogleFonts.kumbhSans(
          color: Color.fromARGB(255, 144, 167, 198),
          fontSize: 16,
        ),
      ),
    );
  }
}
