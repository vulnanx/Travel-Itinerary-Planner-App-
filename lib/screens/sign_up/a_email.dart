import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../common/appbar.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'b_password.dart';
import 'signup_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _SignUpState();
}

class _SignUpState extends State<FirstPage> {
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _email;

  // fields to store inputs
  final Account newUser = Account();
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
                Padding(padding: EdgeInsets.all(4)),
                sub,
                Padding(padding: EdgeInsets.all(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [emailLabel],
                ),
                emailField,
                SizedBox(width: double.infinity, child: next),
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

  // field widgets

  Widget get emailField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      initialValue: newUser.email,
      decoration: fieldStyle(errorMsg: _emailError),
      onSaved: (value) => _email = value!.toLowerCase(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a valid email format";
        }
        if (!value.contains('@') || !value.contains('.')) {
          return "Enter a valid email address";
        }
        return null;
      },
      style: GoogleFonts.kumbhSans(
        color: const Color(0xFF011f4b),
        fontSize: 16,
      ),
    ),
  );

  Widget get next => ElevatedButton(
    onPressed: () async {
      // reset any previous error message muna
      setState(() {
        _emailError = null;
      });

      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        //call function to check if un is unique
        final unique = await context.read<UserAuthProvider>().uniqueEmail(
          _email,
        );

        if (!unique) {
          setState(() {
            // if un is not unique display unError
            _emailError = "Sorry, that email is already taken.";
          });
          return;
        }
        newUser.email = _email;
        // if valid (has value and unique) then proceed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SecondPage(newUser: newUser)),
        );
      }
    },
    style: buttonStyle(),
    child: buttonText("Next"),
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

  Widget get title => header("Enter your email");
  Widget get emailLabel => label("Email");
  Widget get sub => subHeading("No one will see this on your profile");
}
