import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'd_name.dart';
import '../../models/user_model.dart';
import '../../common/appbar.dart';
import 'signup_page.dart';

class ThirdPage extends StatefulWidget {
  final Account newUser;

  const ThirdPage({super.key, required this.newUser});

  @override
  State<ThirdPage> createState() => _SignUpState();
}

class _SignUpState extends State<ThirdPage> {
  final _formKey = GlobalKey<FormState>();

  String? _username;
  String? _usernameError; // unique check error

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
                  children: [tLabel],
                ),
                usernameField,
                SizedBox(width: double.infinity, child: next),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // field widgets

  Widget get usernameField => buildTextField(
    label: "Username",
    hint: "Choose a username",
    onSaved: (value) {
      _username = value;
      widget.newUser.username = value!.toLowerCase();
    },
    validatorMsg: "Please enter a username",
    init: widget.newUser.username,
    errorMsg: _usernameError,
  );

  Widget get next => ElevatedButton(
    onPressed: () async {
      // reset any previous error message muna
      setState(() {
        _usernameError = null;
      });

      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        //call function to check if un is unique
        final unique = await context.read<UserAuthProvider>().uniqueEmail(
          _username,
        );

        if (!unique) {
          setState(() {
            // if un is not unique display unError
            _usernameError = "Sorry, that username is already taken.";
          });
          return;
        }

        // if valid (has value and unique) then proceed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FourthPage(newUser: widget.newUser),
          ),
        );
      }
    },
    style: buttonStyle(),
    child: buttonText("Next"),
  );
  Widget get title => header("We’ll Call you?");
  Widget get sub => subHeading("What do you want to be called?");
  Widget get tLabel => label("Username");
}
