import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/appointments/widgets/custom_button.dart';
import 'package:appointement/features/appointments/widgets/custom_text_field.dart';
import 'package:appointement/features/reminder/widgets/noti_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddAppointment extends StatefulWidget {

  final String? contact;
  final String? id;

  const AddAppointment({
    super.key,
    this.contact,
    this.id,
  });


  @override
  State<AddAppointment> createState() => _AddAppointment();
}

class _AddAppointment extends State<AddAppointment> {
  final NotiService notiService = NotiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userName;


  List<String> selectedContacts = [];
  List<String> selectedContactIds = [];
  List<QueryDocumentSnapshot> firebaseContacts = [];
  List<Map<String, dynamic>> selectedFriends = []; // Stores {id, name}


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

  List<String> categories = [
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

  // Get category
  Future<void> fetchCategories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Error: No user signed in.");
        return;
      }
      final snapshot = await firestore.collection('categories').doc(user.uid).collection('userCategories').get();
      List<String> fetchedCategories = snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        //categories.clear();
        categories.addAll(fetchedCategories);
      });

    } catch (e) {
      print("Error fetching categories: $e");
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


  /*
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
  */

  void loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {

      try {
        DocumentSnapshot doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc.get('name') ?? 'Test';
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  void saveAppointmentToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      final uuid = Uuid();
      List<String> friendIds = selectedFriends.map((f) => f['id'] as String).toList();
      List<String> friendNames = selectedFriends
    .map((f) => (f['name']?.toString() ?? 'Unnamed'))
    .toList();

      print(widget.id);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to create an appointment.')));
        return;
      }

      // data to save
      final appointmentData = {
        "id": uuid.v4(),
        "title": selectedMeetingType,
        "meetingType": selectedMeetingType,
        "from": userName,
        //"contact": selectedContact,
        "date": selectedDate,
        "time": selectedTime,
        "location": selectedLocationType,
        "category": selectedCategorieType,
        "status": selectedStatus,
        "createdAt": FieldValue.serverTimestamp(),
        "userId": user.uid,
        'reminderPreference': _reminderPreference,
        //'contactId': widget.id, 
        //"contacts": selectedContacts,
        //"contactIds": selectedContactIds,
        "contactsId": friendIds,
        "contacts": friendNames,
       // "userId": user.uid,
      };

      await firestore.collection("appointments").add(appointmentData);

      // send the notification
      for (String friendId in friendIds) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'receiverId': friendId,
          'senderId': user.uid,
          'type': 'New Appointment',
          'message': '${userName ?? "Someone"} invited you to a meeting',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      // success message
      _showSuccess("Appointment created successfully!");

      notiService.showNotification(
          title: 'Appointment created successfully for $selectedMeetingType',
          body: 'with $selectedContact'
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.homePageRoute,
        (Route<dynamic> route) => false,
      );

    } catch (e) {
      // error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create appointment: $e")),
      );
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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


  List<Map<String, dynamic>> friendsList = [];

  // Add loading state
  bool isLoadingFriends = false;

  Future<void> getFriends() async {
  try {
    setState(() => isLoadingFriends = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userSnapshot.exists || userSnapshot.data()?['friends'] == null) {
      setState(() => isLoadingFriends = false);
      return;
    }

    final friendIds = List<String>.from(userSnapshot.data()?['friends']);
    print('Found ${friendIds.length} friend IDs');

    List<Map<String, dynamic>> fetchedFriends = await Future.wait(
      friendIds.map((id) async {
        try {
          final friendSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .get();

          if (!friendSnapshot.exists) {
            return {'id': id, 'name': 'Deleted User'};
          }

          final data = friendSnapshot.data()!;
          return {
            'id': id,
            'name': _safeGetString(data, 'name') ?? 'Unnamed',
            'profilePic': _safeGetString(data, 'profilePic'),
          };
        } catch (e) {
          print('Error fetching friend $id: $e');
          return {'id': id, 'name': 'Error loading'};
        }
      }),
    );

    setState(() {
      friendsList = fetchedFriends.where((f) => f['name'] != null).toList();
      isLoadingFriends = false;
    });
  } catch (e) {
    print("Error fetching friends: $e");
    setState(() => isLoadingFriends = false);
  }
}

String? _safeGetString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is String) return value;
  return null;
}

String _getFriendName(Map<String, dynamic> friend) {
  final name = friend['name'];
  if (name is String) return name;
  if (name == null) return 'Unnamed';
  return name.toString();
}

  void _selectContacts() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const Text('Select Friends', style: TextStyle(fontSize: 20)),
              if (isLoadingFriends)
                const LinearProgressIndicator()
              else if (friendsList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No friends found'),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) {
                      final friend = friendsList[index];
                      final isSelected = selectedFriends.any((f) => f['id'] == friend['id']);
                      
                      return CheckboxListTile(
                        title: Text(friend['name']?.toString() ?? 'Unnamed',
    style: TextStyle(
      color: (friend['name']?.toString() ?? '').contains('Error') 
        ? Colors.red 
        : null
    ),),
                        secondary: friend['profilePic']?.isNotEmpty == true
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(friend['profilePic']),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              selectedFriends.add(friend);
                            } else {
                              selectedFriends.removeWhere((f) => f['id'] == friend['id']);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  //backgroundColor: 
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  @override
  void initState() {
    super.initState();
    getFriends().then((_) {
      print('Friends list loaded with ${friendsList.length} items');
    });
    loadUserData();
    fetchCategories();
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
  hintText: selectedFriends.isEmpty
      ? "Select friends"
      : selectedFriends.map(_getFriendName).join(", "),
                    onTap: _selectContacts,
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
                        /*
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
                        */
                        onPressed: (){
                          if (selectedFriends.isNotEmpty &&
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