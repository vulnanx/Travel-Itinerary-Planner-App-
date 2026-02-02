import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project23/common/appbar.dart';
import 'package:project23/providers/plans_provider.dart';
import 'package:project23/screens/create_trip/c_confirm_trip_page.dart';
import 'package:project23/screens/sign_up/signup_page.dart';
import 'package:provider/provider.dart';

import '../../models/plans_model.dart';

class CreateItineraryPage extends StatefulWidget {
  const CreateItineraryPage({
    super.key,
    required this.title,
    required this.tempTrip,
    required this.editable,
  });
  final bool editable;
  final String title;
  final Plans tempTrip;

  @override
  State<CreateItineraryPage> createState() => _CreateItineraryPageState();
}

class _CreateItineraryPageState extends State<CreateItineraryPage> {
  final List<Map<String, dynamic>> _itinerary = [];
  Plans temp = Plans();
  late final int days;
  bool isEdited = false;
  int selected = 1;
  @override
  void initState() {
    super.initState();

    if (widget.tempTrip.itinerary != null) {
      _itinerary.addAll(widget.tempTrip.itinerary!);
    }

    days = widget.tempTrip.tripDuration ?? 1;

    // automatically updates the date when the user changes the date
    for (int j = 0; j < _itinerary.length; j++) {
      _itinerary[j]['time'] = DateTime(
        widget.tempTrip.date!
            .add(Duration(days: _itinerary[j]['day'] - 1))
            .year,
        widget.tempTrip.date!
            .add((Duration(days: _itinerary[j]['day'] - 1)))
            .month,
        widget.tempTrip.date!.add(Duration(days: _itinerary[j]['day'] - 1)).day,
        _itinerary[j]['time'].hour,
        _itinerary[j]['time'].minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomButton(),
      appBar: AppbarWidget(title: 'Create an Itinerary'),
      backgroundColor: Color(0xFFE0EEFF),
      body:
          _itinerary.any((mapTested) => mapTested['day'] == selected)
              ? Column(
                children: [
                  Padding(padding: EdgeInsets.only(left: 12), child: dates()),

                  SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(20),
                            height: 100,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add new blank itinerary item
                                setState(() {
                                  _itinerary.add({
                                    'day': selected,
                                    'activity': '',
                                    'location': '',
                                    'time': addDate(),
                                  });
                                });
                                if (!widget.editable) {
                                  widget.tempTrip.itinerary = _itinerary;
                                } else {
                                  temp.itinerary = _itinerary;
                                  isEdited = true;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xFFecf7ff),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Color(0xFF011f4b),
                                      size: 48,
                                    ),

                                    buttonText("Add an Activity"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildItinerarySection(),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    dates(),
                    Container(
                      margin: EdgeInsets.all(20),
                      height: 100,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add new blank itinerary item
                          setState(() {
                            _itinerary.add({
                              'day': selected,
                              'activity': '',
                              'location': '',
                              'time': addDate(),
                            });
                          });
                          if (!widget.editable) {
                            widget.tempTrip.itinerary = _itinerary;
                          } else {
                            temp.itinerary = _itinerary;
                            isEdited = true;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFecf7ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Color(0xFF011f4b),
                                size: 48,
                              ),

                              buttonText("Add an Activity"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget dates() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 1; i <= days; i++)
            Padding(
              padding: EdgeInsets.all(4),
              child: FilterChip(
                disabledColor: Color(0xFFecf7ff),
                showCheckmark: false,
                selectedColor: Color(0xFF8bc6f1),
                label: Text(
                  "Day $i",
                  style: GoogleFonts.kumbhSans(
                    color: Color(0xFF011f4b),
                    height: 1,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                selected: (selected == i) ? true : false,
                onSelected: (bool value) {
                  setState(() {
                    selected = i;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget bottomButton() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: ElevatedButton(
        onPressed: () {
          _itinerary.sort((a, b) {
            var r = a["day"].compareTo(b["day"]);
            if (r != 0) return r;
            return b["day"].compareTo(a["day"]);
          });

          if (widget.editable) {
            Navigator.pop(context);
            widget.tempTrip.itinerary = _itinerary;
            context.read<TripListProvider>().editPlan(
              widget.tempTrip.id!,
              widget.tempTrip,
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ConfirmTripPage(title: '', tempTrip: widget.tempTrip),
              ),
            );
          }
        },
        style: buttonStyle(),
        child:
            widget.editable
                ? (isEdited ? buttonText("Save") : buttonText("Back"))
                : (_itinerary.isEmpty
                    ? buttonText("Skip")
                    : buttonText("Next")),
      ),
    );
  }

  void updateTiles(int oldI, int newI) {
    setState(() {
      if (oldI < newI) {
        newI--;
      }

      final tile = _itinerary.removeAt(oldI);

      _itinerary.insert(newI, tile);
    });
  }

  Widget _buildItinerarySection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ReorderableListView(
            shrinkWrap: true,
            children: [
              for (int i = 0; i < _itinerary.length; i++) ...[
                if (_itinerary[i]['day'] == selected)
                  Container(
                    height: 80,
                    key: ValueKey(i),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 245, 250, 255),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        CupertinoIcons.line_horizontal_3,
                        color: Color.fromARGB(255, 144, 167, 198),
                      ),
                      trailing: IconButton(
                        onPressed:
                            () => {
                              setState(() {
                                _itinerary.removeAt(i);
                                if (!widget.editable) {
                                  widget.tempTrip.itinerary = _itinerary;
                                } else {
                                  temp.itinerary = _itinerary;
                                  isEdited = true;
                                }
                              }),
                            },
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 144, 167, 198),
                        ),
                      ),
                      title: Text(
                        "${_itinerary[i]['activity'].length == 0 ? "Insert Activity" : _itinerary[i]['activity']} ",
                        style: GoogleFonts.kumbhSans(
                          color: const Color(0xFF254268),
                          fontSize: 16,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${_itinerary[i]['time']!.hour.toString().padLeft(2, '0')}:${_itinerary[i]['time']!.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.kumbhSans(
                          color: const Color.fromARGB(255, 144, 167, 198),
                          fontSize: 16,
                          height: 1,
                        ),
                      ),
                      onTap: () {
                        createItinerary(i);
                      },
                    ),
                  ),
              ],
            ],
            onReorder:
                (oldIndex, newIndex) => (updateTiles(oldIndex, newIndex)),
          ),
        ),

        SizedBox(height: 8),
      ],
    );
  }

  createItinerary(int index) {
    final itineraryItem = _itinerary[index];

    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color.fromARGB(255, 245, 250, 255),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(40, 40, 40, 40),
                child: Column(
                  children: [
                    Text(
                      "Create Itinerary",
                      style: GoogleFonts.kumbhSans(
                        color: Color(0xFF011f4b),
                        height: 1,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      style: GoogleFonts.kumbhSans(
                        color: Color(0xFF254268),
                        fontSize: 16,
                        height: 2,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Activity Name',
                      ),
                      onChanged: (value) {
                        isEdited = true;
                        _itinerary[index]['activity'] = value;
                      },
                      controller: TextEditingController(
                          text: itineraryItem['activity'],
                        )
                        ..selection = TextSelection.collapsed(
                          offset: itineraryItem['activity'].toString().length,
                        ),
                    ),

                    Padding(padding: EdgeInsets.all(8)),

                    // Location
                    TextField(
                      style: GoogleFonts.kumbhSans(
                        color: Color(0xFF254268),
                        fontSize: 16,
                        height: 2,
                      ),
                      decoration: const InputDecoration(labelText: 'Location'),
                      onChanged: (value) {
                        _itinerary[index]['location'] = value;
                      },
                      controller: TextEditingController(
                          text: itineraryItem['location'],
                        )
                        ..selection = TextSelection.collapsed(
                          offset: itineraryItem['location'].toString().length,
                        ),
                    ),

                    Padding(padding: EdgeInsets.all(16)),
                    Row(
                      children: [
                        Expanded(
                          child: Expanded(
                            child: InkWell(
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    _itinerary[index]['time'] ?? addDate(),
                                  ),
                                );

                                setState(() {
                                  isEdited = true;
                                  _itinerary[index]['time'] = DateTime(
                                    widget.tempTrip.date!
                                        .add(Duration(days: selected - 1))
                                        .year,
                                    widget.tempTrip.date!
                                        .add((Duration(days: selected - 1)))
                                        .month,
                                    widget.tempTrip.date!
                                        .add(Duration(days: selected - 1))
                                        .day,
                                    pickedTime!.hour,
                                    pickedTime.minute,
                                  );
                                });
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  labelText: 'Time',
                                  labelStyle: GoogleFonts.kumbhSans(
                                    color: Color(0xFF254268),
                                    fontSize: 16,
                                  ),
                                ),
                                child: Text(
                                  '${_itinerary[index]['time']!.hour.toString().padLeft(2, '0')}:${_itinerary[index]['time']!.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.kumbhSans(
                                    color: Color(0xFF254268),
                                    fontSize: 16,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              const Divider(
                height: 20,
                thickness: 5,
                endIndent: 0,
                color: Color.fromARGB(255, 196, 199, 204),
              ),

              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                horizontalTitleGap: 0,
                title: Center(
                  child: Text(
                    "Close",
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
        );
      },
    );
  }

  // Widget _buildItineraryItem(int index) {
  //   final itineraryItem = _itinerary[index];

  //   return Container(
  //     margin: EdgeInsets.all(30),
  //     child: Column(
  //       children: [
  //         Text(
  //           'Item ${index + 1}:',
  //           style: const TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),

  //         // Activity Name
  //         TextField(
  //           decoration: const InputDecoration(labelText: 'Activity Name'),
  //           onChanged: (value) {
  //             _itinerary[index]['activity'] = value;
  //           },
  //           controller: TextEditingController(text: itineraryItem['activity'])
  //             ..selection = TextSelection.collapsed(
  //               offset: itineraryItem['activity'].toString().length,
  //             ),
  //         ),

  //         Padding(padding: EdgeInsets.all(8)),

  //         // Location
  //         TextField(
  //           decoration: const InputDecoration(labelText: 'Location'),
  //           onChanged: (value) {
  //             _itinerary[index]['location'] = value;
  //           },
  //           controller: TextEditingController(text: itineraryItem['location'])
  //             ..selection = TextSelection.collapsed(
  //               offset: itineraryItem['location'].toString().length,
  //             ),
  //         ),

  //         Padding(padding: EdgeInsets.all(16)),

  //         //Time Picker
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Expanded(
  //                 child: InkWell(
  //                   onTap: () async {
  //                     TimeOfDay? pickedTime = await showTimePicker(
  //                       context: context,
  //                       initialTime: TimeOfDay.fromDateTime(
  //                         itineraryItem['time'] ?? addDate(),
  //                       ),
  //                     );

  //                     setState(() {
  //                       _itinerary[index]['time'] = DateTime(
  //                         widget.tempTrip.date!
  //                             .add(Duration(days: selected - 1))
  //                             .year,
  //                         widget.tempTrip.date!
  //                             .add((Duration(days: selected - 1)))
  //                             .month,
  //                         widget.tempTrip.date!
  //                             .add(Duration(days: selected - 1))
  //                             .day,
  //                         pickedTime!.hour,
  //                         pickedTime.minute,
  //                       );
  //                     });
  //                   },
  //                   child: InputDecorator(
  //                     decoration: const InputDecoration(
  //                       labelText: 'Time',
  //                       border: OutlineInputBorder(),
  //                       prefixIcon: Icon(Icons.timer),
  //                     ),
  //                     child: Text(
  //                       _itinerary[index]['time'] == null
  //                           ? 'Select time'
  //                           : '${_itinerary[index]['time']!.hour.toString().padLeft(2, '0')}:${_itinerary[index]['time']!.minute.toString().padLeft(2, '0')}',
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),

  //         Padding(padding: EdgeInsets.all(12)),

  //         // Remove Item Button
  //         Row(
  //           children: [
  //             Expanded(
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   // Add new blank itinerary item
  //                   setState(() {
  //                     var temp = ({
  //                       'day': selected,
  //                       'activity': '',
  //                       'location': '',
  //                       'time': addDate(),
  //                     });

  //                     _itinerary.insert(index + 1, temp);
  //                   });
  //                 },
  //                 style: buttonStyle(),
  //                 child: buttonText("Add"),
  //               ),
  //             ),
  //             Padding(padding: EdgeInsets.all(10)),
  //             Expanded(
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     _itinerary.removeAt(index);
  //                   });
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Color(0xFF011f4b),
  //                 ),
  //                 child: Text(
  //                   "Remove",
  //                   style: GoogleFonts.kumbhSans(
  //                     color: Color(0xFFecf7ff),
  //                     height: 1,
  //                     fontSize: 18,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  addDate() {
    return DateTime(
      widget.tempTrip.date!.add(Duration(days: selected - 1)).year,
      widget.tempTrip.date!.add((Duration(days: selected - 1))).month,
      widget.tempTrip.date!.add(Duration(days: selected - 1)).day,
    );
  }
}
