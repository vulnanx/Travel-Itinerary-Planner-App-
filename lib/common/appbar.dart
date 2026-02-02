import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? showBackButton; // default = true
  final bool? centerTitle; // default = true
  final Widget? trailing;
  final bool? leading;

  const AppbarWidget({
    super.key,
    required this.title,
    this.showBackButton,
    this.trailing,
    this.centerTitle,
    this.leading,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  //TODO make the app bar reusable not just for account creation!
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: leading ?? true,
      centerTitle: centerTitle ?? true,
      title:
          title == "trippals"
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 28),
                  const SizedBox(width: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'TRIP',
                      style: GoogleFonts.kronaOne(
                        color: const Color(0xFFecf7ff),
                        fontSize: 20,
                        height: 1,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'PALS',
                          style: GoogleFonts.kronaOne(
                            color: Color(0xFF8BC6F1),
                            fontSize: 20,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Text(
                textAlign: TextAlign.center,
                title,
                style: GoogleFonts.kumbhSans(
                  color: const Color(0xFFecf7ff),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
      leading:
          showBackButton ?? true
              ? InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, color: Color(0xFFecf7ff)),
              )
              : null,
      actions: trailing != null ? [trailing!] : null,
      backgroundColor: Color.fromARGB(255, 1, 31, 75),
    );
  }
}
