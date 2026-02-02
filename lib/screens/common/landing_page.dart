import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../signin_page.dart';

import '../sign_up/a_email.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  String? email;
  String? password;
  bool showSignInErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    // para to sa responsiveness sa padding
    double h = MediaQuery.of(context).size.height;

    // TODO improve upon responsiveness code
    return Scaffold(
      extendBody: true,
      backgroundColor: Color.fromARGB(255, 1, 31, 75),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        height: 166,
        child: Column(
          children: [
            SizedBox(width: double.infinity, child: registerButton),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0.005 * h, 0, 0.05 * h),
              child: SizedBox(width: double.infinity, child: loginButton),
            ),
          ],
        ),
      ),
      body: Container(
        // alignment: Alignment.center,
        height: double.maxFinite,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/logo.png', scale: 2.25),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0.02 * h, 0, 0),
                      child: Center(child: splashText),
                    ),
                  ],
                ),
                SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get registerButton => ElevatedButton(
    onPressed: () async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FirstPage()),
      );
    },
    child: Text(
      "Register",
      style: GoogleFonts.kumbhSans(
        fontSize: 18,
        color: Color.fromARGB(255, 1, 31, 75),
      ),
    ),
  );

  Widget get splashText => Column(
    children: [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'WELCOME TO\n TRIP ',
          style: GoogleFonts.kronaOne(
            color: const Color(0xFFecf7ff),
            fontSize: 36,
            height: 1,
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'PALS',
              style: GoogleFonts.kronaOne(
                color: Color(0xFF8BC6F1),
                fontSize: 36,
                height: 1,
              ),
            ),
          ],
        ),
      ),

      Padding(padding: EdgeInsets.all(1.5)),
      Text(
        textAlign: TextAlign.center,
        "Plan your trip & Make new Pals.\n Tap below to get started!",
        style: GoogleFonts.kumbhSans(
          height: 1.1,
          fontSize: 16,
          color: Color.fromARGB(255, 236, 247, 255),
        ),
      ),
    ],
  );

  Widget get loginButton => ElevatedButton(
    onPressed: () async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 179, 205, 224),
    ),
    child: Text(
      "Log In",
      style: GoogleFonts.kumbhSans(
        fontSize: 18,
        color: Color.fromARGB(255, 1, 31, 75),
      ),
    ),
  );
}
