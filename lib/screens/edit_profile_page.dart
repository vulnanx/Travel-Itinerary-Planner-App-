import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/models/user_model.dart';
import 'package:project23/providers/auth_provider.dart';
import 'package:project23/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'
    show ImagePicker, ImageSource, XFile;

// ignore: must_be_immutable
class EditProfilePage extends StatefulWidget {
  final String title;
  const EditProfilePage({super.key, required this.title});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  final _travelStylesList = [
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

  PermissionStatus permissionStatus = PermissionStatus.granted;
  late Permission permission;
  File? imageFile;

  late Account
  account; // duplicate; being editted but not yet saved unless called
  Uint8List? picture;
  final authProvider = UserAuthProvider();

  @override
  void initState() {
    super.initState();
    authProvider.account.first
        .then((acc) async {
          setState(() {
            account = acc;
          });

          if (account.profileURL != null && account.profileURL!.isNotEmpty) {
            try {
              setState(() {
                picture = base64Decode(
                  account.profileURL!,
                ); // decode string into Uint8List
              });
            } catch (e) {
              print("Could not load profile image: $e");
            }
          }
        })
        .catchError((e) {
          print("Error loading account: $e");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: 'Edit Profile Page'),
      backgroundColor: Color(0xFFE0EEFF),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFE0EEFF),
          child: Stack(
            children: [
              blueCircleDesign,
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [SizedBox(height: 60), editProfileForm],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get editProfileForm => Form(
    key: formKey,
    child: Column(
      children: [
        editProfilePic(account),
        SizedBox(height: 10),
        editInfo,
        SizedBox(height: 30),
        saveButton(account),
        SizedBox(height: 60),
      ],
    ),
  );

  get editInfo => Container(
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Color(0xFF9FC4F3),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Column(
          children: [
            infoRow('Account Privacy', setProfilePrivacy(account)),
            infoRow('Username', Text(account.username ?? 'username')),
            infoRow('Email', Text(account.email ?? 'email')),
            infoRow('First Name', firstNameField(account)),
            infoRow('Last Name', lastNameField(account)),
            infoRow('Contact Number', contactNoField(account)),
            SizedBox(height: 20),
            Text(
              'Interests',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
              ),
            ),
            SizedBox(height: 10),
            interestsField(),
            Text(
              'Travel Styles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.kumbhSans().fontFamily,
              ),
            ),
            SizedBox(height: 10),
            travelStylesField(),
          ],
        ),
      ],
    ),
  );

  Widget infoRow(String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: GoogleFonts.kumbhSans().fontFamily,
            ),
          ),
        ),
        SizedBox(width: 30),
        Expanded(child: value),
      ],
    ),
  );

  Widget firstNameField(Account account) => TextFormField(
    initialValue: account.firstName,
    onSaved: (value) => account.firstName = value,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please enter a first name";
      }
      return null;
    },
    style: GoogleFonts.kumbhSans(color: const Color(0xFF011f4b), fontSize: 16),
  );

  Widget lastNameField(Account account) => TextFormField(
    initialValue: account.lastName,
    onSaved: (value) => account.lastName = value,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please enter a last name";
      }
      return null;
    },
    style: GoogleFonts.kumbhSans(color: const Color(0xFF011f4b), fontSize: 16),
  );

  Widget contactNoField(Account account) => TextFormField(
    initialValue: account.contactno,
    onSaved: (value) => account.contactno = value,
    validator: (value) {
      String pattern = r'^(?:[+0][1-9])?[0-9]{10,12}$';
      RegExp regExp = RegExp(pattern);
      if (value!.isNotEmpty && !regExp.hasMatch(value)) {
        return "Please enter a valid contact number (09xxxxxxxxx)";
      }
      return null;
    },
    style: GoogleFonts.kumbhSans(color: const Color(0xFF011f4b), fontSize: 16),
  );

  Widget setProfilePrivacy(Account account) => IconButton(
    onPressed:
        () => {
          setState(() {
            account.public = !(account.public ?? true);
          }),
        },
    icon:
        (account.public ?? true)
            ? Icon(Icons.lock_open_rounded)
            : Icon(Icons.lock_person),
  );

  Widget interestsField() {
    account.interestsList = account.interestsList;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 5,
          children:
              _interests
                  .map(
                    (e) => ChoiceChip(
                      disabledColor: Color(0xFFecf7ff),
                      showCheckmark: false,
                      selectedColor: Color(0xFF254268),
                      label: SizedBox(
                        width: 76,
                        child: Text(
                          textAlign: TextAlign.center,
                          e,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kumbhSans(
                            color:
                                account.interestsList!.contains(e)
                                    ? Colors.white
                                    : Color(0xFF011f4b),
                            height: 1,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      selected: account.interestsList!.contains(e),
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            if (!account.interestsList!.contains(e)) {
                              account.interestsList?.add(e);
                            }
                          } else {
                            account.interestsList?.remove(e);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
        Padding(padding: EdgeInsets.all(12)),
      ],
    );
  }

  Widget travelStylesField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 5,
          children:
              _travelStylesList
                  .map(
                    (e) => ChoiceChip(
                      disabledColor: Color(0xFFecf7ff),
                      showCheckmark: false,
                      selectedColor: Color(0xFF254268),
                      label: SizedBox(
                        width: 76,
                        child: Text(
                          textAlign: TextAlign.center,
                          e,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kumbhSans(
                            color:
                                account.travelStylesList!.contains(e)
                                    ? Colors.white
                                    : Color(0xFF011f4b),
                            height: 1,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      selected: account.travelStylesList!.contains(e),
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            if (!account.travelStylesList!.contains(e)) {
                              account.travelStylesList!.add(e);
                            }
                          } else {
                            account.travelStylesList!.remove(e);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
        Padding(padding: EdgeInsets.all(12)),
      ],
    );
  }

  Widget get blueCircleDesign => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Color(0xFF254268), // Dark blue top section
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(130),
        bottomRight: Radius.circular(130),
      ),
    ),
  );

  Widget saveButton(Account account) => ElevatedButton.icon(
    onPressed: () async {
      final form = formKey.currentState;
      if (form != null && form.validate()) {
        form.save();
        //account.interestsList = interestsList;
        //account.travelStylesList = travelStylesList;
        try {
          await context.read<UserAuthProvider>().updateAccount(account);
          await context.read<UserListProvider>().fetchSuggestedTravelers();

          Navigator.popUntil(context, ModalRoute.withName('/landingpage'));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
        }
      }
    },
    icon: Icon(Icons.check_rounded),
    label: Text(
      "save changes",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.kumbhSans().fontFamily,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF254268),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  );

  void _listenForPermissionStatus() async {
    final status = await permission.status;
    setState(() => permissionStatus = status);
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////

  Widget editProfilePic(Account? account) {
    return GestureDetector(
      onTap: () async {
        _listenForPermissionStatus();
        final picker = ImagePicker();
        final source = await showDialog<ImageSource>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Select Image Source'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                    child: Text('Camera'),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.pop(context, ImageSource.gallery),
                    child: Text('Gallery'),
                  ),
                ],
              ),
        );

        if (source == null) return;
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 50,
        ); // reduce the size of the image less than 1MB
        if (image == null) return;

        final Uint8List imageBytes = await image.readAsBytes();

        setState(() {
          picture = imageBytes;
          account?.profileURL = base64Encode(imageBytes);
        });
      },
      child: ClipOval(
        child:
            picture != null
                ? Image.memory(
                  picture!,
                  fit: BoxFit.cover,
                  width: 200,
                  height: 200,
                )
                : Image.asset(
                  'assets/images/profilepic.png',
                  fit: BoxFit.cover,
                  width: 200,
                  height: 200,
                ),
      ),
    );
  }
}
