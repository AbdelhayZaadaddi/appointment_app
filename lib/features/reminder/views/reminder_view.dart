import 'package:appointement/features/reminder/widgets/noti_service.dart';
import 'package:flutter/material.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  final NotiService notiService = NotiService();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    notiService.initNotification(); // Initialize notifications
  }

  // Function to show a time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Function to schedule a notification
  void _scheduleNotification() {
    if (_selectedTime == null) return;

    // Create a DateTime object using the selected time and today's date
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Call the scheduleNotification method with the DateTime object
    notiService.scheduleNotification(
      title: 'Scheduled Notification',
      body: 'This is a scheduled notification!',
      reminderTime: scheduledDateTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification scheduled for ${_selectedTime!.format(context)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                notiService.showNotification(
                  title: 'Hello',
                  body: 'This is a test notification',
                );
              },
              child: const Text('Show Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Select Time'),
            ),
            const SizedBox(height: 20),
            if (_selectedTime != null)
              Text(
                'Selected Time: ${_selectedTime!.format(context)}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: const Text('Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}