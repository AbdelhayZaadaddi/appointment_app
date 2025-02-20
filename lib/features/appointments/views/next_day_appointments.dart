import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NextDaysAppointments extends StatefulWidget {
  final int numberOfDays;
  final DateTime week;

  const NextDaysAppointments({
    super.key,
    this.numberOfDays = 3,
    required this.week,
  });

  @override
  NextDaysAppointmentsState createState() => NextDaysAppointmentsState();
}

class NextDaysAppointmentsState extends State<NextDaysAppointments> {
  late Future<Map<String, List<Map<String, dynamic>>>> appointmentsByDay;
  List<String> formattedDates = [];
  List<String> dbDates = [];
  List<DateTime> dateTimes = [];
  bool isDeleting = false;
  Map<String, GlobalKey> dayKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
    appointmentsByDay = fetchAppointmentsForMultipleDays();
  }

  void _updateData() {
    formattedDates.clear();
    dbDates.clear();
    dateTimes.clear();
    dayKeys.clear();

    DateTime now = widget.week;
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    for (DateTime date = startOfWeek; date.isBefore(endOfWeek.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
      String formattedDate = DateFormat('E d').format(date);
      String dbDate = DateFormat('yyyy-M-d').format(date);

      formattedDates.add(formattedDate);
      dbDates.add(dbDate);
      dateTimes.add(date);
      dayKeys[formattedDate] = GlobalKey();
    }
  }

  @override
void didUpdateWidget(NextDaysAppointments oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Calculate week starts for old and new dates
  final DateTime oldWeekStart = oldWidget.week.subtract(Duration(days: oldWidget.week.weekday - 1));
  final DateTime newWeekStart = widget.week.subtract(Duration(days: widget.week.weekday - 1));

  if (newWeekStart != oldWeekStart) {
    _updateData();
    setState(() {
      appointmentsByDay = fetchAppointmentsForMultipleDays();
    });
  }
}


  void _initializeData() {
    formattedDates = [];
    dbDates = [];
    dateTimes = [];
    dayKeys = {};

    DateTime now = widget.week;
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    for (DateTime date = startOfWeek; date.isBefore(endOfWeek.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
      String formattedDate = DateFormat('E d').format(date);
      String dbDate = DateFormat('yyyy-M-d').format(date);

      formattedDates.add(formattedDate);
      dbDates.add(dbDate);
      dateTimes.add(date);
      dayKeys[formattedDate] = GlobalKey();
    }
  }

  
  // ... rest of the original NextDaysAppointments code remains the same ...
  // [Keep all other methods unchanged until build method]
  String get _userId{
    final currentuser = FirebaseAuth.instance.currentUser;
    if (currentuser == null) throw Exception("User not logged in");
    return currentuser.uid;
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchAppointmentsForMultipleDays() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("No user is logged in.");
        return {};
      }

      String currentUserId = _userId;
      Map<String, List<Map<String, dynamic>>> results = {};

      for (int i = 0; i < dbDates.length; i++) {

        List<Map<String, dynamic>> combinedResults = [];


        final userQuerySnapshot = await firestore
            .collection("appointments")
            .where("date", isEqualTo: dbDates[i])
            .where("userId", isEqualTo: currentUserId)
            .get();

        final contactQuerySnapshot = await firestore
            .collection("appointments")
            .where("date", isEqualTo: dbDates[i])
            .where("contactId", isEqualTo: currentUserId)
            .get();

        combinedResults.addAll(userQuerySnapshot.docs.map((doc) => {
              "docId": doc.id,
              ...doc.data(),
            }));

        combinedResults.addAll(contactQuerySnapshot.docs.map((doc) => {
              "docId": doc.id,
              ...doc.data(),
            }));


        final uniqueResults = {for (var item in combinedResults) item["docId"]: item}.values.toList();

        results[formattedDates[i]] = uniqueResults;
      }

      return results;
    } catch (e) {
      print("Error fetching appointments: $e");
      return {};
    }
  }




  void deleteAppointment(String docId) async {
    if (docId.isEmpty) {
      print("Error: Document ID is empty");
      return;
    }

    /*
    setState(() {
      isDeleting = true;
    });
    */

    try {
      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(docId)
          .delete();

      final updatedAppointments = await fetchAppointmentsForMultipleDays();

      setState(() {
        appointmentsByDay = Future.value(updatedAppointments);
      });

      if (mounted) {
        _showSuccess("Appointment delted successfuly");
      }
    } catch (e) {
      print("Error deleting appointment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting appointment: $e")),
        );
      }
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  void updatedAppointment(String docId) async {
    if (docId.isEmpty){
      print("Error: Document ID is empty");
      return;
    }

    final UpdateData = {
      "status" : "Canceld",
      "UpdatedAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection("appointments").doc(docId).update(UpdateData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel appointment: $e"))
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color.fromARGB(255, 6, 101, 104);
      case 'completed':
        return const Color.fromARGB(255, 40, 87, 168);
      case 'in progress':
        return const Color.fromARGB(255, 112, 69, 4);
      default:
        return Colors.grey;
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

  void updatedAppointmentArg(BuildContext context, String docId, String status) async {
    if (docId.isEmpty) {
      print("Error: Document ID is empty");
      return;
    }

    final UpdateData = {
      "status": status,
      "UpdatedAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection("appointments").doc(docId).update(UpdateData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel appointment: $e"))
      );
    }
  }
  
  Future<void> _showDialog(String docId) async {
    return showDialog(
      context: context, 
      builder: (context) => Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text('Cancel'),
            ),
            Text("Center test")
          ],
        )
      )
    );
  }
  
  

  Widget buildAppointmentCard(Map<String, dynamic> appointment) {
  final appointmentColor = getStatusColor(appointment["status"]);

  return Slidable(
      key: Key(appointment["docId"]),  

      startActionPane: ActionPane(
        motion: const ScrollMotion(),

        dismissible: DismissiblePane(onDismissed: () {}),


        children: [
          SlidableAction(
            onPressed: (BuildContext context){
               updatedAppointment(appointment["docId"]);
            },
            backgroundColor: Color.fromARGB(255, 52, 139, 25),
            foregroundColor: Colors.white,
            icon: Icons.done,
            label: 'Accecpt',
          ),
          SlidableAction(
            onPressed: (BuildContext context){},
            backgroundColor: Color.fromARGB(255, 143, 39, 13),
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Canceld',
          ),
        ],
      ),

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          /*
          SlidableAction(
            //flex: 2,
            onPressed: (BuildContext context){},
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          */
          SlidableAction(
            onPressed: (BuildContext context){},
            backgroundColor: Color.fromARGB(255, 238, 2, 2),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: appointmentColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if(_userId == appointment["userId"])
                      Icon(Icons.call_made_sharp, size: 15, color: Colors.white,)
                      else
                        Icon(Icons.call_received_outlined, size: 15, color: Colors.white,),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${appointment["time"]} ",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          _showDialog(appointment["docId"]);
                        },
                        child: Row(
                          children: [
                            Text(
                              "${appointment["status"]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_outlined, color: Colors.white,),
                          ],
                        )
                      ),
                      /*
                      const SizedBox(width: 10),
                      if(_userId == appointment["userId"])
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editAppointment,
                              arguments: appointment["docId"],
                            );
                          },
                          child: const Icon(Icons.edit, size: 15, color: Colors.white),
                        ),
                        */
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: appointmentColor.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${appointment['title']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${appointment['date']}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${appointment['contact']} ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Organiser ${appointment['from']}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            "${appointment['location']}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: appointmentsByDay,
        builder: (context, snapshot) {
          // ... existing build logic unchanged until the return Column...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              margin: const EdgeInsets.only(left: 10, top: 5),
              child: const Text(
                "No appointments found.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final appointmentsByDay = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: appointmentsByDay.entries.map((entry) {
              final date = entry.key;
              final appointments = entry.value;

              return Column(
                key: dayKeys[date], // This key is crucial for scroll detection
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 15),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (appointments.isEmpty)
                    Container(
                      // ... existing empty state ...
                       padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(24, 33, 149, 243),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      margin: const EdgeInsets.only(left: 0, top: 5),
                      width: double.infinity,
                      child: const Text(
                        textAlign: TextAlign.center,
                        "No appointments found.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...appointments.map((appointment) => buildAppointmentCard(appointment)),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}