import 'package:flutter/material.dart';
import 'e_interests.dart';
import '../../models/user_model.dart';
import '../../common/appbar.dart';
import 'signup_page.dart';

class FourthPage extends StatefulWidget {
  final Account newUser;

  const FourthPage({super.key, required this.newUser});

  @override
  State<FourthPage> createState() => _SignUpState();
}

class _SignUpState extends State<FourthPage> {
  final _formKey = GlobalKey<FormState>();

  // fields to store inputs

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
                  children: [fLabel],
                ),
                firstNameField,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [lLabel],
                ),
                lastNameField,
                SizedBox(width: double.infinity, child: next),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // field widgets

  Widget get firstNameField => buildTextField(
    label: "First Name",
    hint: "Enter your first name",
    onSaved: (value) => widget.newUser.firstName = value,
    init: widget.newUser.firstName,
    validatorMsg: "Please enter your first name",
  );

  Widget get lastNameField => buildTextField(
    label: "Last Name",
    hint: "Enter your last name",
    onSaved: (value) => widget.newUser.lastName = value,
    init: widget.newUser.lastName,
    validatorMsg: "Please enter your last name",
  );

  Widget get next => nextButton(
    FifthPage(newUser: widget.newUser, isGoogle: false),
    _formKey,
    context,
  );
  Widget get title => header("What’s Your name?");
  Widget get sub => subHeading("Please enter the name you use in real life");
  Widget get fLabel => label("First name");
  Widget get lLabel => label("Last name");
}
