import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget nextButton(
  StatefulWidget nextPage,
  GlobalKey<FormState> key,
  BuildContext context,
) {
  return ElevatedButton(
    onPressed: () async {
      if (key.currentState!.validate()) {
        key.currentState!.save();
        Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
      }
    },
    style: buttonStyle(),
    child: buttonText("Next"),
  );
}

bottomButton(
  StatefulWidget nextPage,
  GlobalKey<FormState> key,
  BuildContext context,
) {
  return BottomAppBar(
    color: Colors.transparent,
    elevation: 0,
    height: 70,
    child: nextButton(nextPage, key, context),
  );
}

buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF8bc6f1),
    elevation: 0.0,
  );
}

Widget buttonText(String text) {
  return Text(
    text,
    style: GoogleFonts.kumbhSans(
      color: Color(0xFF011f4b),
      height: 1,
      fontSize: 18,
    ),
  );
}

Widget header(String title) {
  return Text(
    textAlign: TextAlign.center,
    title,
    style: GoogleFonts.kronaOne(
      color: const Color(0xFFecf7ff),
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1,
    ),
  );
}

Widget subHeading(String sub) {
  return Text(
    textAlign: TextAlign.center,
    sub,
    style: GoogleFonts.kumbhSans(
      color: const Color(0xFF8BC6F1),
      height: 1,
      fontSize: 12,
    ),
  );
}

fieldStyle({String? errorMsg}) {
  return InputDecoration(
    filled: true,
    fillColor: Color(0xFFecf7ff),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFecf7ff), width: 2.0),
      borderRadius: BorderRadius.circular(20),
    ),
    errorText: errorMsg,
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Color(0xFFF39FA0), width: 2.0),
    ),
    errorStyle: GoogleFonts.kumbhSans(
      color: const Color(0xFFF39FA0),
      height: 1,
      fontSize: 12,
    ),
  );
}

Widget label(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      textAlign: TextAlign.left,
      title,
      style: GoogleFonts.kumbhSans(
        color: const Color(0xFFecf7ff),
        fontSize: 16,
        height: 1,
      ),
    ),
  );
}

Widget buildTextField({
  required String label,
  required String hint,
  required void Function(String?) onSaved,
  required String validatorMsg,
  required String? init,
  String? errorMsg,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      initialValue: init,
      decoration: fieldStyle(errorMsg: errorMsg),
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        return null;
      },
      style: GoogleFonts.kumbhSans(
        color: const Color(0xFF011f4b),
        fontSize: 16,
      ),
    ),
  );
}
