import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../common/appbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/users_provider.dart';
import 'display.dart';
import 'signup_page.dart';

class SixthPage extends StatefulWidget {
  final Account newUser;
  final bool isGoogle;
  const SixthPage({super.key, required this.newUser, required this.isGoogle});

  @override
  State<SixthPage> createState() => _SignUpState();
}

class _SignUpState extends State<SixthPage> {
  final _formKey = GlobalKey<FormState>();

  final _interests = [
    "Luxury",
    "Backpacking",
    "Nature",
    "Beach",
    "Relaxation",
    "City",
    "Exploration",
    "Volunteer",
    "Cultural",
    "Cruise",
    "Movies",
  ];

  late List<String> selection;
  @override
  void initState() {
    super.initState();
    selection = widget.newUser.travelStylesList ?? [];
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: submitButton,

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
                title,
                Padding(padding: EdgeInsets.all(4)),
                sub,
                Padding(padding: EdgeInsets.all(12)),
                Wrap(
                  spacing: 5,
                  children:
                      _interests
                          .map(
                            (e) => FilterChip(
                              disabledColor: Color(0xFFecf7ff),
                              showCheckmark: false,
                              selectedColor: Color(0xFF8bc6f1),
                              label: SizedBox(
                                width: w / 6,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  e,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.kumbhSans(
                                    color: Color(0xFF011f4b),
                                    height: 1,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              selected: selection.contains(e),
                              onSelected: (bool value) {
                                setState(() {
                                  if (value) {
                                    selection.add(e);
                                  } else {
                                    selection.remove(e);
                                  }
                                  widget.newUser.travelStylesList = selection;
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
                Padding(padding: EdgeInsets.all(12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get submitButton => BottomAppBar(
    color: Colors.transparent,
    elevation: 0,
    height: 70,
    child: ElevatedButton(
      style: buttonStyle(),

      onPressed: () async {
        if (!widget.isGoogle) {
          await context.read<UserAuthProvider>().authService.signUp(
            widget.newUser,
          );
          await context.read<UserListProvider>().fetchSuggestedTravelers();

          if (mounted)
            Navigator.popUntil(context, ModalRoute.withName('/landingpage'));
        } else {
          await context.read<UserAuthProvider>().updateAccount(widget.newUser);
          await context.read<UserListProvider>().fetchSuggestedTravelers();
          if (mounted)
            Navigator.popUntil(context, ModalRoute.withName('/landingpage'));
        }
      },

      child:
          widget.isGoogle
              ? buttonText("Update Profile")
              : buttonText("Sign Up"),
    ),
  );

  Widget get next =>
      bottomButton(Display(newUser: widget.newUser), _formKey, context);
  Widget get title => header("Select your travel styles");
  Widget get sub => subHeading(
    "We’ll use them to match with other users\n based on common interests",
  );
}
