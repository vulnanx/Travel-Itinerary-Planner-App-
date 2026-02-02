import 'package:flutter/material.dart';
import 'package:project23/screens/homePage-Widgets/qrCode/qrGenerator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/plans_model.dart';

class PlanQRGenerator extends StatefulWidget {
  final Plans plan;

  const PlanQRGenerator({Key? key, required this.plan}) : super(key: key);

  @override
  State<PlanQRGenerator> createState() => _PlanQRGeneratorState();
}

class _PlanQRGeneratorState extends State<PlanQRGenerator> {
  bool isSaving = false;
  String statusMessage = '';
  final GlobalKey qrKey = GlobalKey();

  // saved qr to device galleryy
  Future<void> _saveQRCodeToGallery() async {
    setState(() {
      isSaving = true;
      statusMessage = 'Preparing QR code...';
    });

    // generate data string for qr code
    final data = QRGenerator.generateQRData(widget.plan);
    // save qr code as an image
    final error = await QRGenerator.saveQRCodeToGallery(
      data,
      'plan_qr_${DateTime.now().millisecondsSinceEpoch}',
    );

    setState(() {
      isSaving = false;
      statusMessage = error ?? 'QR code saved to gallery successfully!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrData = QRGenerator.generateQRData(widget.plan);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Plan as QR Code'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 89, 129, 183),
      ),
      backgroundColor: const Color(0xFFE3F2FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child:
              // Main Card
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(top: 50),
                color: Color.fromARGB(255, 89, 129, 183),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      QrImageView(
                        key: qrKey,
                        data: qrData,
                        version: QrVersions.auto,
                        size: 250.0,
                        gapless: true,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: isSaving ? null : _saveQRCodeToGallery,
                        icon: const Icon(Icons.save_alt),
                        label: const Text("Save to Gallery"),
                      ),
                      const SizedBox(height: 20),
                      if (statusMessage.isNotEmpty)
                        Text(
                          statusMessage,
                          style: TextStyle(
                            color:
                                statusMessage.contains('Error') ||
                                        statusMessage.contains('Failed')
                                    ? Colors.red
                                    : const Color.fromARGB(255, 76, 116, 175),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home),
                        label: const Text("Back to Homepage"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF254268),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Positioned above card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF254268),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade300,
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.plan.name ?? 'No Name',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
