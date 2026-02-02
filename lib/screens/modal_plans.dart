import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plans_model.dart';
import '../providers/plans_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripModal extends StatefulWidget {
  final String type;
  final Plans? item;

  const TripModal({super.key, required this.type, this.item});

  @override
  _PlansModalState createState() => _PlansModalState();
}

class _PlansModalState extends State<TripModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? selectedCategory;
  DateTime? _selectedDate;
  final List<Map<String, dynamic>> _itinerary = [];

  // categories list modify na lang
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
    if (widget.item != null) {
      selectedCategory = widget.item!.category;
      _nameController.text = widget.item!.name!;
      _descriptionController.text = widget.item!.description!;
      _locationController.text = widget.item!.genlocation!;
      _selectedDate = widget.item!.date;
      _itinerary.addAll(widget.item!.itinerary!);
    }
  }

  //searched and added --------------------------------------
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          _selectedDate != null
              ? TimeOfDay.fromDateTime(_selectedDate!)
              : TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate?.year ?? DateTime.now().year,
          _selectedDate?.month ?? DateTime.now().month,
          _selectedDate?.day ?? DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
  //------------------------------------------------------------------------------------------

  // Method to show the name of the modal depending on the functionality
  Text _buildName() {
    switch (widget.type) {
      case 'Add':
        return const Text("Add new plans");
      case 'Edit':
        return const Text("Edit plans");
      case 'Delete':
        return const Text("Delete plans");
      case 'View':
        return const Text("View plans");

      default:
        return const Text("");
    }
  }

  // Method to build the content or body depending on the functionality
  Widget _buildContent(BuildContext context) {
    if (widget.type == 'Delete') {
      return Text(
        "Are you sure you want to delete '${widget.item!.name}'?",
        style: const TextStyle(fontSize: 16),
      );
    }
    // view selected plans
    if (widget.type == 'View') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${widget.item!.name}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Description: ${widget.item!.description}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${widget.item!.category}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Location: ${widget.item!.genlocation}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Date & Time: ${widget.item!.date!.year}-${widget.item!.date!.month.toString().padLeft(2, '0')}-${widget.item!.date!.day.toString().padLeft(2, '0')} ${widget.item!.date!.hour.toString().padLeft(2, '0')}:${widget.item!.date!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      );
    }

    // for edit and add
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                // date
                child: Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () => _pickDate(context),
                child: const Text('Select Date'),
              ),
              const SizedBox(width: 10),
              //time
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'No time selected'
                      : 'Time: ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () => _pickTime(context),
                child: const Text('Select Time'),
              ),
            ],
          ),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Category'),
            value: selectedCategory,
            items:
                categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 12),
          _buildItinerarySection(),
        ],
      ),
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Itinerary:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),

        for (int i = 0; i < _itinerary.length; i++) _buildItineraryItem(i),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Add new blank itinerary item
            setState(() {
              _itinerary.add({
                'activity': '',
                'location': '',
                'time': DateTime.now(),
              });
            });
          },
          child: const Text('Add Itinerary Item'),
        ),
      ],
    );
  }

  Widget _buildItineraryItem(int index) {
    final itineraryItem = _itinerary[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item ${index + 1}:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Activity Name
        TextField(
          decoration: const InputDecoration(labelText: 'Activity Name'),
          onChanged: (value) {
            _itinerary[index]['activity'] = value;
          },
          controller: TextEditingController(text: itineraryItem['activity'])
            ..selection = TextSelection.collapsed(
              offset: itineraryItem['activity'].toString().length,
            ),
        ),

        const SizedBox(height: 8),

        // Location
        TextField(
          decoration: const InputDecoration(labelText: 'Location'),
          onChanged: (value) {
            _itinerary[index]['location'] = value;
          },
          controller: TextEditingController(text: itineraryItem['location'])
            ..selection = TextSelection.collapsed(
              offset: itineraryItem['location'].toString().length,
            ),
        ),

        const SizedBox(height: 8),

        // Date and Time Picker
        Row(
          children: [
            Expanded(
              child: Text(
                itineraryItem['time'] == null
                    ? 'No date and time selected'
                    : 'Date: ${itineraryItem['time'].toString().split(' ')[0]} Time: ${itineraryItem['time'].toString().split(' ')[1].split('.')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Pick Date
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: itineraryItem['time'] ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  // Pick Time
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      itineraryItem['time'] ?? DateTime.now(),
                    ),
                  );

                  if (pickedTime != null) {
                    // Combine selected date and time into one DateTime object
                    setState(() {
                      _itinerary[index]['time'] = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: const Text('Pick Date & Time'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Remove Item Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _itinerary.removeAt(index);
            });
          },
          child: const Text('Remove Item'),
        ),

        const Divider(thickness: 1),
      ],
    );
  }

  // handle form submission and validate inputs
  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        selectedCategory == null ||
        _selectedDate == null) {
      return false; //  failed
    }
    return true; // passed
  }

  Widget _dialogAction(BuildContext context) {
    //for delete, para hindi na mag show lahat ng values
    if (widget.type == 'Delete') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TripListProvider>().deletePlan(widget.item!.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 161, 35, 26),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text("Delete"),
          ),
        ],
      );
    }

    //for viewing ng selected exoense
    if (widget.type == 'View') {
      return TextButton(
        onPressed: () => Navigator.of(context).pop(), // Back button
        child: const Text("Back"),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (!_validateInputs()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields.')),
            );
            return;
          }
          // print("Location: ${_locationController.text}");

          // for (var i = 0; i < _itinerary.length; i++) {
          //   var item = _itinerary[i];
          //   print("Itinerary ${i + 1}:");
          //   print("  act: ${item['activity']}");
          //   print("  Location: ${item['location']}");
          //   print("  Time: ${item['time']}");
          // }

          String userId =
              FirebaseAuth.instance.currentUser!.uid; // Get  current users UID

          switch (widget.type) {
            case 'Add':
              Plans temp = Plans(
                name: _nameController.text,
                description: _descriptionController.text,
                category: selectedCategory!,
                date: _selectedDate!,
                userId: userId,
                genlocation: _locationController.text,
                itinerary: _itinerary,
              );
              context.read<TripListProvider>().addPlan(temp);
              //print("Itinerary being sent: ${temp.itinerary}"); // For Add

              break;

            case 'Edit':
              Plans updated = Plans(
                id: widget.item!.id,
                name: _nameController.text,
                description: _descriptionController.text,
                category: selectedCategory!,
                date: _selectedDate!,
                userId: widget.item!.userId, //keep lang din
                genlocation: _locationController.text,
              );

              context.read<TripListProvider>().editPlan(
                widget.item!.id!,
                updated,
              );
              break;

            case 'Delete':
              context.read<TripListProvider>().deletePlan(widget.item!.id!);
              break;
          }

          Navigator.of(context).pop();
        },
        //button for adding
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 92, 14, 108),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(widget.type == 'Add' ? 'Add Plan' : widget.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildName(),
      content: _buildContent(context),
      actions: <Widget>[_dialogAction(context)],
    );
  }
}
