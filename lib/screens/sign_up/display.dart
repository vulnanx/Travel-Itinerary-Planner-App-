import 'package:flutter/material.dart';
import 'package:project23/providers/users_provider.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../common/appbar.dart';
import '../../providers/auth_provider.dart';

class Display extends StatefulWidget {
  final Account newUser;

  const Display({super.key, required this.newUser});

  @override
  State<Display> createState() => _SignUpState();
}

class _SignUpState extends State<Display> {
  final _formKey = GlobalKey<FormState>();

  // fields to store inputs
  String? username;

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
                Text(
                  "${widget.newUser.email}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${widget.newUser.username}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${widget.newUser.firstName}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${widget.newUser.lastName}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${widget.newUser.interestsList}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${widget.newUser.travelStylesList}",
                  style: TextStyle(color: Colors.white),
                ),
                submitButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get submitButton => ElevatedButton(
    onPressed: () async {
      await context.read<UserAuthProvider>().authService.signUp(widget.newUser);
      await context.read<UserListProvider>().fetchSuggestedTravelers();

      if (mounted)
        Navigator.popUntil(context, ModalRoute.withName('/landingpage'));
    },

    child: const Text("Sign Up"),
  );
}
