import 'package:appointement/features/appointments/widgets/custom_button.dart';
import 'package:appointement/features/appointments/widgets/custom_text_field.dart';
import 'package:appointement/features/reminder/widgets/noti_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _Appointments();
}

class _Appointments extends State<Appointments> {
  final NotiService notiService = NotiService();

  final List<String> meetingTypes = [
    "Business Meeting",
    "Team Meeting",
    "Client Call",
    "Project Discussion",
    "One-on-One",
    "Brainstorming Session",
  ];

  final List<String> locations = [
    "Office building",
    "Apartement",
    "Room"
  ];

  final List<String> categories = [
    "Business",
    "Project",
    "Internship"
  ];

  final List<String> reminderOptions = [
    '1 Day Before',
    '2 Hours Before',
    '30 Minutes Before',
  ];

  final List<String> statusOptions = [
    "Scheduled",
    "In Progress",
    "Completed",
  ];

  String selectedMeetingType = "Business Meeting";
  String selectedLocationType = "Office building";
  String selectedCategorieType = "Business";
  String selectedContact = "";
  String selectedDate = "";
  String selectedTime = "";
  String selectedStatus = "Scheduled";
  String? _reminderPreference;

  // Function to show the time picker
  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.black,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.black54,
              onSurface: Colors.black54,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        // Format the time as HH:MM AM/PM
        selectedTime = pickedTime.format(context);
      });
    }
  }

  // Function to show the calendar and select a date
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.black,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.black54,
              onSurface: Colors.black54,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }


  // Generic method to show a bottom sheet and select an item from a list
  void _showSelectionList(List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(options[index]),
                onTap: () {
                  onSelected(options[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }


  // Function to fetch and display contacts
  Future<void> _selectContact() async {
    if (!await FlutterContacts.requestPermission()) {

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Denied"),
          content: const Text("Please allow access to contacts in settings."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }


    final contacts = await FlutterContacts.getContacts(withProperties: true);


    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text(contact.displayName),
            onTap: () {
              setState(() {
                selectedContact = contact.displayName;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  /*
  Future<void> _selectOnlineContact() async {
    if 
  }
  */

  void saveAppointmentToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      final uuid = Uuid();

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to create an appointment.')));
        return;
      }

      // data to save
      final appointmentData = {
        "id": uuid.v4(),
        "title": selectedMeetingType,
        "meetingType": selectedMeetingType,
        "contact": selectedContact,
        "date": selectedDate,
        "time": selectedTime,
        "location": selectedLocationType,
        "category": selectedCategorieType,
        "status": selectedStatus,
        "createdAt": FieldValue.serverTimestamp(),
        "userId": user.uid,
        'reminderPreference': _reminderPreference,
      };

      await firestore.collection("appointments").add(appointmentData);

      // success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment created successfully!")),
      );
      notiService.showNotification(
          title: 'Appointment created successfully for $selectedMeetingType',
          body: 'with $selectedContact'
      );
      Navigator.of(context).pop();
    } catch (e) {
      // error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create appointment: $e")),
      );
    }
  }

  void _scheduleReminder(Map<String, dynamic> appointment) {
    final notiService = NotiService();
    final dateTimeString = "${appointment['date']} ${appointment['time']}";
    final appointmentTime = DateFormat("yyyy-MM-dd h:mm a").parse(dateTimeString);

    final reminderPreference = appointment['reminderPreference'];
    Duration reminderDuration;
    switch (reminderPreference) {
      case '1 Day Before':
        reminderDuration = const Duration(days: 1);
        break;
      case '2 Hours Before':
        reminderDuration = const Duration(hours: 2);
        break;
      case '30 Minutes Before':
        reminderDuration = const Duration(minutes: 30);
        break;
      default:
        reminderDuration = Duration.zero;
    }
    final reminderTime = appointmentTime.subtract(reminderDuration);

    notiService.scheduleNotification(
      title: 'Reminder: ${appointment['title']}',
      body: 'Your appointment is coming up at ${appointment['time']}',
      reminderTime: reminderTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Create New Appointment',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  CustomTextField(
                    label: "Title",
                    hintText: selectedMeetingType,
                    onTap: () {
                      _showSelectionList(meetingTypes, (selectedValue) {
                        setState(() {
                          selectedMeetingType = selectedValue;
                        });
                      });
                    },
                    readOnly: true,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    label: "With",
                    hintText: selectedContact.isEmpty
                        ? "Select contact"
                        : selectedContact,
                    onTap: _selectContact,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    label: "Date",
                    onTap: _selectDate,
                    readOnly: true,
                    hintText: selectedDate.isEmpty ? "Select Date" : selectedDate,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    label: "Time",
                    onTap: _selectTime,
                    readOnly: true,
                    hintText: selectedTime.isEmpty ? "Select Time" : selectedTime,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    label: "Location",
                    onTap: () {
                      _showSelectionList(locations, (selectedValue) {
                        setState(() {
                          selectedLocationType = selectedValue;
                        });
                      });
                    },
                    readOnly: true,
                    hintText: selectedLocationType,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    label: "Category",
                    onTap: () {
                      _showSelectionList(categories, (selectedValue) {
                        setState(() {
                          selectedCategorieType = selectedValue;
                        });
                      });
                    },
                    readOnly: true,
                    hintText: selectedCategorieType,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _reminderPreference,
                    items: reminderOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _reminderPreference = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Reminder Preference'),
                    dropdownColor: Colors.white,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a reminder preference';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a status';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: "Create Appointment",
                        onPressed: () {
                          if (selectedContact.isNotEmpty &&
                              selectedDate.isNotEmpty &&
                              selectedTime.isNotEmpty) {
                            saveAppointmentToFirestore();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill all fields")),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}