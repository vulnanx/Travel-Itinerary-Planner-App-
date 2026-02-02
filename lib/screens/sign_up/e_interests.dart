import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'f_travel_styles.dart';
import '../../models/user_model.dart';
import '../../common/appbar.dart';
import 'signup_page.dart';

class FifthPage extends StatefulWidget {
  final Account newUser;
  final bool isGoogle;

  const FifthPage({super.key, required this.newUser, required this.isGoogle});

  @override
  State<FifthPage> createState() => _SignUpState();
}

class _SignUpState extends State<FifthPage> {
  final _formKey = GlobalKey<FormState>();

  final _interests = [
    "Music",
    "Gaming",
    "Design",
    "Food",
    "Fitness",
    "Reading",
    "Movies",
    "Technology",
    "Nature",
    "Language",
    "Pets",
    "Adventure",
    "Beauty",
    "Dancing",
    "Singing",
    "Cosplay",
    "Gardening",
    "Fashion",
    "Television",
    "Photography",
    "Ideas",
    "Culture",
    "Environment",
    "Economics",
  ];
  late List<String> selection;
  @override
  void initState() {
    super.initState();
    selection = widget.newUser.interestsList ?? [];
  }

  // fields to store inputs

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 75),
      appBar: AppbarWidget(title: 'Create Account', leading: !widget.isGoogle),
      bottomNavigationBar: next,
      body: SingleChildScrollView(
        child: Center(
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
                              (e) => ChoiceChip(
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
                                    widget.newUser.interestsList = selection;
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
      ),
    );
  }

  Widget get next => bottomButton(
    SixthPage(newUser: widget.newUser, isGoogle: widget.isGoogle),
    _formKey,
    context,
  );
  Widget get title =>
      widget.isGoogle
          ? header("Complete your account, Select your interests")
          : header("Select your interests");
  Widget get sub => subHeading(
    "We’ll use them to match with other users\n based on common interests",
  );
}
