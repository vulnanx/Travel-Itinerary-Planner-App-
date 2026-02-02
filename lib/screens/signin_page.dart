import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/screens/sign_up/signup_page.dart';
import 'package:provider/provider.dart';
import '../api/firebase_notification_api.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'sign_up/e_interests.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? password;
  bool isObscured = true;
  bool showSignInErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 75),
      appBar: AppbarWidget(title: 'Sign In'),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title,
                Padding(padding: EdgeInsets.all(4)),
                sub,
                Padding(padding: EdgeInsets.all(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [userLabel],
                ),
                usernameField,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [passLabel],
                ),
                passwordField,
                showSignInErrorMessage ? signInErrorMessage : Container(),
                SizedBox(width: double.infinity, child: submitButton),
                Column(
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: new Container(
                            margin: const EdgeInsets.only(
                              left: 10.0,
                              right: 32.0,
                            ),
                            child: Divider(
                              color: Color(0xFF8bc6f1),
                              height: 36,
                            ),
                          ),
                        ),
                        Text(
                          "OR",
                          style: GoogleFonts.kumbhSans(
                            color: Color(0xFF8bc6f1),
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: new Container(
                            margin: const EdgeInsets.only(
                              left: 32.0,
                              right: 10.0,
                            ),
                            child: Divider(
                              color: Color(0xFF8bc6f1),
                              height: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                  ],
                ),
                SizedBox(width: double.infinity, child: googleButton),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get usernameField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      decoration: fieldStyle(),
      onSaved: (value) => setState(() => username = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your username";
        }
        return null;
      },
    ),
  );

  Widget get passwordField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
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
      onSaved: (value) => setState(() => password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        return null;
      },
    ),
  );

  Widget get signInErrorMessage => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Text(
      "Invalid username or password",
      style: GoogleFonts.kumbhSans(
        color: const Color(0xFFF39FA0),
        height: 1,
        fontSize: 12,
      ),
    ),
  );

  Widget get submitButton => ElevatedButton(
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        String? message = await context
            .read<UserAuthProvider>()
            .authService
            .signIn(username!, password!);

        setState(() {
          if (message != "Successfully signed in!") {
            showSignInErrorMessage = true;
          } else {
            showSignInErrorMessage = false;
            Navigator.pop(context);
          }
        });
      }
    },
    style: buttonStyle(),
    child: buttonText("Log in"),
  );

  Widget get googleButton => ElevatedButton.icon(
    onPressed: () async {
      await context.read<UserAuthProvider>().authService.signInWithGoogle();
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
      iconAlignment: IconAlignment.start,
      backgroundColor: Color(0xFFecf7ff),
    ),
    icon: FaIcon(FontAwesomeIcons.google, size: 20, color: Color(0xFF011f4b)),
    label: Text(
      "  Sign in with google",
      style: GoogleFonts.kumbhSans(
        color: Color(0xFF011f4b),
        height: 1,
        fontSize: 16,
      ),
    ),
  );

  Widget get title => header("Welcome back, Pal!");
  Widget get userLabel => label("Username");
  Widget get passLabel => label("Password");
  Widget get sub => subHeading("We’re so excited to see you again!");
}
