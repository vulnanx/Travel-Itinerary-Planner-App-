import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import 'c_username.dart';
import '../../common/appbar.dart';
import 'signup_page.dart';

class SecondPage extends StatefulWidget {
  final Account newUser;

  const SecondPage({super.key, required this.newUser});
  @override
  State<SecondPage> createState() => _SignUpState();
}

class _SignUpState extends State<SecondPage> {
  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;
  // fields to store inputs
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 75),
      appBar: AppbarWidget(title: 'Create Account'),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //fields
                title,
                Padding(padding: EdgeInsets.all(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [tLabel],
                ),
                passwordField,
                SizedBox(width: double.infinity, child: next),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // field widgets

  Widget get passwordField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      initialValue: widget.newUser.password,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFecf7ff),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isObscured = !isObscured;
            });
          },
          icon:
              isObscured
                  ? Icon(
                    CupertinoIcons.eye,
                    color: Color.fromARGB(255, 117, 117, 117),
                  )
                  : Icon(
                    CupertinoIcons.eye_slash,
                    color: Color.fromARGB(255, 117, 117, 117),
                  ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFecf7ff), width: 2.0),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      obscureText: isObscured,
      onSaved: (value) => widget.newUser.password = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a valid password";
        }
        if (value.length < 8) {
          return "Password must be at least 8 characters";
        }

        return null;
      },
      style: GoogleFonts.kumbhSans(
        color: const Color(0xFF011f4b),
        fontSize: 16,
      ),
    ),
  );

  Widget get next =>
      nextButton(ThirdPage(newUser: widget.newUser), _formKey, context);
  Widget get title => header("Create a password");
  Widget get tLabel => label("Password");
}
