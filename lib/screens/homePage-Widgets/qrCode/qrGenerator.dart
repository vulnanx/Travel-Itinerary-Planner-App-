import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/models/plans_model.dart';

class QRGenerator {
  // returns docu id to be use sa qr data
  static String generateQRData(Plans plan) {
    // make sure plan has ID before generating qr
    if (plan.id == null || plan.id!.isEmpty) {
      throw ArgumentError('Plan must have a valid ID to generate QR data.');
    }

    return plan.id!;
  }

  // generate qr for plan, saving and sharing
  Future<void> generateAndSharePlan(Plans plan) async {
    // plan must be already saved and has id
    if (plan.id == null || plan.id!.isEmpty) {
      print('Error: Plan has no ID. Make sure it is saved to Firestore first.');
      return;
    }

    // make qr code data from plan id
    final qrData = QRGenerator.generateQRData(plan);
    //check if qr data is not empty
    if (qrData.isEmpty) {
      print('Error: Generated QR data is empty');
      return;
    }

    final fileName = 'plan_${plan.id}';

    // save qr image sa device
    final saveResult = await QRGenerator.saveQRCodeToGallery(qrData, fileName);
    if (saveResult != null) {
      print('Error saving QR: $saveResult');
      return;
    }
  }

  // saves qr sa device
  static Future<String?> saveQRCodeToGallery(
    String qrData,
    String fileName,
  ) async {
    final isAndroid = Platform.isAndroid;
    // permissions
    if (isAndroid) {
      final photosPermission = await Permission.photos.request();
      final storagePermission = await Permission.storage.request();

      if (!photosPermission.isGranted && !storagePermission.isGranted) {
        return 'Permission denied to access media storage';
      }
    }

    try {
      // temp directory to store
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/$fileName.png';

      // generate qr image
      final qrImage = await QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImageData(300.0);

      if (qrImage != null) {
        //save to a file
        final file = File(imagePath);
        await file.writeAsBytes(qrImage.buffer.asUint8List());

        // save to gallery
        final result = await ImageGallerySaverPlus.saveImage(
          await file.readAsBytes(),
          name: fileName,
        );

        return result['isSuccess'] == true
            ? null
            : 'Failed to save QR code to gallery';
      }

      return 'Failed to generate QR image';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
