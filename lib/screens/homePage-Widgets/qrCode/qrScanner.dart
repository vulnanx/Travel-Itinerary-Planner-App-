import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:flutter/material.dart';
import 'qr_result.dart';

class QRcam extends StatefulWidget {
  const QRcam({Key? key}) : super(key: key);

  @override
  State<QRcam> createState() => _QRCamState();
}

class _QRCamState extends State<QRcam> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!scanned) {
        scanned = true;
        controller.pauseCamera();
        // navigate to QR result and pass scanned data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // barcode result
            builder: (context) => QRResult(data: scanData.code ?? ''),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
