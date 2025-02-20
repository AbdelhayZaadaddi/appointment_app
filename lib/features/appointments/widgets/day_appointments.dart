import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DayAppointments extends StatefulWidget {
  const DayAppointments({super.key});

  @override
  State<DayAppointments> createState() => _DayAppointmentsState();
}

class _DayAppointmentsState extends State<DayAppointments> {
  late Future<List<Map<String, dynamic>>> appointments;

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection("appointments").get();

      return querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appointments = fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Appointments',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.newAppointment);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                  children: appointments.map((appointment) {
                    return Container(
                      width: double.infinity,
                      decoration: TAppTheme.lightBoxShadow,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment["title"] ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Time: ${appointment["time"] ?? "No Time"}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "Location: ${appointment["location"] ?? "No Location"}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "Reminder: ${appointment["reminderPreference"] ?? "No Reminder"}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
