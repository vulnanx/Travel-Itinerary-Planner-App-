import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? showBackButton; // default = true
  final bool? centerTitle; // default = true
  final Widget? trailing;

  const MainAppBar({super.key, required this.title, this.showBackButton, this.trailing, this.centerTitle});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  //TODO make the app bar reusable not just for account creation!
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png', height: 28),
          const SizedBox(width: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'TRIP',
              style: GoogleFonts.kronaOne(
                color: const Color(0xFFecf7ff),
                fontSize: 30,
                height: 1,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'PALS',
                  style: GoogleFonts.kronaOne(
                    color: Color(0xFF8BC6F1),
                    fontSize: 30,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Color.fromARGB(255, 1, 31, 75),
    );
  }
}
