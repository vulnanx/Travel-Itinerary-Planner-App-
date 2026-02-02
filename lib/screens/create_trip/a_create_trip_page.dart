import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/create_trip/b_create_itinerary_page.dart';
import 'package:project23/screens/sign_up/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '/models/plans_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateTripPage extends StatefulWidget {
  final String title;
  final bool editable;
  final Plans? edited;

  const CreateTripPage({
    super.key,
    required this.title,
    required this.editable,
    this.edited,
  });

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String selectedCategory = 'Vacation';
  DateTime? _selectedDate;
  DateTime now = DateTime.now();
  int _tripDays = 1;
  List<String> results = [];

  Future<void> searchPlaces(String query) async {
    var token = dotenv.env["MAPBOX_TOKEN"]!;
    var session = Uuid().v4();
    // calls the mapbox api and converts the obtained json responses to a list of strings
    final url = Uri.parse(
      'https://api.mapbox.com/search/searchbox/v1/suggest?q=$query&session_token=$session&access_token=$token',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      List<String> temp = [];
      for (int i = 0; i < data['suggestions'].length; i++) {
        if (!temp.contains(data['suggestions'][i]['name'])) {
          temp.add(data['suggestions'][i]['name']);
        }
      }
      results = temp;

      // Handle search results here
      // print(data);
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  // Categories list
  final List<String> categories = [
    'Vacation',
    'Business',
    'Adventure',
    'Family',
    'Solo',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // for editing, set the selected values to the current values
    if (widget.edited != null) {
      selectedCategory = widget.edited!.category!;
      _nameController.text = widget.edited!.name!;
      _descriptionController.text = widget.edited!.description!;
      _locationController.text = widget.edited!.genlocation!;
      _tripDays = widget.edited!.tripDuration!;
      _selectedDate = widget.edited!.date;
    }
  }

  selectedDay() {
    int tempVal = _tripDays;
    return showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color.fromARGB(255, 245, 250, 255),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    return NumberPicker(
                      selectedTextStyle: GoogleFonts.kumbhSans(
                        color: Color.fromARGB(255, 19, 19, 19),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      textStyle: GoogleFonts.kumbhSans(
                        color: Color.fromARGB(255, 80, 80, 80),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      axis: Axis.vertical,
                      minValue: 1,
                      maxValue: 30,
                      value: tempVal,
                      onChanged: (value) => setState(() => tempVal = value),
                    );
                  },
                ),

                const Divider(
                  height: 20,
                  thickness: 5,
                  endIndent: 0,
                  color: Color.fromARGB(255, 196, 199, 204),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _tripDays = tempVal;
                    });

                    Navigator.pop(context);
                  },
                  horizontalTitleGap: 0,
                  title: Center(
                    child: Text(
                      "Confirm",
                      style: GoogleFonts.kumbhSans(
                        color: Color.fromARGB(255, 19, 19, 19),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  thickness: 0.5,

                  color: Color.fromARGB(255, 196, 199, 204),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  horizontalTitleGap: 0,
                  title: Center(
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.kumbhSans(
                        color: Color.fromARGB(255, 19, 19, 19),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // date & time picker -----------------------------------------------------------------
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(now.year),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate?.hour ?? now.hour,
          _selectedDate?.minute ?? now.minute,
        );
      });
    }
  }

  //validator
  bool _validateInputs() {
    return _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _selectedDate != null;
  }

  Plans tempTrip = Plans();

  choices() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color.fromARGB(255, 245, 250, 255),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < categories.length; i++)
                  Column(
                    children: [
                      ListTile(
                        minTileHeight: 45,
                        onTap: () {
                          setState(() {
                            selectedCategory = categories[i];
                          });
                          Navigator.pop(context);
                        },
                        horizontalTitleGap: 0,
                        title: Center(
                          child: Text(
                            categories[i],
                            maxLines: 2,
                            style: GoogleFonts.kumbhSans(
                              color: Color.fromARGB(255, 19, 19, 19),
                              fontSize: 16,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      i != categories.length - 1
                          ? const Divider(
                            thickness: 0.5,
                            color: Color.fromARGB(255, 196, 199, 204),
                          )
                          : const Divider(
                            height: 20,
                            thickness: 5,
                            endIndent: 0,
                            color: Color.fromARGB(255, 196, 199, 204),
                          ),
                    ],
                  ),

                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  horizontalTitleGap: 0,
                  title: Center(
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.kumbhSans(
                        color: Color.fromARGB(255, 19, 19, 19),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomButton(),
      appBar:
          widget.editable
              ? AppbarWidget(title: 'Edit Travel Plan')
              : AppbarWidget(title: 'Create Travel Plan'),
      backgroundColor: Color.fromARGB(255, 245, 250, 255),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Name
              TextField(
                style: GoogleFonts.kumbhSans(
                  color: Color(0xFF254268),
                  fontSize: 16,
                  height: 2,
                ),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Trip Name',
                  labelStyle: GoogleFonts.kumbhSans(
                    color: Color(0xFF254268),
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(12)),

              InkWell(
                onTap: () {
                  choices();
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                    labelText: 'Category',
                    labelStyle: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                    ),
                  ),
                  child: Text(
                    selectedCategory,
                    style: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                      height: 2,
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.all(12)),

              Autocomplete<String>(
                onSelected: (option) {
                  _locationController.text = option;
                },
                optionsBuilder: (textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return results;
                },
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  return TextField(
                    focusNode: focusNode,
                    onChanged: (value) {
                      searchPlaces(value);
                      _locationController.text = textEditingController.text;
                    },
                    style: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                      height: 2,
                    ),
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: GoogleFonts.kumbhSans(
                        color: Color(0xFF254268),
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),

              // Trip Location
              Padding(padding: EdgeInsets.all(12)),

              // Date and Time selection
              InkWell(
                onTap: () => _pickDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                    labelText: 'Date',
                    labelStyle: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                    ),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select a date'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                    style: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                      height: 2,
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.all(12)),
              InkWell(
                onTap: () {
                  selectedDay();
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),

                    labelText: 'Number of days',
                    labelStyle: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                    ),
                  ),
                  child: Text(
                    "$_tripDays",
                    style: GoogleFonts.kumbhSans(
                      color: Color(0xFF254268),
                      fontSize: 16,
                      height: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Trip Description
              TextField(
                style: GoogleFonts.kumbhSans(
                  color: Color(0xFF254268),
                  fontSize: 16,
                  height: 2,
                ),
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.kumbhSans(
                    color: Color(0xFF254268),
                    fontSize: 16,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomButton() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: ElevatedButton(
        onPressed: () {
          if (!widget.editable) {
            if (!_validateInputs()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all fields')),
              );
            } else {
              // temporary trip object, data here will be passed to next page
              tempTrip.name = _nameController.text;
              tempTrip.description = _descriptionController.text;
              tempTrip.category = selectedCategory;
              tempTrip.date = _selectedDate!;
              tempTrip.genlocation = _locationController.text;
              tempTrip.tripDuration = _tripDays;
              tempTrip.userId = getCurrentUserId();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CreateItineraryPage(
                        title: '',
                        tempTrip: tempTrip,
                        editable: false,
                      ),
                ),
              );
            }
          }

          if (!_validateInputs()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill in all fields or edit the fields'),
              ),
            );
          } else {
            if ((_nameController.text == widget.edited!.name &&
                _descriptionController.text == widget.edited!.description &&
                _locationController.text == widget.edited!.genlocation &&
                selectedCategory == widget.edited!.category &&
                _selectedDate == widget.edited!.date &&
                _tripDays == widget.edited!.tripDuration)) {
              Navigator.pop(context);
            } else {
              // temporary trip object, data here will be passed to next page
              widget.edited!.name = _nameController.text;
              widget.edited!.description = _descriptionController.text;
              widget.edited!.category = selectedCategory;
              widget.edited!.date = _selectedDate!;
              widget.edited!.genlocation = _locationController.text;
              widget.edited!.tripDuration = _tripDays;

              context.read<TripListProvider>().editPlan(
                widget.edited!.id!,
                widget.edited as Plans,
              );

              // updates itinerary dates
              for (int j = 0; j < widget.edited!.itinerary!.length; j++) {
                widget.edited!.itinerary![j]['time'] = DateTime(
                  widget.edited!.date!
                      .add(
                        Duration(days: widget.edited!.itinerary![j]['day'] - 1),
                      )
                      .year,
                  widget.edited!.date!
                      .add(
                        (Duration(
                          days: widget.edited!.itinerary![j]['day'] - 1,
                        )),
                      )
                      .month,
                  widget.edited!.date!
                      .add(
                        Duration(days: widget.edited!.itinerary![j]['day'] - 1),
                      )
                      .day,
                  widget.edited!.itinerary![j]['time']!.hour,
                  widget.edited!.itinerary![j]['time']!.minute,
                );
              }
              Navigator.pop(context);
            }
          }
        },
        style: buttonStyle(),
        child:
            widget.editable
                ? (((_nameController.text == widget.edited!.name &&
                        _descriptionController.text ==
                            widget.edited!.description &&
                        _locationController.text ==
                            widget.edited!.genlocation &&
                        selectedCategory == widget.edited!.category &&
                        _selectedDate == widget.edited!.date &&
                        _tripDays == widget.edited!.tripDuration))
                    ? buttonText("Back")
                    : buttonText("Save"))
                : buttonText("Next: Add Itinerary"),
      ),
    );
  }
}

String getCurrentUserId() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid ?? '';
}
