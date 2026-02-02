import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

Widget getProfilePicOrInitials(Account account, {double size = 76}) {
  final borderColor = const Color(0xFF254268);
  final borderWidth = 2.5;
  final gap = 3.0;

  Widget imageOrInitials;

  if (account.profileURL != null && account.profileURL!.isNotEmpty) {
    try {
      final decoded = base64Decode(account.profileURL!);
      imageOrInitials = ClipOval(
        child: Image.memory(
          decoded,
          fit: BoxFit.cover,
          width: size - 2 * (borderWidth + gap),
          height: size - 2 * (borderWidth + gap),
        ),
      );
    } catch (e) {
      // fallback to initials
      imageOrInitials = _initialsAvatar(
        size - 2 * (borderWidth + gap),
        account,
      );
    }
  } else {
    imageOrInitials = _initialsAvatar(size - 2 * (borderWidth + gap), account);
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: borderWidth),
    ),
    child: Padding(padding: EdgeInsets.all(gap), child: imageOrInitials),
  );
}

Widget _initialsAvatar(double size, Account account) {
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: Colors.grey.shade300,
    child: Text(
      '${account.firstName?.isNotEmpty == true ? account.firstName![0] : ''}'
      '${account.lastName?.isNotEmpty == true ? account.lastName![0] : ''}',
      style: TextStyle(
        fontSize: size / 2.5,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
