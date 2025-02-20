import 'package:appointement/config/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodayAppointments extends StatefulWidget {
  const TodayAppointments({super.key});

  @override
  State<TodayAppointments> createState() => _TodayAppointmentsState();
}

class _TodayAppointmentsState extends State<TodayAppointments> {
  late Future<List<Map<String, dynamic>>> appointments;


  Future<List<Map<String, dynamic>>> fetchAppointments() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final today = DateFormat('yyyy-M-d').format(DateTime.now());

    final querySnapshot = await firestore
        .collection("appointments")
        .where("date", isEqualTo: today)
        //.limit(5)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        "docId": doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  } catch (e) {
    print("Error fetching appointments: $e");
    return [];
  }
}


  
 
  void deleteAppointment(String docId) async {
    if (docId.isEmpty) {
      print("Error: Document ID is empty");
      return;
    }

    try {
      print("Attempting to delete appointment: $docId");
      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(docId)
          .delete();
      print("Appointment deleted successfully: $docId");

      setState(() {
        appointments = fetchAppointments();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment deleted successfully")),
      );
    } catch (e) {
      print("Error deleting appointment: $e");
    }
  }




  @override
  void initState() {
    super.initState();
    appointments = fetchAppointments();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                  'Today\'s Appointments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                )
              ],
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: appointments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                  return const Center(
                    child: Text("No appointments found."),
                  );
                }

                final appointments = snapshot.data!;

                return Column(
                  children: [
                    ...appointments.map((appointment) {
                      final appointmentColor = getStatusColor(appointment["status"]);
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 4),
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${appointment["time"]} ",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${appointment["status"]}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print(appointment["id"].runtimeType);
                                          print(appointment["id"]);                                
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.editAppointment,
                                            arguments: appointment["docId"],
                                          );

                                        },
                                        child: const Icon(Icons.edit, size: 15, color: Colors.white),
                                      ),
                                      const SizedBox(
                                        width:10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (appointment["docId"] != null) {
                                          deleteAppointment(appointment["docId"]);
                                          } else {
                                            print("Error: Appointment ID is null");
                                          }
                                        },
                                        child: const Icon(Icons.delete, size: 15, color: Colors.red),
                                      ),


                                    ],
                                  )
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
                              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${appointment['date']}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      )
                                    ],
                                  ),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${appointment['contact']}",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        "${appointment['location']}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    TextButton(
                      onPressed: () {
                        // Navigate to a screen that shows all appointments
                        //Navigator.pushNamed(context, AppRoutes.allAppointments);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}